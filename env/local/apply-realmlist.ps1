# Point a 3.3.5a client at the local AzerothCore authserver.
param(
    [string]$ClientDir
)

$ErrorActionPreference = "Stop"
$realmlist = @"
set realmlist 127.0.0.1
set patchlist 127.0.0.1
"@

function Set-Realmlist([string]$dir) {
    $targets = @(
        (Join-Path $dir "realmlist.wtf"),
        (Join-Path $dir "Data\enUS\realmlist.wtf"),
        (Join-Path $dir "Data\enGB\realmlist.wtf")
    ) | Where-Object { Test-Path (Split-Path $_ -Parent) }

    if (-not $targets) {
        $targets = @(Join-Path $dir "realmlist.wtf")
    }

    foreach ($path in $targets) {
        Set-Content -Path $path -Value $realmlist -Encoding ascii
        Write-Host "Wrote $path"
    }
}

if (-not $ClientDir) {
    $wow = Get-ChildItem -Path @(
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\Documents",
        "C:\dev",
        "C:\Games",
        "C:\WoW",
        "C:\wow"
    ) -Filter "Wow.exe" -Recurse -ErrorAction SilentlyContinue -Depth 6 |
        Where-Object { $_.VersionInfo.FileVersion -like "*3.3.5*" -or $_.Length -gt 4MB } |
        Select-Object -First 5

    if (-not $wow) {
        Write-Host "No Wow.exe found yet. Re-run after extract:"
        Write-Host "  .\env\local\apply-realmlist.ps1 -ClientDir 'C:\path\to\3.3.5a'"
        exit 1
    }

    $wow | ForEach-Object {
        Write-Host "Found $($_.FullName) version=$($_.VersionInfo.FileVersion)"
        Set-Realmlist $_.DirectoryName
    }
    exit 0
}

if (-not (Test-Path $ClientDir)) {
    throw "Client dir not found: $ClientDir"
}

Set-Realmlist $ClientDir
Write-Host "Launch Wow.exe from that folder (not Battle.net / Launcher.exe)."
