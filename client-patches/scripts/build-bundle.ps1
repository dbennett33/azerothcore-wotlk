#Requires -Version 5.1
<#
.SYNOPSIS
    Build a versioned client/server patch bundle from sources\.

.PARAMETER Version
    Semver release id (e.g. 1.0.0).

.PARAMETER CacheVersion
    ClientCacheVersion to publish (default: previous manifest value + 1).

.PARAMETER Locale
    Client locale folder (default: enUS).

.PARAMETER Changelog
    Repeatable changelog lines.

.PARAMETER SkipPlaceholder
    Allow building when no client or server inputs exist.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Version,
    [int]$CacheVersion,
    [string]$Locale = 'enUS',
    [string[]]$Changelog = @(),
    [switch]$SkipPlaceholder
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib.ps1')

if ($Version -notmatch '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$') {
    throw "Version must be semver (e.g. 1.0.0), got: $Version"
}

$root = Get-ClientPatchesRoot
$sources = Join-Path $root 'sources'
$outDir = Join-Path $root (Join-Path 'bundles' $Version)
$outClient = Join-Path $outDir 'client'
$outServer = Join-Path $outDir 'server'
New-Item -ItemType Directory -Path $outClient -Force | Out-Null
New-Item -ItemType Directory -Path $outServer -Force | Out-Null

Get-ChildItem -LiteralPath $outClient -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Extension -match '^\.mpq$' } |
    Remove-Item -Force

$mpqDir = Join-Path $sources (Join-Path 'client' 'mpq')
$clientMpqs = @()
if (Test-Path -LiteralPath $mpqDir -PathType Container) {
    $clientMpqs = @(Get-ChildItem -LiteralPath $mpqDir -File |
        Where-Object { $_.Extension -match '^\.mpq$' } |
        Sort-Object Name)
}

$serverComponents = @()
foreach ($component in @('dbc', 'maps', 'vmaps', 'mmaps')) {
    $componentDir = Join-Path $sources (Join-Path 'server' $component)
    if (Test-DirHasFiles $componentDir) {
        $serverComponents += $component
    }
}

if ($clientMpqs.Count -eq 0 -and $serverComponents.Count -eq 0 -and -not $SkipPlaceholder) {
    throw "No inputs under $sources\client\mpq or $sources\server. Add MPQs or server data first."
}

$looseDir = Join-Path $sources (Join-Path 'client' 'loose')
if (Test-DirHasFiles $looseDir) {
    Write-Host 'note: loose client files found. Pack them into sources\client\mpq\ with an MPQ editor.'
    Write-Host '      See docs/client-patches.md'
}

$patches = @()
foreach ($mpq in $clientMpqs) {
    $dest = Join-Path $outClient $mpq.Name
    Copy-Item -LiteralPath $mpq.FullName -Destination $dest -Force
    $patches += [pscustomobject]@{
        file          = $mpq.Name
        sha256        = Get-FileSha256Hex $dest
        size          = [int64]$mpq.Length
        install_path  = "Data/$Locale/$($mpq.Name)"
    }
}

$serverArchive = 'server-data.tar.gz'
$serverSha = ''
$serverSize = 0
if ($serverComponents.Count -gt 0) {
    $tar = Assert-NativeCommand 'tar.exe' 'tar.exe ships with Windows 10+.'
    $archivePath = Join-Path $outServer $serverArchive
    if (Test-Path -LiteralPath $archivePath) {
        Remove-Item -LiteralPath $archivePath -Force
    }
    $serverRoot = Join-Path $sources 'server'
    Invoke-Native -FilePath $tar -ArgumentList (@('-czf', $archivePath, '-C', $serverRoot) + $serverComponents)
    $serverSha = Get-FileSha256Hex $archivePath
    $serverSize = [int64](Get-Item -LiteralPath $archivePath).Length
}

$existingManifest = Join-Path $root 'manifest.json'
if (-not $PSBoundParameters.ContainsKey('CacheVersion')) {
    $CacheVersion = 1
    if (Test-Path -LiteralPath $existingManifest -PathType Leaf) {
        $prev = Read-ClientPatchManifest $existingManifest
        $prevCache = 0
        if ($null -ne $prev.client_cache_version) {
            $prevCache = [int]$prev.client_cache_version
        }
        $CacheVersion = $prevCache + 1
    }
}

$outManifest = Join-Path $outDir 'manifest.json'
Write-ClientPatchManifest -Path $outManifest -Version $Version -CacheVersion $CacheVersion `
    -Locale $Locale -Changelog $Changelog -Patches $patches `
    -ServerArchive $serverArchive -ServerSha256 $serverSha -ServerSize $serverSize `
    -ServerComponents $serverComponents

Copy-Item -LiteralPath $outManifest -Destination $existingManifest -Force

$written = Read-ClientPatchManifest $outManifest
Assert-ClientPatchManifest $written
foreach ($patch in @(Get-ManifestPatches $written)) {
    Assert-Sha256 (Join-Path $outClient $patch.file) ([string]$patch.sha256)
    Write-Host "client patch checksum ok: $($patch.file)"
}
if ($serverSha) {
    Assert-Sha256 (Join-Path $outServer $serverArchive) $serverSha
    Write-Host 'server archive checksum ok'
}

Write-Host ""
Write-Host "Built bundle ${Version}:"
Write-Host "  $outDir"
Write-Host "  manifest copied to $existingManifest"
Write-Host ""
Write-Host 'Next steps:'
Write-Host '  1. Commit manifest.json (not bundle binaries under bundles/).'
Write-Host '  2. Publish binaries to the VPS:'
Write-Host "       .\client-patches\scripts\publish-to-vps.ps1 '$outDir'"
Write-Host '  3. Deploy server data: GitHub Actions -> deploy-client-patches'
Write-Host '  4. Players update locally:'
Write-Host '       .\client-patches\scripts\update-client.ps1 -WowDir <WoW> -FromVps debian@your.vps'
