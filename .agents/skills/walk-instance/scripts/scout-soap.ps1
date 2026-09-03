param(
  [Parameter(Mandatory = $true)][string]$Command
)
$ErrorActionPreference = "Stop"
$xmlPath = Join-Path $env:TEMP "ac-soap.xml"
$body = @"
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ns1="urn:AC">
  <SOAP-ENV:Body>
    <ns1:executeCommand>
      <command>$([System.Security.SecurityElement]::Escape($Command))</command>
    </ns1:executeCommand>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
"@
[System.IO.File]::WriteAllText($xmlPath, $body)
$raw = curl.exe -s -u ADMIN:password -H "Content-Type: text/xml; charset=utf-8" --data-binary "@$xmlPath" http://127.0.0.1:7878/
$raw
if ($Command -match '(?i)^\s*\.go(\s|xyz)') {
  Write-Warning ".go is Console::No over SOAP (matches .gobject). Type it in the scout client with scout-say.ps1."
}
