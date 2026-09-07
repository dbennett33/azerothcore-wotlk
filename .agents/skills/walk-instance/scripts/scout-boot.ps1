# One-time scout client: second Wow.exe, windowed, does not touch Gonzalez's install.
# Requires SOAP. Does not Stop-Process Wow.
$ErrorActionPreference = "Stop"
$src = "C:\dev\wow-335\ChromieCraft_3.3.5a"
$dst = "C:\dev\wow-335\scout"
New-Item -ItemType Directory -Force -Path $dst, "$dst\WTF", "$dst\Cache", "$dst\Logs", "$dst\Screenshots" | Out-Null
foreach ($f in @("Wow.exe", "Battle.net.dll", "dbghelp.dll", "DivxDecoder.dll", "ijl15.dll", "msvcr80.dll", "unicows.dll", "Scan.dll", "WowError.exe", "realmlist.wtf")) {
  Copy-Item -Force (Join-Path $src $f) (Join-Path $dst $f)
}
if (-not (Test-Path "$dst\Data")) {
  cmd /c mklink /J "$dst\Data" "$src\Data" | Out-Host
}
if (-not (Test-Path "$dst\Interface")) {
  cmd /c mklink /J "$dst\Interface" "$src\Interface" | Out-Host
}
@"
SET realmList "127.0.0.1"
SET gxWindow "1"
SET gxMaximize "0"
SET gxResolution "1024x768"
SET gxRefresh "60"
SET screenshotFormat "jpg"
SET screenshotQuality "10"
SET farclip "397"
SET Sound_EnableSFX "0"
SET Sound_EnableAmbience "0"
SET Sound_EnableMusic "0"
"@ | Set-Content -Path "$dst\WTF\Config.wtf" -Encoding ASCII
Write-Host "Scout client ready at $dst"
