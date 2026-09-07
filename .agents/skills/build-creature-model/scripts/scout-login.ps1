# Launch the scout Wow.exe (if not running) and log Walky in. Keys go only to the scout PID.
# Every SendWait is preceded by a foreground check: SendKeys types into whatever window has
# focus, so a lost focus race would otherwise type the account/password into the user's editor.
#
# Glue-screen notes (3.3.5a): SendKeys {TAB}/{BACKSPACE}/{END} do not move/edit the login
# fields, and mouse_event/SetCursorPos clicks do not change focus. What works:
#   1) SET accountName "SCOUT" in scout WTF\Config.wtf so the account box is pre-filled.
#   2) SendInput mouse MOVE|ABSOLUTE then LEFTDOWN (hold ~180ms) LEFTUP on the password box.
#   3) SendKeys the password, then {ENTER}. Never send {ESC} on this screen (it quits Wow.exe).
param([string]$Account = "SCOUT", [string]$Password = "password", [switch]$NoLaunch)
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms
if (-not ([System.Management.Automation.PSTypeName]'NativeWowL').Type) {
  Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class NativeWowL {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, IntPtr lpdwProcessId);
  [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
  [DllImport("user32.dll")] public static extern int GetSystemMetrics(int nIndex);
  [DllImport("user32.dll", SetLastError = true)] public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);
  public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
  [StructLayout(LayoutKind.Sequential)]
  public struct MOUSEINPUT {
    public int dx; public int dy; public uint mouseData; public uint dwFlags; public uint time; public IntPtr dwExtraInfo;
  }
  [StructLayout(LayoutKind.Explicit)]
  public struct INPUTUNION {
    [FieldOffset(0)] public MOUSEINPUT mi;
  }
  [StructLayout(LayoutKind.Sequential)]
  public struct INPUT {
    public uint type;
    public INPUTUNION u;
  }
  public static void AbsClick(int x, int y, int holdMs) {
    int sw = GetSystemMetrics(0);
    int sh = GetSystemMetrics(1);
    if (sw < 2) sw = 2;
    if (sh < 2) sh = 2;
    int ax = (int)((x * 65535.0) / (sw - 1));
    int ay = (int)((y * 65535.0) / (sh - 1));
    uint MOVEABS = 0x0001u | 0x8000u;
    INPUT[] m = new INPUT[1];
    m[0].type = 0;
    m[0].u.mi.dx = ax; m[0].u.mi.dy = ay; m[0].u.mi.dwFlags = MOVEABS;
    SendInput(1, m, Marshal.SizeOf(typeof(INPUT)));
    System.Threading.Thread.Sleep(80);
    INPUT[] d = new INPUT[1];
    d[0].type = 0;
    d[0].u.mi.dx = ax; d[0].u.mi.dy = ay; d[0].u.mi.dwFlags = MOVEABS | 0x0002u;
    SendInput(1, d, Marshal.SizeOf(typeof(INPUT)));
    System.Threading.Thread.Sleep(holdMs);
    INPUT[] u = new INPUT[1];
    u[0].type = 0;
    u[0].u.mi.dx = ax; u[0].u.mi.dy = ay; u[0].u.mi.dwFlags = MOVEABS | 0x0004u;
    SendInput(1, u, Marshal.SizeOf(typeof(INPUT)));
  }
}
"@
}

# Click at a point given as a fraction of the window rect (same frame as scout-capture PNGs).
function Click-Scout {
  param([IntPtr]$Hwnd, [double]$Fx, [double]$Fy, [int]$AfterMs = 300)
  if ([NativeWowL]::GetForegroundWindow() -ne $Hwnd) { throw "Focus left the scout window - not clicking." }
  $r = New-Object NativeWowL+RECT
  if (-not [NativeWowL]::GetWindowRect($Hwnd, [ref]$r)) { throw "GetWindowRect failed" }
  $x = [int]($r.Left + ($r.Right - $r.Left) * $Fx)
  $y = [int]($r.Top + ($r.Bottom - $r.Top) * $Fy)
  [NativeWowL]::AbsClick($x, $y, 180)
  Start-Sleep -Milliseconds $AfterMs
}
# Glue-screen layout (fractions of the 1040x807 windowed frame): password box.
$PASSWORD_BOX = @(0.673, 0.770)

function Enter-ScoutForeground {
  param([IntPtr]$Hwnd, [int]$Tries = 6)
  for ($i = 0; $i -lt $Tries; $i++) {
    [void][NativeWowL]::ShowWindow($Hwnd, 9)
    $fgThread = [NativeWowL]::GetWindowThreadProcessId([NativeWowL]::GetForegroundWindow(), [IntPtr]::Zero)
    $me = [NativeWowL]::GetCurrentThreadId()
    $attached = ($fgThread -ne 0) -and ($fgThread -ne $me) -and [NativeWowL]::AttachThreadInput($me, $fgThread, $true)
    try { [void][NativeWowL]::SetForegroundWindow($Hwnd) }
    finally { if ($attached) { [void][NativeWowL]::AttachThreadInput($me, $fgThread, $false) } }
    Start-Sleep -Milliseconds 300
    if ([NativeWowL]::GetForegroundWindow() -eq $Hwnd) { return }
  }
  throw "Scout window never became foreground - refusing to SendKeys (keys would leak into another app)."
}

function Send-Scout {
  param([IntPtr]$Hwnd, [string]$Keys, [int]$AfterMs = 0)
  if ([NativeWowL]::GetForegroundWindow() -ne $Hwnd) {
    throw "Focus left the scout window - aborting login sequence before keys leak."
  }
  [System.Windows.Forms.SendKeys]::SendWait($Keys)
  if ($AfterMs -gt 0) { Start-Sleep -Milliseconds $AfterMs }
}

$scoutRoot = "C:\dev\wow-335\scout"
$scoutExe = Join-Path $scoutRoot "Wow.exe"
$wtf = Join-Path $scoutRoot "WTF\Config.wtf"
if (Test-Path $wtf) {
  $cfg = Get-Content -LiteralPath $wtf
  if (-not ($cfg -match '^\s*SET\s+accountName\s+')) {
    $cfg = @("SET accountName `"$Account`"") + $cfg
    Set-Content -LiteralPath $wtf -Value $cfg -Encoding ASCII
    Write-Host "wrote SET accountName to Config.wtf"
  }
}

$p = Get-Process -Name Wow -ErrorAction SilentlyContinue | Where-Object { $_.Path -like '*wow-335\scout*' }
if (-not $p -and -not $NoLaunch) {
  $p = Start-Process -FilePath $scoutExe -WorkingDirectory $scoutRoot -PassThru
  Write-Host "launched scout pid $($p.Id)"
  Start-Sleep -Seconds 22
  $p = Get-Process -Id $p.Id
}
if (-not $p) { throw "scout not running" }
$hwnd = $p.MainWindowHandle
if ($hwnd -eq [IntPtr]::Zero) { throw "scout has no main window yet" }
Enter-ScoutForeground -Hwnd $hwnd
# Account box is pre-filled from Config.wtf. TAB/BACKSPACE do not work on glue;
# SendInput absolute click focuses the password box.
Click-Scout $hwnd $PASSWORD_BOX[0] $PASSWORD_BOX[1]
Send-Scout $hwnd $Password 200
Send-Scout $hwnd "{ENTER}"
Start-Sleep -Seconds 12
Enter-ScoutForeground -Hwnd $hwnd
Send-Scout $hwnd "{ENTER}"          # character select -> enter world (Walky preselected)
Start-Sleep -Seconds 9
Write-Host "login sequence sent to pid $($p.Id)"
