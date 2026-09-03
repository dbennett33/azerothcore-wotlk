#Requires -Version 5.1
<#
.SYNOPSIS
    Download and install client MPQ patches for a local WoW 3.3.5a install.

.DESCRIPTION
    Fetches manifest.json and MPQ files from the VPS (scp) or an HTTP base URL,
    verifies SHA-256 checksums, and copies patches into the WoW Data folder.

.PARAMETER WowDir
    WoW install root (contains Data\ and Wow.exe). Env: WOW_DIR

.PARAMETER PatchesUrl
    Base URL of a release directory that contains manifest.json. Env: PATCHES_BASE_URL

.PARAMETER FromVps
    user@host for scp from /home/acore/client-patches/current. Env: FROM_VPS

.PARAMETER Version
    Release version when using -FromVps (default: current symlink). Env: VERSION

.PARAMETER Locale
    Override locale folder from the manifest (rewrites Data/<locale>/ in install_path).

.PARAMETER DryRun
    Show install destinations without writing files.

.EXAMPLE
    .\update-client.ps1 -WowDir 'C:\Games\ChromieCraft' -FromVps 'acore@203.0.113.10'

.EXAMPLE
    .\update-client.ps1 -WowDir 'C:\Games\ChromieCraft' -PatchesUrl 'https://example.com/client-patches/current'
#>
[CmdletBinding()]
param(
    [string]$WowDir = $env:WOW_DIR,
    [string]$PatchesUrl = $env:PATCHES_BASE_URL,
    [string]$FromVps = $env:FROM_VPS,
    [string]$Version = $env:VERSION,
    [string]$Locale,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib.ps1')

if (-not $WowDir) {
    throw 'Set -WowDir or environment variable WOW_DIR'
}

$WowDir = (Resolve-Path -LiteralPath $WowDir).Path
$dataDir = Join-Path $WowDir 'Data'
if (-not (Test-Path -LiteralPath $dataDir -PathType Container)) {
    throw "WoW Data\ directory not found under $WowDir"
}

if (-not $FromVps -and -not $PatchesUrl) {
    throw 'Set -FromVps or -PatchesUrl (or FROM_VPS / PATCHES_BASE_URL)'
}

$scp = $null
$remoteRelease = $null
$base = $null
if ($FromVps) {
    $scp = Assert-NativeCommand 'scp.exe' 'Install OpenSSH Client (Settings > Apps > Optional features).'
}

$work = Join-Path ([System.IO.Path]::GetTempPath()) ('acore-client-patches-' + [guid]::NewGuid().ToString('n'))
New-Item -ItemType Directory -Path $work | Out-Null
$clientDir = Join-Path $work 'client'
New-Item -ItemType Directory -Path $clientDir | Out-Null
$manifestLocal = Join-Path $work 'manifest.json'

try {
    if ($FromVps) {
        $remoteBase = '/home/acore/client-patches'
        if ($Version) {
            $remoteRelease = "$remoteBase/releases/$Version"
        } else {
            $remoteRelease = "$remoteBase/current"
        }
        Invoke-Native -FilePath $scp -ArgumentList @(
            '-q', '--',
            "${FromVps}:${remoteRelease}/manifest.json",
            (ConvertTo-ScpLocalPath $manifestLocal)
        )
    } else {
        $base = $PatchesUrl.TrimEnd('/')
        Save-HttpFile "$base/manifest.json" $manifestLocal
    }

    $manifest = Read-ClientPatchManifest $manifestLocal
    Assert-ClientPatchManifest $manifest
    $patches = @(Get-ManifestPatches $manifest)
    if ($patches.Count -eq 0) {
        throw "Manifest $($manifest.version) has no client patches to install"
    }

    $manifestLocale = [string]$manifest.client.locale
    if (-not $Locale) {
        $Locale = $manifestLocale
    }
    $targetVersion = [string]$manifest.version
    $stateFile = Join-Path $WowDir '.acore-client-patch-version'
    if ((Test-Path -LiteralPath $stateFile -PathType Leaf) -and
        ((Get-Content -LiteralPath $stateFile -Raw).Trim() -eq $targetVersion)) {
        Write-Host "Client already at patch version $targetVersion"
        return
    }

    foreach ($patch in $patches) {
        $file = [string]$patch.file
        if (-not $file -or $file -eq 'null') {
            continue
        }
        $dest = Join-Path $clientDir $file
        if ($FromVps) {
            Invoke-Native -FilePath $scp -ArgumentList @(
                '-q', '--',
                "${FromVps}:${remoteRelease}/client/${file}",
                (ConvertTo-ScpLocalPath $dest)
            )
        } else {
            Save-HttpFile "$base/client/$file" $dest
        }
        Assert-Sha256 $dest ([string]$patch.sha256)
        Write-Host "verified $file"
    }

    foreach ($patch in $patches) {
        $file = [string]$patch.file
        $relPath = [string]$patch.install_path
        if (-not $file -or -not $relPath -or $relPath -eq 'null') {
            continue
        }
        $manifestPrefix = "Data/$manifestLocale/"
        if ($Locale -ne $manifestLocale -and $relPath.StartsWith($manifestPrefix)) {
            $relPath = "Data/$Locale/" + $relPath.Substring($manifestPrefix.Length)
        }
        $src = Join-Path $clientDir $file
        $dest = Join-Path $WowDir ($relPath -replace '/', '\')
        $destParent = Split-Path -Parent $dest
        if ($DryRun) {
            Write-Host "would install $src -> $dest"
            continue
        }
        if (-not (Test-Path -LiteralPath $destParent)) {
            New-Item -ItemType Directory -Path $destParent | Out-Null
        }
        Copy-Item -LiteralPath $src -Destination $dest -Force
        Write-Host "installed $dest"
    }

    if (-not $DryRun) {
        [System.IO.File]::WriteAllText($stateFile, $targetVersion + "`n", [System.Text.UTF8Encoding]::new($false))
        Write-Host "Client patch version set to $targetVersion"
        Write-Host "Server ClientCacheVersion for this release: $($manifest.client_cache_version)"
        Write-Host "Close WoW completely before launching if it was already running."
    }
} finally {
    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
