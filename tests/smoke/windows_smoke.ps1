# Launches a built softphonepro.exe with --provision, then drives the local automation API.
#   windows_smoke.ps1 -Exe <path\softphonepro.exe> -OutDir <dir> [-ExpectedVersion 1.2.3]
param(
  [Parameter(Mandatory)] [string] $Exe,
  [Parameter(Mandatory)] [string] $OutDir,
  [string] $ExpectedVersion = ''
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force $OutDir | Out-Null
$Exe = (Resolve-Path $Exe).Path

function Get-FreePort {
  $l = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
  $l.Start(); $p = $l.LocalEndpoint.Port; $l.Stop(); return $p
}
$port = Get-FreePort
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$token = -join ($bytes | ForEach-Object { $_.ToString('x2') })
$cfg = @{
  accounts = @(@{ username = 'smoke1'; password = 'smoke-pass'; domain = '127.0.0.1:5999'; transport = 'udp'; label = 'smoke' })
  settings = @{ automationEnabled = $true; automationPort = $port; automationToken = $token; stunServers = @(); dnd = $false }
}
$cfgPath = Join-Path $OutDir 'provision.json'
$cfg | ConvertTo-Json -Depth 6 | Set-Content -Encoding utf8 $cfgPath

$h = @{ Authorization = "Bearer $token" }
$base = "http://127.0.0.1:$port"
function Api($method, $path, $body = $null) {
  $a = @{ Uri = "$base$path"; Method = $method; Headers = $h; TimeoutSec = 5; UseBasicParsing = $true }
  if ($null -ne $body) { $a.Body = ($body | ConvertTo-Json -Compress); $a.ContentType = 'application/json' }
  return (Invoke-RestMethod @a)
}
function Check($cond, $msg) { if (-not $cond) { throw "ASSERT FAILED: $msg" } ; Write-Host "PASS: $msg" }

$startTime = Get-Date
$outLog = Join-Path $OutDir 'stdout.log'; $errLog = Join-Path $OutDir 'stderr.log'
$p = Start-Process -FilePath $Exe -ArgumentList @('--provision', "`"$cfgPath`"") -PassThru -RedirectStandardOutput $outLog -RedirectStandardError $errLog
try {
  $st = $null
  $deadline = (Get-Date).AddSeconds(60)
  while ((Get-Date) -lt $deadline) {
    if ($p.HasExited) { throw "app exited early with code $($p.ExitCode)" }
    try { $st = Api GET '/v1/status'; break } catch { Start-Sleep -Milliseconds 700 }
  }
  Check ($null -ne $st) 'automation API answered /v1/status within 60 s'
  $st | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $OutDir 'status.json')
  Check ($st.app -eq 'SoftphonePro') 'app name is SoftphonePro'
  if ($ExpectedVersion) {
    $want = ($ExpectedVersion -split '[-+]')[0]
    Check ("$($st.version)".StartsWith($want)) "version '$($st.version)' matches $want"
  } else { Check ([bool]$st.version) "version reported: $($st.version)" }

  $end = (Get-Date).AddSeconds(30)
  while ($st.engine.state -ne 'running' -and (Get-Date) -lt $end) { Start-Sleep -Milliseconds 700; $st = Api GET '/v1/status' }
  Check ($st.engine.state -eq 'running') "engine state is running (was $($st.engine.state) $($st.engine.error))"

  $acc = @($st.accounts | Where-Object { $_.username -eq 'smoke1' })
  Check ($acc.Count -ge 1) 'provisioned account smoke1 is listed'
  $end = (Get-Date).AddSeconds(30)
  while ($end -gt (Get-Date)) {
    $st = Api GET '/v1/status'; $acc = @($st.accounts | Where-Object { $_.username -eq 'smoke1' })
    if ($acc[0].regState -in 'failed', 'offline') { break }
    Start-Sleep 1
  }
  Write-Host "account regState=$($acc[0].regState) regCode=$($acc[0].regCode) error=$($acc[0].error)"
  Check ($acc[0].regState -in 'registering', 'failed', 'offline') 'account is not registered (no server) and the app stays alive'

  $null = Api POST '/v1/dnd' @{ enabled = $true }
  $st = Api GET '/v1/status'
  Check ($st.dnd -eq $true) 'POST /v1/dnd enabled -> status.dnd is true'
  $null = Api POST '/v1/dnd' @{ enabled = $false }
  $st = Api GET '/v1/status'
  Check ($st.dnd -eq $false) 'DND switched off again'
  Check (-not $p.HasExited) 'process still running after API exercise'
}
finally {
  if ($p -and -not $p.HasExited) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue; $p.WaitForExit(10000) | Out-Null }
}
$name = [IO.Path]::GetFileName($Exe)
$crashes = @(Get-WinEvent -FilterHashtable @{ LogName = 'Application'; ProviderName = 'Application Error'; StartTime = $startTime } -ErrorAction SilentlyContinue |
  Where-Object { $_.Message -like "*$name*" })
if ($crashes.Count) { $crashes | Format-List | Out-String | Set-Content (Join-Path $OutDir 'crash-events.txt'); throw "Application Error events for $name" }
Write-Host 'PASS: no crash events'
Write-Host "SMOKE OK ($Exe)"
