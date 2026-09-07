param(
  [Parameter(Mandatory = $true)][string]$OutFile,
  [int]$SettleMs = 600,
  [string]$InstallMatch = '*wow-335\scout*'
)
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
if (-not ([System.Management.Automation.PSTypeName]'NativeWowCap').Type) {
  Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class NativeWowCap {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
  public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
}
"@
}

function Get-ScoutWow {
  $all = Get-Process -Name Wow -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero }
  $scout = $all | Where-Object { $_.Path -like $InstallMatch }
  if ($scout) { return $scout | Select-Object -First 1 }
  $n = @($all).Count
  if ($n -eq 1) {
    Write-Warning "No Wow.exe matched $InstallMatch; capturing the only Wow window."
    return $all | Select-Object -First 1
  }
  throw "Scout Wow.exe not found (match $InstallMatch)."
}

$p = Get-ScoutWow
$hwnd = $p.MainWindowHandle
[void][NativeWowCap]::ShowWindow($hwnd, 9)
[void][NativeWowCap]::SetForegroundWindow($hwnd)
Start-Sleep -Milliseconds $SettleMs
$rect = New-Object NativeWowCap+RECT
if (-not [NativeWowCap]::GetWindowRect($hwnd, [ref]$rect)) {
  throw "GetWindowRect failed"
}
$w = $rect.Right - $rect.Left
$h = $rect.Bottom - $rect.Top
if ($w -lt 200 -or $h -lt 200) {
  throw ("Window too small or minimized ({0}x{1}). Scout must be windowed and restored." -f $w, $h)
}
$dir = Split-Path -Parent $OutFile
if ($dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
$bmp = New-Object System.Drawing.Bitmap $w, $h
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bmp.Size)
$g.Dispose()
$bmp.Save($OutFile, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
$item = Get-Item $OutFile
Write-Host ("CAPTURED {0} ({1} bytes, {2}x{3} pid={4})" -f $item.FullName, $item.Length, $w, $h, $p.Id)
if ($item.Length -lt 8000) {
  Write-Warning "Tiny PNG - likely black (fullscreen/minimized). Recapture once, then stop."
}
