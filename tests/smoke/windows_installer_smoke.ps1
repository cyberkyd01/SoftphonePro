# Silent-installs the Inno Setup installer, checks files + URL handler registry, runs the installed
# app through windows_smoke.ps1, then uninstalls and checks cleanup.
param(
  [Parameter(Mandatory)] [string] $Installer,
  [Parameter(Mandatory)] [string] $OutDir,
  [string] $ExpectedVersion = ''
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force $OutDir | Out-Null
$Installer = (Resolve-Path $Installer).Path
$tmp = if ($env:RUNNER_TEMP) { $env:RUNNER_TEMP } else { $env:TEMP }
$dir = Join-Path $tmp 'SoftphoneProSmokeInstall'
function Check($cond, $msg) { if (-not $cond) { throw "ASSERT FAILED: $msg" } ; Write-Host "PASS: $msg" }

$inst = Start-Process $Installer -ArgumentList @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/CURRENTUSER', "/DIR=`"$dir`"", "/LOG=`"$OutDir\install.log`"") -Wait -PassThru
Check ($inst.ExitCode -eq 0) "installer exit code 0 (was $($inst.ExitCode))"
$exe = Join-Path $dir 'softphonepro.exe'
Check (Test-Path $exe) 'softphonepro.exe installed'
Check (Test-Path (Join-Path $dir 'spcore.dll')) 'spcore.dll installed'
Check (Test-Path (Join-Path $dir 'data\app.so')) 'data\app.so installed'
Check (Test-Path (Join-Path $dir 'unins000.exe')) 'uninstaller installed'

foreach ($s in 'sip', 'sips', 'tel', 'callto', 'softphonepro') {
  $v = (Get-ItemProperty "HKCU:\Software\Classes\$s\shell\open\command").'(default)'
  Write-Host "$s -> $v"
  Check ($v -like "*$exe*") "protocol '$s' command points to the installed exe"
}

& (Join-Path $PSScriptRoot 'windows_smoke.ps1') -Exe $exe -OutDir (Join-Path $OutDir 'installed-run') -ExpectedVersion $ExpectedVersion

$un = Start-Process (Join-Path $dir 'unins000.exe') -ArgumentList @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART') -Wait -PassThru
Check ($un.ExitCode -eq 0) 'uninstaller exit code 0'
for ($i = 0; $i -lt 20 -and (Test-Path $exe); $i++) { Start-Sleep 1 }
Check (-not (Test-Path $exe)) 'installed exe removed'
foreach ($s in 'sip', 'sips', 'tel', 'callto', 'softphonepro') {
  Check (-not (Test-Path "HKCU:\Software\Classes\$s")) "registry key for '$s' removed"
}
Write-Host 'INSTALLER SMOKE OK'
