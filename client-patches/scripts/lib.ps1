# Shared helpers for client-patches PowerShell scripts (Windows PowerShell 5.1+ / pwsh).
#Requires -Version 5.1

$script:ClientPatchesRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

function Get-ClientPatchesRoot {
    $script:ClientPatchesRoot
}

function Get-NativeCommand {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )
    $cmd = Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($cmd) {
        return $cmd.Source
    }
    return $null
}

function Assert-NativeCommand {
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$Hint
    )
    $path = Get-NativeCommand $Name
    if (-not $path -and $Name -notlike '*.exe') {
        $path = Get-NativeCommand ($Name + '.exe')
    }
    if (-not $path -and $Name -like '*.exe') {
        $path = Get-NativeCommand ([IO.Path]::GetFileNameWithoutExtension($Name))
    }
    if (-not $path) {
        $msg = "Missing required command: $Name"
        if ($Hint) {
            $msg = "$msg. $Hint"
        }
        throw $msg
    }
    return $path
}

function Invoke-Native {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,
        [string[]]$ArgumentList = @()
    )
    if ($null -eq $ArgumentList) {
        $ArgumentList = @()
    }
    & $FilePath @ArgumentList
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed ($LASTEXITCODE): $FilePath $($ArgumentList -join ' ')"
    }
}

function ConvertTo-ScpLocalPath {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    ([System.IO.Path]::GetFullPath($Path)).Replace('\', '/')
}

function Get-FileSha256Hex {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Assert-Sha256 {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Expected
    )
    $expected = $Expected.Trim().ToLowerInvariant()
    if ($expected -notmatch '^[a-f0-9]{64}$') {
        throw "Invalid SHA-256 in manifest for ${Path}: $Expected"
    }
    $actual = Get-FileSha256Hex $Path
    if ($actual -ne $expected) {
        throw "Checksum mismatch for ${Path}`n  expected: $expected`n  actual:   $actual"
    }
}

function ConvertTo-ObjectArray {
    param($Value)
    if ($null -eq $Value) {
        return @()
    }
    if ($Value -is [System.Array]) {
        return @($Value)
    }
    return @($Value)
}

function ConvertTo-JsonString {
    param([AllowNull()][string]$Value)
    if ($null -eq $Value) {
        $Value = ''
    }
    $escaped = $Value.
        Replace('\', '\\').
        Replace('"', '\"').
        Replace("`r", '\r').
        Replace("`n", '\n').
        Replace("`t", '\t')
    '"{0}"' -f $escaped
}

function ConvertTo-JsonStringArray {
    param([AllowNull()][object]$Items)
    $values = @(ConvertTo-ObjectArray $Items | ForEach-Object { ConvertTo-JsonString ([string]$_) })
    if ($values.Count -eq 0) {
        return '[]'
    }
    return ('[' + ($values -join ', ') + ']')
}

function Read-ClientPatchManifest {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Manifest not found: $Path"
    }
    Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Assert-ClientPatchManifest {
    param(
        [Parameter(Mandatory)]
        $Manifest
    )
    $required = @(
        'version', 'released', 'blizzard_build', 'client_cache_version',
        'changelog', 'client', 'server'
    )
    foreach ($key in $required) {
        if ($null -eq $Manifest.$key) {
            throw "manifest missing required key: $key"
        }
    }
    if ($null -eq $Manifest.client.locale -or $null -eq $Manifest.client.patches) {
        throw 'manifest missing client.locale or client.patches'
    }
    if ($Manifest.version -eq '0.0.0') {
        Write-Warning 'placeholder manifest version 0.0.0'
    }
}

function Get-ManifestPatches {
    param(
        [Parameter(Mandatory)]
        $Manifest
    )
    ConvertTo-ObjectArray $Manifest.client.patches
}

function Write-ClientPatchManifest {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Version,
        [Parameter(Mandatory)]
        [int]$CacheVersion,
        [string]$Locale = 'enUS',
        [string[]]$Changelog = @(),
        [object[]]$Patches = @(),
        [string]$ServerArchive = 'server-data.tar.gz',
        [string]$ServerSha256 = '',
        [long]$ServerSize = 0,
        [string[]]$ServerComponents = @()
    )
    if (-not $Changelog -or $Changelog.Count -eq 0) {
        $Changelog = @("Release $Version")
    }
    $released = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
    $patchLines = @()
    foreach ($patch in @(ConvertTo-ObjectArray $Patches)) {
        $patchLines += @(
            '      {',
            ('        "file": {0},' -f (ConvertTo-JsonString $patch.file)),
            ('        "sha256": {0},' -f (ConvertTo-JsonString $patch.sha256)),
            ('        "size": {0},' -f [int64]$patch.size),
            ('        "install_path": {0}' -f (ConvertTo-JsonString $patch.install_path)),
            '      }'
        ) -join "`n"
    }
    $patchesJson = '[]'
    if ($patchLines.Count -gt 0) {
        $patchesJson = '[' + "`n" + ($patchLines -join ",`n") + "`n" + '    ]'
    }

    $changelogJson = ConvertTo-JsonStringArray $Changelog
    $componentsJson = ConvertTo-JsonStringArray $ServerComponents
    $json = @(
        '{',
        ('  "version": {0},' -f (ConvertTo-JsonString $Version)),
        ('  "released": {0},' -f (ConvertTo-JsonString $released)),
        '  "blizzard_build": 12340,',
        ('  "client_cache_version": {0},' -f $CacheVersion),
        ('  "changelog": {0},' -f $changelogJson),
        '  "client": {',
        ('    "locale": {0},' -f (ConvertTo-JsonString $Locale)),
        ('    "patches": {0}' -f $patchesJson),
        '  },',
        '  "server": {',
        ('    "archive": {0},' -f (ConvertTo-JsonString $ServerArchive)),
        ('    "sha256": {0},' -f (ConvertTo-JsonString $ServerSha256)),
        ('    "size": {0},' -f [int64]$ServerSize),
        ('    "components": {0}' -f $componentsJson),
        '  }',
        '}'
    ) -join "`n"

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $json + "`n", [System.Text.UTF8Encoding]::new($false))
}

function Test-DirHasFiles {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        return $false
    }
    $null -ne (Get-ChildItem -LiteralPath $Path -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notin @('.gitkeep', 'README.md') } |
        Select-Object -First 1)
}

function Get-ClientMpqInstallPath {
    param(
        [Parameter(Mandatory)]
        [string]$FileName,
        [string]$Locale = 'enUS'
    )
    # Locale and lettered patches go under Data/<locale>/. Numeric global patches
    # (patch-4.MPQ) go under Data/ -- that is where 3.3.5a and the extractors look.
    if ($FileName -match ('(?i)^patch-{0}' -f [regex]::Escape($Locale))) {
        return "Data/$Locale/$FileName"
    }
    if ($FileName -match '^patch-[A-Za-z]') {
        return "Data/$Locale/$FileName"
    }
    return "Data/$FileName"
}

function Get-HttpDownloader {
    $curl = Get-NativeCommand 'curl.exe'
    if ($curl) {
        return $curl
    }
    return $null
}

function Save-HttpFile {
    param(
        [Parameter(Mandatory)]
        [string]$Url,
        [Parameter(Mandatory)]
        [string]$Destination
    )
    $parent = Split-Path -Parent $Destination
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent | Out-Null
    }
    $curl = Get-HttpDownloader
    if ($curl) {
        Invoke-Native -FilePath $curl -ArgumentList @('-fsSL', $Url, '-o', $Destination)
        return
    }
    # Fallback when curl.exe is missing (rare on current Windows).
    Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
}
