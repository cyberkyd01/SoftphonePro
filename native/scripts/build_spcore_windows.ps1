<#
.SYNOPSIS
  Build spcore.dll (Windows x64, MSVC, static CRT) against native/out/windows-x64 and copy it to
  packages/spcore_flutter/windows/prebuilt/.
.EXAMPLE
  pwsh -File native\scripts\build_spcore_windows.ps1 [-Clean] [-Jobs 8]
  Prerequisite: pwsh native\scripts\build_deps_windows.ps1
#>
param(
  [switch]$Clean,
  [int]$Jobs = [Environment]::ProcessorCount,
  [string]$BuildType = 'Release'
)
$ErrorActionPreference = 'Stop'
$Native  = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Repo    = (Resolve-Path (Join-Path $Native '..')).Path
$Prefix  = Join-Path $Native 'out\windows-x64'
$Build   = Join-Path $Native 'build\spcore-windows-x64'
$Dest    = Join-Path $Repo 'packages\spcore_flutter\windows\prebuilt'
$Src     = if ($env:SPC_CMAKE_SOURCE) { $env:SPC_CMAKE_SOURCE } else { $Native }

if (-not (Test-Path (Join-Path $Prefix 'spc_deps.cmake'))) { throw "dependency prefix $Prefix missing - run build_deps_windows.ps1 first" }
if (-not (Test-Path (Join-Path $Src 'CMakeLists.txt'))) { throw "native/CMakeLists.txt not found" }
if ($Clean -and (Test-Path $Build)) { Remove-Item -Recurse -Force $Build }

& cmake -S $Src -B $Build -G 'Visual Studio 17 2022' -A x64 `
  "-DSPC_DEPS_PREFIX=$Prefix" `
  '-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded' `
  '-DCMAKE_POLICY_DEFAULT_CMP0091=NEW'
if ($LASTEXITCODE -ne 0) { throw 'cmake configure failed' }
& cmake --build $Build --config $BuildType --parallel $Jobs
if ($LASTEXITCODE -ne 0) { throw 'cmake build failed' }

$dll = Get-ChildItem -Path $Build -Recurse -Filter spcore.dll | Where-Object { $_.FullName -match $BuildType } | Select-Object -First 1
if (-not $dll) { throw 'spcore.dll not found in build output' }

# Verify exports and that the CRT is not a dependency (static runtime).
$required = 'spc_api_version','spc_version_string','spc_init_dart_api','spc_init','spc_set_event_port',
            'spc_set_event_callback','spc_request','spc_request_sync','spc_free','spc_shutdown'
$dumpbin = Get-Command dumpbin.exe -ErrorAction SilentlyContinue
if (-not $dumpbin) {
  $vs = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath 2>$null
  if ($vs) { $dumpbin = Get-ChildItem "$vs\VC\Tools\MSVC" -Recurse -Filter dumpbin.exe -ErrorAction SilentlyContinue | Where-Object { $_.FullName -match 'Hostx64\\x64' } | Select-Object -First 1 }
}
if ($dumpbin) {
  $exe = if ($dumpbin.Source) { $dumpbin.Source } else { $dumpbin.FullName }
  $exports = & $exe /nologo /exports $dll.FullName | Out-String
  foreach ($s in $required) { if ($exports -notmatch "\b$s\b") { throw "spcore.dll does not export $s" } }
  $deps = & $exe /nologo /dependents $dll.FullName | Out-String
  if ($deps -match '(?i)vcruntime|msvcp|ucrtbased') { throw "spcore.dll depends on the dynamic CRT (all libs must be /MT):`n$deps" }
  Write-Host "Exports verified ($($required.Count) symbols)."
} else { Write-Warning 'dumpbin not found: exports not verified' }

New-Item -ItemType Directory -Force -Path $Dest | Out-Null
Copy-Item $dll.FullName (Join-Path $Dest 'spcore.dll') -Force
Write-Host "spcore.dll -> $Dest"
