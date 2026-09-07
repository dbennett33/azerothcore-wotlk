param(
  [Parameter(Mandatory = $true)][string]$Text,
  [int]$WaitMs = 800,
  [string]$InstallMatch = '*wow-335\scout*'
)
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms
if (-not ([System.Management.Automation.PSTypeName]'NativeWow').Type) {
  Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class NativeWow {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
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
    Write-Warning "No Wow.exe matched $InstallMatch; using the only Wow process. Do not SendKeys if this is Gonzalez."
    return $all | Select-Object -First 1
  }
  throw "Scout Wow.exe not found (match $InstallMatch). User client must not receive these keys."
}

$p = Get-ScoutWow
[void][NativeWow]::ShowWindow($p.MainWindowHandle, 9)
[void][NativeWow]::SetForegroundWindow($p.MainWindowHandle)
Start-Sleep -Milliseconds 250
# Do not send ESC on the login screen — that quits Wow.exe.
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Start-Sleep -Milliseconds 150
$escaped = ($Text -replace '([+\^%~(){}\[\]])', '{$1}')
[System.Windows.Forms.SendKeys]::SendWait($escaped)
Start-Sleep -Milliseconds 80
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Start-Sleep -Milliseconds $WaitMs
Write-Host ("SENT pid={0} path={1}: {2}" -f $p.Id, $p.Path, $Text)
