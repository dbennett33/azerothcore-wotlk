#Requires -Version 5.1
<#
.SYNOPSIS
    Upload a local bundle directory to the VPS patch store and publish it.

.PARAMETER BundleDir
    Path to client-patches\bundles\<version> (contains manifest.json).

.PARAMETER VpsHost
    SSH login user@host (e.g. debian@203.0.113.10). Env: VPS_HOST
    Files are stored under /home/acore/; publish runs as acore via sudo.

.PARAMETER RemoteRepo
    AzerothCore checkout on the VPS. Env: REMOTE_REPO
    Default: /home/acore/src/azerothcore-wotlk
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$BundleDir,
    [string]$VpsHost = $env:VPS_HOST,
    [string]$RemoteRepo = $env:REMOTE_REPO
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib.ps1')

if (-not $VpsHost) {
    throw 'Set -VpsHost or environment variable VPS_HOST (e.g. debian@203.0.113.10)'
}
if (-not $RemoteRepo) {
    $RemoteRepo = '/home/acore/src/azerothcore-wotlk'
}

$BundleDir = (Resolve-Path -LiteralPath $BundleDir).Path
$manifestPath = Join-Path $BundleDir 'manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    throw "Bundle directory not found or missing manifest.json: $BundleDir"
}

$ssh = Assert-NativeCommand 'ssh.exe' 'Install OpenSSH Client (Settings → Apps → Optional features).'
$scp = Assert-NativeCommand 'scp.exe' 'Install OpenSSH Client (Settings → Apps → Optional features).'

$manifest = Read-ClientPatchManifest $manifestPath
$version = [string]$manifest.version
$remoteStaging = "/home/acore/client-patches/staging/$version"

Write-Host "Uploading bundle $version to ${VpsHost}:${remoteStaging} ..."
Invoke-Native -FilePath $ssh -ArgumentList @($VpsHost, "rm -rf '$remoteStaging' && mkdir -p '$remoteStaging'")

Get-ChildItem -LiteralPath $BundleDir -Force | ForEach-Object {
    $local = ConvertTo-ScpLocalPath $_.FullName
    Invoke-Native -FilePath $scp -ArgumentList @('-r', '--', $local, "${VpsHost}:${remoteStaging}/")
}

$publish = "$RemoteRepo/apps/deploy/debian12/client-patches/publish-client-patches.sh"
Write-Host 'Publishing on VPS as acore ...'
Invoke-Native -FilePath $ssh -ArgumentList @(
    $VpsHost,
    "sudo chown -R acore:acore '$remoteStaging' && sudo -u acore bash '$publish' '$remoteStaging'"
)

Write-Host 'Done. Bundle is in the VPS store only — Live and Test are unchanged.'
Write-Host 'Commit client-patches/manifest.json with the matching C++/SQL, then:'
Write-Host '  git push origin dev        # vps-build → deploy-vps applies overlay to Test'
Write-Host '  merge to Playerbot         # then Actions → deploy-vps → live'
Write-Host 'Players: update-client.ps1 -FromVps debian@host -Target test   # or -Target live'
