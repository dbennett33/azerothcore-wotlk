# Stage the built model + DBCs into client-patches/sources/client/loose, repack BOTH archives
# (patch-4 = world files, patch-enUS-4 = DBCs) with MPQEditor and install into the dev client.
# Existing DBCs already shipped in patch-enUS-4 are kept (extracted first). Closes no Wow.exe
# on its own: stop the client yourself before running.
param(
  [string]$Repo = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path,
  [string]$ModelDir = "WaxCandle",
  [string]$Out = "$PSScriptRoot\out",
  [string]$Client = $(if ($env:WOW_CLIENT) { $env:WOW_CLIENT } else { "C:\dev\wow-335\scout" }),
  [string]$MpqEditor = "C:\dev\tools\mpqeditor\x64\MPQEditor.exe",
  [string]$BlenderPython = "C:\dev\tools\blender\blender-3.4.1-windows-x64\3.4\python\bin\python.exe",
  [switch]$SkipInstall
)
$ErrorActionPreference = "Stop"
if (Get-Process Wow -ErrorAction SilentlyContinue) { throw "Close every Wow.exe first (MPQs are locked / read stale)." }
$loose = Join-Path $Repo "client-patches\sources\client\loose"
$mpqdir = Join-Path $Repo "client-patches\sources\client\mpq"

New-Item -ItemType Directory -Force "$loose\Creature\$ModelDir", "$loose\DBFilesClient" | Out-Null
Copy-Item "$Out\Creature\$ModelDir\*" "$loose\Creature\$ModelDir\" -Force

# keep the DBCs the current locale archive already ships
if (Test-Path "$mpqdir\patch-enUS-4.MPQ") {
  $wbs = if ($env:WBS_ROOT) { $env:WBS_ROOT } else { "C:\dev\tools\blender-wow-studio\io_scene_wmo" }
  & $BlenderPython -c @"
import sys; sys.path.insert(0, r'$wbs')
from pywowlib.archives.mpq import MPQFile
m = MPQFile(r'$mpqdir\patch-enUS-4.MPQ')
for n in [x for x in m.namelist() if x.lower().endswith('.dbc')]:
    dst = r'$loose\DBFilesClient' + chr(92) + n.split('/')[-1]
    if not __import__('os').path.exists(dst):
        open(dst, 'wb').write(m.read(n.replace('/', chr(92)))); print('kept', n)
m.close()
"@
}
Copy-Item "$Out\DBFilesClient\*.dbc" "$loose\DBFilesClient\" -Force

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
foreach ($a in "patch-4.MPQ", "patch-enUS-4.MPQ") {
  if (Test-Path "$mpqdir\$a") { Move-Item "$mpqdir\$a" "$mpqdir\$a.bak-$stamp" -Force }
}
$adds = foreach ($top in Get-ChildItem $loose -Directory | Where-Object { $_.Name -ne "DBFilesClient" }) {
  "add `"$mpqdir\patch-4.MPQ`" `"$loose\$($top.Name)\*`" `"$($top.Name)\`" /c /r"
}
$script = @(
  "new `"$mpqdir\patch-4.MPQ`" 0x1000"
) + $adds + @(
  "flush `"$mpqdir\patch-4.MPQ`"", "close",
  "new `"$mpqdir\patch-enUS-4.MPQ`" 0x1000",
  "add `"$mpqdir\patch-enUS-4.MPQ`" `"$loose\DBFilesClient\*`" `"DBFilesClient\`" /c /r",
  "flush `"$mpqdir\patch-enUS-4.MPQ`"", "close"
) -join "`r`n"
$txt = Join-Path $env:TEMP "pack-creature.txt"
Set-Content -Path $txt -Value $script -Encoding ascii          # ASCII: a BOM makes `new` a silent no-op
& $MpqEditor /console $txt | Out-Null
Get-ChildItem "$mpqdir\patch-4.MPQ", "$mpqdir\patch-enUS-4.MPQ" | ForEach-Object { "{0} {1:N0} bytes" -f $_.Name, $_.Length }

if (-not $SkipInstall) {
  Copy-Item "$mpqdir\patch-4.MPQ" "$Client\Data\patch-4.MPQ" -Force
  Copy-Item "$mpqdir\patch-enUS-4.MPQ" "$Client\Data\enUS\patch-enUS-4.MPQ" -Force
  Remove-Item "$Client\Cache\WDB" -Recurse -Force -ErrorAction SilentlyContinue
  "installed into $Client (WDB cache cleared)"
}
