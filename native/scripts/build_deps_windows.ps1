<#
.SYNOPSIS
  Build PJSIP 2.17 + OpenSSL 3.5 + Opus + bcg729 static libraries for windows-x64 (MSVC, /MT).

.DESCRIPTION
  Output: native\out\windows-x64\   include\, lib\*.lib, spc_deps.cmake (imported target spc::deps)
  Designed for GitHub Actions windows-2022 (VS 2022 / v143, Strawberry Perl, CMake, Ninja and NASM
  are preinstalled; NASM is installed through Chocolatey if missing). Cannot be tested on macOS/Linux.

  * pjproject: official MSBuild solution projects (pjproject-vs14.sln -> Release-Static|x64, which is
    /MT = static CRT, so spcore.dll has no VC++ redistributable dependency). pjproject's CMake build
    is NOT used on MSVC (experimental, not supported there).
  * OpenSSL: built from the pinned tarball with perl + nasm + nmake (VC-WIN64A, no-shared, makefile
    patched /MD -> /MT). Alternative: -OpenSSL vcpkg uses `vcpkg install openssl:x64-windows-static`
    (static CRT, but the version is whatever the vcpkg checkout carries).
  * Opus / bcg729: CMake + Ninja, CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded.
  * Audio: WMME (pjmedia's WASAPI backend is UWP-only), ioqueue select, WebRTC AEC3 enabled.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File native\scripts\build_deps_windows.ps1 [-Clean] [-OpenSSL source|vcpkg]
#>
[CmdletBinding()]
param(
  [switch]$Clean,
  [ValidateSet('source','vcpkg')][string]$OpenSSL = 'source',
  [int]$Jobs = [Environment]::ProcessorCount
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Native    = Resolve-Path (Join-Path $ScriptDir '..') | Select-Object -ExpandProperty Path
$Target    = 'windows-x64'
$Out       = Join-Path $Native "out\$Target"
$Bld       = Join-Path $Native "build\$Target"
$DepsSrc   = Join-Path $Native 'deps\src'
$ConfigSite= Join-Path $Native 'config\config_site.h'
$Stamps    = Join-Path $Out '.stamps'
$T0 = Get-Date

function Log($m)  { Write-Host "[spc] $m" -ForegroundColor Cyan }
function Die($m)  { Write-Host "[spc] ERROR: $m" -ForegroundColor Red; exit 1 }
function Run {
  # Run a native command, fail on non-zero exit code.
  param([string]$Exe, [string[]]$Arguments)
  Log "> $Exe $($Arguments -join ' ')"
  & $Exe @Arguments
  if ($LASTEXITCODE -ne 0) { Die "'$Exe' failed with exit code $LASTEXITCODE" }
}

if ($Clean) { Log "-Clean: removing $Out and $Bld"; Remove-Item -Recurse -Force $Out, $Bld -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Force $Out, $Bld, $Stamps, $DepsSrc | Out-Null

# ------------------------------------------------------------------ pinned deps (shared with fetch_deps.sh)
$Deps = @{}
foreach ($line in Get-Content (Join-Path $ScriptDir 'fetch_deps.sh')) {
  if ($line -match '^DEP\|') {
    $f = $line.Split('|')   # DEP|name|version|file|sha256|url
    $Deps[$f[1]] = @{ Version=$f[2]; File=$f[3]; Sha=$f[4]; Url=$f[5] }
  }
}
foreach ($n in 'pjproject','openssl','opus','bcg729') { if (-not $Deps.ContainsKey($n)) { Die "dep $n missing in fetch_deps.sh" } }

function Fetch($name) {
  $d = $Deps[$name]; $dest = Join-Path $DepsSrc $d.File
  if (Test-Path $dest) {
    if ((Get-FileHash $dest -Algorithm SHA256).Hash.ToLower() -eq $d.Sha) { Log "fetch ok  $($d.File)"; return $dest }
    Log "hash mismatch for cached $($d.File); re-downloading"; Remove-Item -Force $dest
  }
  Log "fetch get $($d.File)"
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -Uri $d.Url -OutFile "$dest.part" -UseBasicParsing
  $got = (Get-FileHash "$dest.part" -Algorithm SHA256).Hash.ToLower()
  if ($got -ne $d.Sha) { Remove-Item -Force "$dest.part"; Die "SHA-256 mismatch for $($d.File): expected $($d.Sha) got $got" }
  Move-Item -Force "$dest.part" $dest
  return $dest
}

function Extract($name, $dest) {
  $archive = Fetch $name
  if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
  New-Item -ItemType Directory -Force $dest | Out-Null
  Run 'tar' @('-xzf', $archive, '-C', $dest, '--strip-components=1')   # bsdtar ships with Windows 10+
}

function StampOk($name, $key) { $f = Join-Path $Stamps $name; (Test-Path $f) -and ((Get-Content $f -Raw).Trim() -eq $key) }
function StampSet($name, $key) { Set-Content -Path (Join-Path $Stamps $name) -Value $key }

# ------------------------------------------------------------------ MSVC environment (vcvars64)
function Import-VcVars {
  if ($env:VSCMD_ARG_TGT_ARCH -eq 'x64') { return }
  $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
  if (-not (Test-Path $vswhere)) { Die 'vswhere.exe not found: Visual Studio 2022 Build Tools are required' }
  $vs = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
  if (-not $vs) { Die 'Visual Studio with the C++ x64 toolset not found' }
  $bat = Join-Path $vs 'VC\Auxiliary\Build\vcvars64.bat'
  Log "importing environment from $bat"
  cmd /c "`"$bat`" >nul && set" | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') { [Environment]::SetEnvironmentVariable($Matches[1], $Matches[2], 'Process') }
  }
}
Import-VcVars
foreach ($t in 'cmake','ninja','perl','msbuild') { if (-not (Get-Command $t -ErrorAction SilentlyContinue)) { Die "$t not found in PATH" } }

# ------------------------------------------------------------------ OpenSSL
function Build-OpenSSL {
  $key = "$($Deps.openssl.Version)|$OpenSSL"
  if ((StampOk 'openssl' $key) -and (Test-Path "$Out\lib\libssl.lib")) { Log 'openssl: up to date'; return }
  if ($OpenSSL -eq 'vcpkg') {
    $vcpkgRoot = if ($env:VCPKG_INSTALLATION_ROOT) { $env:VCPKG_INSTALLATION_ROOT } else { 'C:\vcpkg' }
    Run "$vcpkgRoot\vcpkg.exe" @('install','openssl:x64-windows-static','--x-install-root', (Join-Path $Bld 'vcpkg'))
    $inst = Join-Path $Bld 'vcpkg\x64-windows-static'
    New-Item -ItemType Directory -Force "$Out\include","$Out\lib" | Out-Null
    Copy-Item -Recurse -Force "$inst\include\openssl" "$Out\include\"
    Copy-Item -Force "$inst\lib\libssl.lib","$inst\lib\libcrypto.lib" "$Out\lib\"
    StampSet 'openssl' $key; return
  }
  if (-not (Get-Command nasm -ErrorAction SilentlyContinue)) {
    $nasmDir = 'C:\Program Files\NASM'
    if (-not (Test-Path "$nasmDir\nasm.exe")) {
      Log 'nasm missing: installing via Chocolatey'
      Run 'choco' @('install','nasm','-y','--no-progress')
    }
    $env:PATH = "$nasmDir;$env:PATH"
  }
  if (-not (Get-Command nasm -ErrorAction SilentlyContinue)) { Die 'nasm not found' }
  Log "openssl $($Deps.openssl.Version) (VC-WIN64A, static, /MT)"
  $src = Join-Path $Bld 'src\openssl'; Extract 'openssl' $src
  $inst = Join-Path $Bld 'openssl-install'
  if (Test-Path $inst) { Remove-Item -Recurse -Force $inst }
  Push-Location $src
  try {
    Run 'perl' @('Configure','VC-WIN64A','no-shared','no-tests','no-docs','no-apps','no-module','no-legacy','no-comp',
                 'no-ssl3','no-weak-ssl-ciphers','no-engine','no-dso',
                 "--prefix=$inst","--openssldir=$inst\ssl","--libdir=lib")
    # Static CRT: OpenSSL's VC targets hard-code /MD. Rewrite it in the generated makefile.
    $mk = Get-Content makefile -Raw
    $mk = [regex]::Replace($mk, '(?<![\w/])/MD(?![\w])', '/MT')
    Set-Content -Path makefile -Value $mk -NoNewline
    if ((Select-String -Path makefile -Pattern '(?<![\w/])/MD(?![\w])' -Quiet)) { Die 'failed to switch OpenSSL to /MT' }
    Run 'nmake' @('/nologo','build_libs')
    Run 'nmake' @('/nologo','install_dev')
  } finally { Pop-Location }
  New-Item -ItemType Directory -Force "$Out\include","$Out\lib" | Out-Null
  Copy-Item -Recurse -Force "$inst\include\openssl" "$Out\include\"
  Copy-Item -Force "$inst\lib\libssl.lib","$inst\lib\libcrypto.lib" "$Out\lib\"
  StampSet 'openssl' $key
}

# ------------------------------------------------------------------ CMake sub-projects (Opus, bcg729)
function Build-CMake($name, $extra) {
  $d = $Deps[$name]; $key = "$($d.Version)|static-crt-v2"
  $lib = if ($name -eq 'opus') { 'opus.lib' } else { 'bcg729.lib' }
  if ((StampOk $name $key) -and (Test-Path "$Out\lib\$lib")) { Log "${name}: up to date"; return }
  Log "$name $($d.Version)"
  $src = Join-Path $Bld "src\$name"; Extract $name $src
  $b = Join-Path $Bld $name; if (Test-Path $b) { Remove-Item -Recurse -Force $b }
  $args = @('-S',$src,'-B',$b,'-G','Ninja','-DCMAKE_BUILD_TYPE=Release',"-DCMAKE_INSTALL_PREFIX=$Out",
            '-DCMAKE_INSTALL_LIBDIR=lib','-DBUILD_SHARED_LIBS=OFF','-DCMAKE_POLICY_VERSION_MINIMUM=3.5',
            '-DCMAKE_POLICY_DEFAULT_CMP0091=NEW','-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded') + $extra
  Run 'cmake' $args
  Run 'cmake' @('--build',$b,'--parallel',"$Jobs")
  Run 'cmake' @('--install',$b)
  if (-not (Test-Path "$Out\lib\$lib")) {
    # some projects name the archive differently (e.g. libbcg729.lib / bcg729-static.lib): normalise
    $alt = Get-ChildItem "$Out\lib" -Filter '*.lib' | Where-Object { $_.Name -match "^(lib)?$name" } | Select-Object -First 1
    if (-not $alt) { Die "$lib not installed" }
    Copy-Item $alt.FullName "$Out\lib\$lib"
  }
  StampSet $name $key
}

# ------------------------------------------------------------------ pjproject (MSBuild)
$PjLibs = @('pjlib','pjlib-util','pjnath','pjmedia','pjmedia-codec','pjmedia-audiodev','pjmedia-videodev',
            'pjsip-core','pjsip-simple','pjsip-ua','pjsua-lib')   # installed names (vcxproj TargetName prefix)
$PjProjects = @(
  'pjlib\build\pjlib.vcxproj','pjlib-util\build\pjlib_util.vcxproj','pjnath\build\pjnath.vcxproj',
  'pjmedia\build\pjmedia.vcxproj','pjmedia\build\pjmedia_codec.vcxproj','pjmedia\build\pjmedia_audiodev.vcxproj',
  'pjmedia\build\pjmedia_videodev.vcxproj','pjsip\build\pjsip_core.vcxproj','pjsip\build\pjsip_simple.vcxproj',
  'pjsip\build\pjsip_ua.vcxproj','pjsip\build\pjsua_lib.vcxproj',
  'third_party\build\srtp\libsrtp.vcxproj','third_party\build\resample\libresample.vcxproj',
  'third_party\build\speex\libspeex.vcxproj','third_party\build\gsm\libgsmcodec.vcxproj',
  'third_party\build\ilbc\libilbccodec.vcxproj','third_party\build\g7221\libg7221codec.vcxproj',
  'third_party\build\webrtc_aec3\libwebrtc_aec3.vcxproj'
)

function Build-PjProject {
  $cs = (Get-FileHash $ConfigSite -Algorithm SHA256).Hash.ToLower()
  $key = "$($Deps.pjproject.Version)|$cs|msbuild-v143-Release-Static-srtpossl-v2"
  if ((StampOk 'pjproject' $key) -and (Test-Path "$Out\lib\pjsua-lib.lib")) { Log 'pjproject: up to date'; return }
  Log "pjproject $($Deps.pjproject.Version) (MSBuild, Release-Static|x64)"
  $src = Join-Path $Bld 'src\pjproject'; Extract 'pjproject' $src

  # The project's config_site.h is authoritative. We only APPEND a trailer to the build-tree copy that
  # switches on what the .sln build cannot know (codecs found via INCLUDE/LIB, AEC3).
  $dst = Join-Path $src 'pjlib\include\pj\config_site.h'
  Copy-Item -Force $ConfigSite $dst
  $trailer = @'

/* ---- appended by native/scripts/build_deps_windows.ps1 (not part of native/config/config_site.h) ---- */
#ifndef PJMEDIA_HAS_OPUS_CODEC
#  define PJMEDIA_HAS_OPUS_CODEC 1
#endif
#ifndef PJMEDIA_CODEC_OPUS_LIB_NAME
#  define PJMEDIA_CODEC_OPUS_LIB_NAME "opus.lib"
#endif
#ifndef PJMEDIA_HAS_BCG729
#  define PJMEDIA_HAS_BCG729 1
#endif
#ifndef PJMEDIA_HAS_WEBRTC_AEC3
#  define PJMEDIA_HAS_WEBRTC_AEC3 1
#endif
/* bcg729 is linked statically: without this its headers declare the API __declspec(dllimport) and
   pjmedia-codec fails with unresolved __imp_initBcg729EncoderChannel. */
#ifndef BCG729_STATIC
#  define BCG729_STATIC 1
#endif
#ifndef PJMEDIA_AUDIO_DEV_HAS_WMME
#  define PJMEDIA_AUDIO_DEV_HAS_WMME 1
#endif
#ifndef PJMEDIA_AUDIO_DEV_HAS_WASAPI
#  define PJMEDIA_AUDIO_DEV_HAS_WASAPI 0
#endif
'@
  Add-Content -Path $dst -Value $trailer

  # libsrtp: the stock project builds its own OpenSSL-less crypto, which has no AES-GCM (-> unresolved
  # srtp_aes_gcm_128/256 from pjmedia). Switch Release-Static|x64 to the OpenSSL backend
  # (aes_gcm_ossl / aes_icm_ossl / hmac_ossl, defines OPENSSL + GCM) so AEAD_AES_128/256_GCM work here too.
  $srtpProj = Join-Path $src 'third_party\build\srtp\libsrtp.vcxproj'
  $x = Get-Content $srtpProj -Raw
  $cond = '''$(Configuration)|$(Platform)''==''Release-Static|x64'''
  $condRx = [regex]::Escape($cond)
  foreach ($n in 'aes_gcm_ossl','aes_icm_ossl','hmac_ossl') {
    $rx = '(?s)(<ClCompile Include="[^"]*\\' + $n + '\.c">)(.*?)(</ClCompile>)'
    if ($x -notmatch $rx) { Die "libsrtp.vcxproj: $n.c entry not found" }
    $x = [regex]::Replace($x, $rx, {
      param($m)
      $m.Groups[1].Value + [regex]::Replace($m.Groups[2].Value, '(?m)^\s*<ExcludedFromBuild Condition="' + $condRx + '">true</ExcludedFromBuild>\r?\n', '') + $m.Groups[3].Value
    })
  }
  foreach ($n in 'aes_icm','hmac') {
    $rx = '<ClCompile Include="([^"]*\\' + $n + '\.c)" />'
    if ($x -notmatch $rx) { Die "libsrtp.vcxproj: $n.c entry not found" }
    $x = [regex]::Replace($x, $rx, ('<ClCompile Include="$1"><ExcludedFromBuild Condition="' + $cond + '">true</ExcludedFromBuild></ClCompile>'))
  }
  $rxDef = '(?s)(<ItemDefinitionGroup Condition="' + $condRx + '">.*?<PreprocessorDefinitions>)(_LIB;HAVE_CONFIG_H;)'
  if ($x -notmatch $rxDef) { Die 'libsrtp.vcxproj: Release-Static|x64 definitions not found' }
  $x = [regex]::Replace($x, $rxDef, '${1}_LIB;HAVE_CONFIG_H;OPENSSL;GCM;')
  Set-Content -Path $srtpProj -Value $x -NoNewline

  # bcg729.c / opus.c are compiled by pjmedia_codec.vcxproj: it needs the headers, found via INCLUDE.
  $env:INCLUDE = "$Out\include;$Out\include\opus;$env:INCLUDE"
  $env:LIB     = "$Out\lib;$env:LIB"
  $msb = @('/nologo','/m',"/maxcpucount:$Jobs",'/p:Configuration=Release-Static','/p:Platform=x64',
           '/p:PlatformToolset=v143','/p:UseEnv=true','/v:minimal','/p:WarningLevel=1')
  foreach ($p in $PjProjects) {
    $proj = Join-Path $src $p
    if (-not (Test-Path $proj)) { Die "missing project $p" }
    Run 'msbuild' (@($proj) + $msb)
  }

  # Collect headers + libraries into the prefix with normalised names (pjlib.lib, pjsua-lib.lib, ...).
  New-Item -ItemType Directory -Force "$Out\include","$Out\lib" | Out-Null
  foreach ($inc in 'pjlib','pjlib-util','pjnath','pjmedia','pjsip') {
    Copy-Item -Recurse -Force "$src\$inc\include\*" "$Out\include\"
  }
  Copy-Item -Force $dst "$Out\include\pj\config_site.h"     # the exact config_site.h the libs were built with
  $found = @{}
  Get-ChildItem -Recurse -Path $src -Filter '*-x86_64-x64-vc14-Release-Static.lib' | ForEach-Object {
    $base = $_.Name -replace '-x86_64-x64-vc14-Release-Static\.lib$',''
    if ($base -match '_test$|^pjsua$') { return }
    $found[$base] = $_.FullName
  }
  foreach ($kv in $found.GetEnumerator()) { Copy-Item -Force $kv.Value (Join-Path $Out "lib\$($kv.Key).lib") }
  foreach ($l in $PjLibs) { if (-not (Test-Path "$Out\lib\$l.lib")) { Die "expected library $l.lib was not produced (found: $($found.Keys -join ', '))" } }
  StampSet 'pjproject' $key
}

# ------------------------------------------------------------------ spc_deps.cmake
function Write-DepsCmake {
  $libs = New-Object System.Collections.Generic.List[string]
  foreach ($l in $PjLibs) { $libs.Add("lib/$l.lib") }
  # third-party libs: names differ per vcxproj (libsrtp, libresample, libspeex, libgsmcodec, ...)
  foreach ($f in Get-ChildItem "$Out\lib" -Filter 'lib*.lib' | Sort-Object Name) {
    if ($f.Name -in 'libssl.lib','libcrypto.lib') { continue }
    $libs.Add("lib/$($f.Name)")
  }
  foreach ($l in 'opus.lib','bcg729.lib','libssl.lib','libcrypto.lib') {
    if (-not (Test-Path "$Out\lib\$l")) { Die "missing $l" }
    $libs.Add("lib/$l")
  }
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.AppendLine("# Generated by native/scripts/build_deps_windows.ps1 for target '$Target' ($(Get-Date -Format s))")
  [void]$sb.AppendLine('# Usage: include(<prefix>/spc_deps.cmake); target_link_libraries(spcore PRIVATE spc::deps)')
  [void]$sb.AppendLine('# All archives are built with the static CRT (/MT): set CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded in spcore.')
  [void]$sb.AppendLine('if(TARGET spc::deps)'); [void]$sb.AppendLine('  return()'); [void]$sb.AppendLine('endif()')
  [void]$sb.AppendLine('get_filename_component(SPC_DEPS_PREFIX "${CMAKE_CURRENT_LIST_DIR}" ABSOLUTE)')
  [void]$sb.AppendLine("set(SPC_DEPS_TARGET `"$Target`")")
  [void]$sb.AppendLine('set(_spc_static_libs')
  foreach ($l in ($libs | Select-Object -Unique)) { [void]$sb.AppendLine("  `"`${SPC_DEPS_PREFIX}/$l`"") }
  [void]$sb.AppendLine(')')
  [void]$sb.AppendLine('add_library(spc::deps INTERFACE IMPORTED GLOBAL)')
  [void]$sb.AppendLine('target_include_directories(spc::deps INTERFACE "${SPC_DEPS_PREFIX}/include")')
  [void]$sb.AppendLine('# macros appended to config_site.h by the build (also present in <prefix>/include/pj/config_site.h)')
  [void]$sb.AppendLine('target_compile_definitions(spc::deps INTERFACE PJMEDIA_HAS_OPUS_CODEC=1 PJMEDIA_HAS_BCG729=1 PJMEDIA_HAS_WEBRTC_AEC3=1)')
  [void]$sb.AppendLine('target_link_libraries(spc::deps INTERFACE ${_spc_static_libs}')
  [void]$sb.AppendLine('  ws2_32 winmm iphlpapi ole32 crypt32 secur32 avrt ksuser uuid user32 advapi32 gdi32 bcrypt mswsock)')
  [void]$sb.AppendLine('unset(_spc_static_libs)')
  Set-Content -Path "$Out\spc_deps.cmake" -Value $sb.ToString()
  Log "wrote $Out\spc_deps.cmake"
}

Build-OpenSSL
Build-CMake 'opus'   @('-DOPUS_BUILD_SHARED_LIBRARY=OFF','-DOPUS_BUILD_PROGRAMS=OFF','-DOPUS_BUILD_TESTING=OFF','-DOPUS_STATIC_RUNTIME=ON')
Build-CMake 'bcg729' @('-DENABLE_SHARED=NO','-DENABLE_STATIC=YES','-DENABLE_UNIT_TESTS=NO','-DENABLE_STRICT=NO')
Build-PjProject
Write-DepsCmake

Write-Host ''
Write-Host '==================== SUMMARY ===================='
Write-Host "target   : $Target"
Write-Host "prefix   : $Out"
Get-ChildItem "$Out\lib" -Filter '*.lib' | ForEach-Object { '  {0,-34} {1,8:N0} KB' -f $_.Name, ($_.Length/1KB) }
Write-Host "entry    : include($Out\spc_deps.cmake)"
Write-Host ("elapsed  : {0:N0}s" -f ((Get-Date) - $T0).TotalSeconds)
Write-Host '================================================='
