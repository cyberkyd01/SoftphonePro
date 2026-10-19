#!/usr/bin/env bash
# Shared helpers for the native dependency build scripts. Source, don't run.
#
# Contract of a build_deps_<platform>.sh script:
#   source common.sh
#   spc_init <target-name> "$@"        # parses --clean / -j N, sets paths
#   ...set the SPC_* platform variables (see below)...
#   spc_build_all                      # openssl, opus, bcg729, [oboe], pjproject, spc_deps.cmake
#
# Platform variables (bash 3.2 compatible arrays):
#   SPC_CMAKE_PLATFORM_ARGS   extra cmake args for EVERY cmake sub-build (toolchain, arch, ...)
#   SPC_OPENSSL_TARGET        `Configure` target (darwin64-arm64-cc, linux-x86_64, android-arm64, ...)
#   SPC_OPENSSL_ARGS          extra Configure args (cflags etc.)
#   SPC_PJ_CMAKE_ARGS         extra cmake args for pjproject only
#   SPC_WITH_OBOE=1           build Oboe and enable pjmedia's Oboe backend (Android)
#   SPC_SYSTEM_LIBS           CMake link items appended to spc::deps (e.g. "m;pthread" / "-framework Foo")
#   SPC_LINK_GROUP=1          wrap static libs in a --start-group/--end-group (ELF linkers)
#   SPC_LINK_OPTIONS          extra INTERFACE_LINK_OPTIONS (e.g. -Wl,-z,max-page-size=16384)

# shellcheck shell=bash
set -euo pipefail

SPC_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPC_NATIVE_DIR="$(cd "$SPC_SCRIPT_DIR/.." && pwd)"
SPC_REPO_DIR="$(cd "$SPC_NATIVE_DIR/.." && pwd)"
SPC_DEPS_SRC="${SPC_DEPS_SRC:-$SPC_NATIVE_DIR/deps/src}"
SPC_CONFIG_SITE="${SPC_CONFIG_SITE:-$SPC_NATIVE_DIR/config/config_site.h}"

# Pinned versions (hashes live in fetch_deps.sh).
PJ_VER=2.17
OPENSSL_VER=3.5.9
OPUS_VER=1.6.1
BCG729_VER=1.1.2
OBOE_VER=1.11.0

# Bundled WebRTC AEC / AEC3: enabled everywhere except Apple (pjproject's CMake does not offer them there).
# NOTE pjproject 2.17's CMake only defines PJMEDIA_HAS_LIBWEBRTC / PJMEDIA_HAS_LIBWEBRTC_AEC3, but the
# sources test PJMEDIA_HAS_WEBRTC_AEC / PJMEDIA_HAS_WEBRTC_AEC3 (default 0) -> the AEC code would silently
# be compiled out. We therefore also define the macros the sources really use (build + spc::deps).
: "${SPC_WEBRTC_AEC:=1}"

: "${SPC_JOBS:=$( (sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4) | head -1)}"

log()  { printf '\033[1;34m[spc]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[spc] WARNING:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[spc] ERROR:\033[0m %s\n' "$*" >&2; exit 1; }

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
  else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

SPC_CLEAN=0
spc_init() {
  SPC_TARGET="$1"; shift
  while [ $# -gt 0 ]; do
    case "$1" in
      --clean)  SPC_CLEAN=1 ;;
      -j|--jobs) shift; SPC_JOBS="$1" ;;
      -h|--help) sed -n '2,12p' "$0" 2>/dev/null || true; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
    shift
  done
  SPC_OUT="${SPC_OUT_ROOT:-$SPC_NATIVE_DIR/out}/$SPC_TARGET"
  SPC_BLD="${SPC_BUILD_ROOT:-$SPC_NATIVE_DIR/build}/$SPC_TARGET"
  SPC_STAMPS="$SPC_OUT/.stamps"
  SPC_T0=$(date +%s)
  if [ "$SPC_CLEAN" = 1 ]; then
    log "--clean: removing $SPC_OUT and $SPC_BLD"
    rm -rf "$SPC_OUT" "$SPC_BLD"
  fi
  mkdir -p "$SPC_OUT" "$SPC_BLD" "$SPC_STAMPS"
  [ -f "$SPC_CONFIG_SITE" ] || die "missing $SPC_CONFIG_SITE"
  command -v cmake >/dev/null || die "cmake not found"
  command -v ninja >/dev/null || die "ninja not found"
  # shellcheck source=fetch_deps.sh
  source "$SPC_SCRIPT_DIR/fetch_deps.sh"
  log "target=$SPC_TARGET jobs=$SPC_JOBS out=$SPC_OUT"
}

spc_fetch() {
  bash "$SPC_SCRIPT_DIR/fetch_deps.sh" "$@" >/dev/null
}

# stamp helpers: a component is skipped when its stamp (version + extra key) matches.
_stamp_file() { echo "$SPC_STAMPS/$1"; }
spc_stamp_ok() { [ -f "$(_stamp_file "$1")" ] && [ "$(cat "$(_stamp_file "$1")")" = "$2" ]; }
spc_stamp_set() { echo "$2" > "$(_stamp_file "$1")"; }

# spc_extract <archive-basename> <dest-dir>  -> extracts with the top dir stripped
spc_extract() {
  local archive="$SPC_DEPS_SRC/$1" dest="$2"
  [ -f "$archive" ] || die "missing $archive (run fetch_deps.sh)"
  rm -rf "$dest"; mkdir -p "$dest"
  tar -xzf "$archive" -C "$dest" --strip-components=1
}

# Run cmake configure+build+install for a project.
#   spc_cmake <src> <build-dir> [cmake args...]
spc_cmake() {
  local src="$1" bld="$2"; shift 2
  # Keep Homebrew/MacPorts prefixes out of find_package/find_library: they contain OpenSSL, Opus,
  # etc. of the wrong version/architecture (pjproject's srtp even probes OpenSSL via CONFIG mode).
  local ignore=()
  if [ "$(uname -s)" = Darwin ]; then ignore=("-DCMAKE_IGNORE_PREFIX_PATH=/opt/homebrew;/usr/local;/opt/local"); fi
  mkdir -p "$SPC_BLD/empty-pkgconfig"
  PKG_CONFIG_LIBDIR="$SPC_BLD/empty-pkgconfig" PKG_CONFIG_PATH="" \
  cmake -S "$src" -B "$bld" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$SPC_OUT" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_PREFIX_PATH="$SPC_OUT" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    ${ignore[@]+"${ignore[@]}"} \
    ${SPC_CMAKE_PLATFORM_ARGS[@]+"${SPC_CMAKE_PLATFORM_ARGS[@]}"} \
    "$@"
  cmake --build "$bld" --parallel "$SPC_JOBS"
  cmake --install "$bld"
}

# ---------------------------------------------------------------- OpenSSL
# OpenSSL's makefiles cannot cope with spaces in paths, and this repo may live
# in one ("Claude Projects"), so OpenSSL is built in a space-free temp dir and
# its install tree is copied into the prefix.
spc_build_openssl() {
  local key="$OPENSSL_VER|$SPC_OPENSSL_TARGET|${SPC_OPENSSL_ARGS[*]-}"
  if spc_stamp_ok openssl "$key" && [ -f "$SPC_OUT/lib/libssl.a" ]; then log "openssl: up to date"; return; fi
  log "openssl $OPENSSL_VER ($SPC_OPENSSL_TARGET)"
  spc_fetch openssl
  local work; work="$(mktemp -d "${TMPDIR:-/tmp}/spc-openssl.XXXXXX")"
  work="$(cd "$work" && pwd -P)"
  case "$work" in *" "*) die "temp dir has spaces: $work (set TMPDIR)";; esac
  spc_extract "openssl-$OPENSSL_VER.tar.gz" "$work/src"
  mkdir -p "$work/build" "$work/inst"
  (
    cd "$work/build"
    perl "$work/src/Configure" "$SPC_OPENSSL_TARGET" \
      --prefix="$work/inst" --openssldir=/usr/local/ssl --libdir=lib \
      no-shared no-tests no-docs no-apps no-module no-legacy no-comp \
      no-ssl3 no-weak-ssl-ciphers no-afalgeng no-engine no-dso \
      ${SPC_OPENSSL_ARGS[@]+"${SPC_OPENSSL_ARGS[@]}"}
    make -j"$SPC_JOBS" build_libs
    make install_dev
  )
  mkdir -p "$SPC_OUT/include" "$SPC_OUT/lib"
  cp -R "$work/inst/include/openssl" "$SPC_OUT/include/"
  cp -p "$work/inst/lib/libssl.a" "$work/inst/lib/libcrypto.a" "$SPC_OUT/lib/"
  rm -rf "$work"
  spc_stamp_set openssl "$key"
}

# ---------------------------------------------------------------- Opus
spc_build_opus() {
  local key="$OPUS_VER|${SPC_CMAKE_PLATFORM_ARGS[*]-}"
  if spc_stamp_ok opus "$key" && [ -f "$SPC_OUT/lib/libopus.a" ]; then log "opus: up to date"; return; fi
  log "opus $OPUS_VER"
  spc_fetch opus
  spc_extract "opus-$OPUS_VER.tar.gz" "$SPC_BLD/src/opus"
  spc_cmake "$SPC_BLD/src/opus" "$SPC_BLD/opus" \
    -DOPUS_BUILD_SHARED_LIBRARY=OFF -DOPUS_BUILD_PROGRAMS=OFF -DOPUS_BUILD_TESTING=OFF \
    -DOPUS_INSTALL_PKG_CONFIG_MODULE=OFF -DOPUS_INSTALL_CMAKE_CONFIG_MODULE=ON \
    ${SPC_OPUS_ARGS[@]+"${SPC_OPUS_ARGS[@]}"}
  spc_stamp_set opus "$key"
}

# ---------------------------------------------------------------- bcg729
spc_build_bcg729() {
  local key="$BCG729_VER|${SPC_CMAKE_PLATFORM_ARGS[*]-}"
  if spc_stamp_ok bcg729 "$key" && [ -f "$SPC_OUT/lib/libbcg729.a" ]; then log "bcg729: up to date"; return; fi
  log "bcg729 $BCG729_VER"
  spc_fetch bcg729
  spc_extract "bcg729-$BCG729_VER.tar.gz" "$SPC_BLD/src/bcg729"
  spc_cmake "$SPC_BLD/src/bcg729" "$SPC_BLD/bcg729" \
    -DENABLE_SHARED=NO -DENABLE_STATIC=YES -DENABLE_UNIT_TESTS=NO -DENABLE_STRICT=NO
  # bcg729 may install into lib/ or lib64/ depending on its own GNUInstallDirs use
  [ -f "$SPC_OUT/lib/libbcg729.a" ] || die "bcg729: libbcg729.a not installed in $SPC_OUT/lib"
  spc_stamp_set bcg729 "$key"
}

# ---------------------------------------------------------------- Oboe (Android)
spc_build_oboe() {
  local key="$OBOE_VER|${SPC_CMAKE_PLATFORM_ARGS[*]-}"
  if spc_stamp_ok oboe "$key" && [ -f "$SPC_OUT/lib/liboboe.a" ]; then log "oboe: up to date"; return; fi
  log "oboe $OBOE_VER"
  spc_fetch oboe
  spc_extract "oboe-$OBOE_VER.tar.gz" "$SPC_BLD/src/oboe"
  cmake -S "$SPC_BLD/src/oboe" -B "$SPC_BLD/oboe" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    ${SPC_CMAKE_PLATFORM_ARGS[@]+"${SPC_CMAKE_PLATFORM_ARGS[@]}"}
  cmake --build "$SPC_BLD/oboe" --parallel "$SPC_JOBS" --target oboe
  local a; a="$(find "$SPC_BLD/oboe" -name 'liboboe.a' | head -1)"
  [ -n "$a" ] || die "oboe: liboboe.a not produced"
  mkdir -p "$SPC_OUT/lib" "$SPC_OUT/include"
  cp -p "$a" "$SPC_OUT/lib/liboboe.a"
  rm -rf "$SPC_OUT/include/oboe"
  cp -R "$SPC_BLD/src/oboe/include/oboe" "$SPC_OUT/include/oboe"
  spc_stamp_set oboe "$key"
}

# ---------------------------------------------------------------- SpeexDSP shim
# pjproject's CMake only enables Speex AEC if a "speexdsp" library + header can be found, although
# the AEC code (mdf.c) is part of its BUNDLED libspeex. For platforms without bundled WebRTC AEC
# (Apple) we install an empty libspeexdsp.a and a placeholder speex/speexdsp_types.h so that
# FindSpeexDSP succeeds; the real symbols come from the bundled libspeex.a (in spc_deps.cmake).
spc_build_speexdsp_shim() {
  [ -f "$SPC_OUT/lib/libspeexdsp.a" ] && [ -f "$SPC_OUT/include/speex/speexdsp_types.h" ] && return 0
  local d="$SPC_BLD/speexdsp-shim"
  rm -rf "$d"; mkdir -p "$d"
  cat > "$d/stub.c" <<'EOT'
/* intentionally (almost) empty: Speex AEC symbols live in the bundled libspeex */
int spc_speexdsp_shim_marker(void) { return 0; }
EOT
  cat > "$d/CMakeLists.txt" <<'EOT'
cmake_minimum_required(VERSION 3.20)
project(speexdsp_shim C)
add_library(speexdsp STATIC stub.c)
install(TARGETS speexdsp ARCHIVE DESTINATION lib)
EOT
  spc_cmake "$d" "$d/build"
  mkdir -p "$SPC_OUT/include/speex"
  echo '/* placeholder so pjproject CMake finds "SpeexDSP"; see native/scripts/common.sh */' \
    > "$SPC_OUT/include/speex/speexdsp_types.h"
}

# ---------------------------------------------------------------- pjproject
spc_build_pjproject() {
  local cs_hash; cs_hash="$(sha256_of "$SPC_CONFIG_SITE")"
  local key="$PJ_VER|$cs_hash|${SPC_PJ_CMAKE_ARGS[*]-}|${SPC_CMAKE_PLATFORM_ARGS[*]-}|oboe=${SPC_WITH_OBOE:-0}|aa=${SPC_ANDROID_AUDIO:-}|spx=${SPC_SPEEX_AEC_SHIM:-0}|webrtc=${SPC_WEBRTC_AEC:-1}|${SPC_WEBRTC_DEFS[*]-}|flags-v2"
  if spc_stamp_ok pjproject "$key" && [ -f "$SPC_OUT/lib/cmake/Pj/PjConfig.cmake" ]; then log "pjproject: up to date"; return; fi
  log "pjproject $PJ_VER (CMake build)"
  spc_fetch pjproject
  local src="$SPC_BLD/src/pjproject"
  # pjproject's FindOPUS/FindBCG729 take extra cflags from pkg-config (it would find Homebrew's
  # opus, and a .pc under a prefix with spaces is split into bogus compiler arguments). We pass
  # all paths explicitly, and spc_cmake makes pkg-config see an empty database; no .pc files
  # are left in the prefix either.
  rm -rf "$SPC_OUT/lib/pkgconfig" "$SPC_BLD/pjproject"
  spc_extract "pjproject-$PJ_VER.tar.gz" "$src"
  # The project's config_site.h is authoritative; never edit it here.
  cp "$SPC_CONFIG_SITE" "$src/pjlib/include/pj/config_site.h"

  if [ "${SPC_ANDROID_AUDIO:-}" = opensl ]; then
    # pjproject's CMake has no OpenSL ES backend (opensl_dev.c is not in its source list and the
    # compile definition is hard-wired to 0). Patch the EXTRACTED build-tree copy (never the repo).
    local cm="$src/pjmedia/CMakeLists.txt"
    grep -q 'PJMEDIA_AUDIO_DEV_HAS_OPENSL=0' "$cm" && grep -q 'src/pjmedia-audiodev/oboe_dev.cpp' "$cm" \
      || die "pjmedia/CMakeLists.txt layout changed; cannot enable OpenSL ES"
    perl -0pi -e 's#PJMEDIA_AUDIO_DEV_HAS_OPENSL=0#PJMEDIA_AUDIO_DEV_HAS_OPENSL=1#; s#(  src/pjmedia-audiodev/oboe_dev\.cpp\n)#$1  src/pjmedia-audiodev/opensl_dev.c\n#' "$cm"
    grep -q 'opensl_dev.c' "$cm" || die "OpenSL ES patch failed"
    # opensl_dev.c calls opensl_to_pj_error() before defining it (implicit declaration = hard error in
    # clang >= 16): add the missing prototype.
    perl -0pi -e 's|(#include <SLES/OpenSLES\.h>\n)|$1pj_status_t opensl_to_pj_error(SLresult code);\n|' "$src/pjmedia/src/pjmedia-audiodev/opensl_dev.c"
    grep -q '^pj_status_t opensl_to_pj_error(SLresult code);' "$src/pjmedia/src/pjmedia-audiodev/opensl_dev.c" || die "OpenSL ES prototype patch failed"
  fi
  local pj_defs=()
  if [ "${SPC_WEBRTC_AEC:-1}" = 1 ]; then 
    # pjmedia's echo_webrtc_aec3.cpp is compiled WITHOUT the WEBRTC_* defines that pjproject's CMake
    # gives only to the webrtc_aec3 library itself -> pass the same set to the whole build.
    pj_defs=(-DPJMEDIA_HAS_WEBRTC_AEC=1 -DPJMEDIA_HAS_WEBRTC_AEC3=1 -DWEBRTC_APM_DEBUG_DUMP=0 -DWEBRTC_POSIX=1
             ${SPC_WEBRTC_DEFS[@]+"${SPC_WEBRTC_DEFS[@]}"})
  fi
  local speex_args=()
  if [ "${SPC_SPEEX_AEC_SHIM:-0}" = 1 ]; then
    spc_build_speexdsp_shim
    speex_args=(-DPJMEDIA_WITH_SPEEX_AEC=ON -DSpeexDSP_INCLUDE_DIR="$SPC_OUT/include" -DSpeexDSP_LIBRARY="$SPC_OUT/lib/libspeexdsp.a")
  fi
  local oboe_args=()
  if [ "${SPC_WITH_OBOE:-0}" = 1 ]; then
    # pjproject's CMake has no switch for Oboe, but pjmedia-audiodev's compile
    # definition is $<BOOL:${PJMEDIA_AUDIO_DEV_HAS_OBOE}>, so defining that
    # variable enables oboe_dev.cpp; the JNI backend must be turned off.
    oboe_args=(-DPJMEDIA_AUDIO_DEV_HAS_OBOE=1 -DPJMEDIA_WITH_AUDIODEV_JNI=OFF
               "-DCMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES=$SPC_OUT/include")
  fi

  local flag_args=()
  if [ "${#pj_defs[@]}" -gt 0 ]; then flag_args=("-DCMAKE_C_FLAGS=${pj_defs[*]}" "-DCMAKE_CXX_FLAGS=${pj_defs[*]}"); fi
  spc_cmake "$src" "$SPC_BLD/pjproject" \
    -DPJ_SKIP_EXPERIMENTAL_NOTICE=ON \
    -DCMAKE_CXX_STANDARD=17 \
    -DBUILD_TESTING=OFF \
    -DPJMEDIA_WITH_VIDEO=OFF \
    -DPJNATH_WITH_UPNP=OFF \
    -DPJMEDIA_WITH_LYRA_CODEC=OFF \
    -DPJMEDIA_WITH_SILK_CODEC=OFF \
    -DPJMEDIA_WITH_OPENCORE_AMRNB_CODEC=OFF \
    -DPJMEDIA_WITH_OPENCORE_AMRWB_CODEC=OFF \
    -DPJMEDIA_WITH_FFMPEG=OFF \
    -DPJMEDIA_WITH_VIDEODEV_SDL=OFF \
    -DPJMEDIA_WITH_LIBYUV=OFF \
    -DPJMEDIA_WITH_VPX_CODEC=OFF \
    -DPJMEDIA_WITH_OPEN_H264_CODEC=OFF \
    -DPJLIB_WITH_SSL=openssl \
    -DPJMEDIA_WITH_OPUS_CODEC=ON -DPJMEDIA_WITH_BCG729_CODEC=ON \
    -DOPENSSL_ROOT_DIR="$SPC_OUT" -DOPENSSL_USE_STATIC_LIBS=ON \
    -DOPUS_INCLUDE_DIR="$SPC_OUT/include" -DOPUS_LIBRARY="$SPC_OUT/lib/libopus.a" \
    -DBCG729_INCLUDE_DIR="$SPC_OUT/include" -DBCG729_LIBRARY="$SPC_OUT/lib/libbcg729.a" \
    ${flag_args[@]+"${flag_args[@]}"} \
    ${oboe_args[@]+"${oboe_args[@]}"} \
    ${speex_args[@]+"${speex_args[@]}"} \
    ${SPC_PJ_CMAKE_ARGS[@]+"${SPC_PJ_CMAKE_ARGS[@]}"}
  # pjproject's CMake silently downgrades features it cannot find (e.g. "OpenSSL not found. setting
  # PJLIB_WITH_SSL to <empty>"). TLS/DTLS-SRTP and the Opus/G.729 codecs are mandatory: fail loudly.
  local cache="$SPC_BLD/pjproject/CMakeCache.txt" v
  for v in PJLIB_WITH_SSL=openssl PJMEDIA_WITH_OPUS_CODEC=ON PJMEDIA_WITH_BCG729_CODEC=ON; do
    grep -Eq "^${v%%=*}:[A-Z]+=${v#*=}\$" "$cache" \
      || die "pjproject was configured without ${v%%=*}=${v#*=} (see 'not found' messages above); refusing to build with silent feature loss"
  done
  spc_stamp_set pjproject "$key"
}

# ---------------------------------------------------------------- spc_deps.cmake
# Locate an installed static library by base name (without lib prefix/.a/.lib).
_spc_find_lib() {
  local name="$1" d f
  for d in lib bin bin/pjproject/third_party lib/pjproject/third_party; do
    for f in "$SPC_OUT/$d/lib$name.a" "$SPC_OUT/$d/$name.lib" "$SPC_OUT/$d/lib$name.lib"; do
      if [ -f "$f" ]; then echo "${f#"$SPC_OUT"/}"; return 0; fi
    done
  done
  return 1
}

# Write <prefix>/spc_deps.cmake. Library list is resolved NOW (fail fast if a
# required one is missing); paths are stored relative to the prefix so the
# prefix stays relocatable.
spc_write_deps_cmake() {
  local f="$SPC_OUT/spc_deps.cmake"
  local required="pjsua-lib pjsip-ua pjsip-simple pjsip pjmedia-codec pjmedia-videodev pjmedia-audiodev pjmedia pjnath pjlib-util pjlib"
  local optional="srtp resample speex gsm ilbc g7221 webrtc_aec3 webrtc yuv"
  local libs="" n rel
  for n in $required; do
    rel="$(_spc_find_lib "$n")" || die "required library '$n' not found under $SPC_OUT"
    libs="$libs $rel"
  done
  local found_opt=""
  for n in $optional; do
    if rel="$(_spc_find_lib "$n")"; then libs="$libs $rel"; found_opt="$found_opt $n"; fi
  done
  # Android Oboe is part of the audio backend -> must come after pjmedia-audiodev
  if [ "${SPC_WITH_OBOE:-0}" = 1 ]; then
    rel="$(_spc_find_lib oboe)" || die "oboe not found"; libs="$libs $rel"
  fi
  for n in opus bcg729 ssl crypto; do
    rel="$(_spc_find_lib "$n")" || die "required library '$n' not found under $SPC_OUT"
    libs="$libs $rel"
  done

  {
    echo "# Generated by native/scripts/common.sh for target '$SPC_TARGET' ($(date -u +%Y-%m-%dT%H:%M:%SZ))."
    echo "# Usage:  include(<prefix>/spc_deps.cmake)"
    echo "#         target_link_libraries(spcore PRIVATE spc::deps)"
    echo "# Provides the imported INTERFACE target spc::deps: pjproject $PJ_VER + OpenSSL $OPENSSL_VER"
    echo "# + Opus $OPUS_VER + bcg729 $BCG729_VER static libs (in link order), include dirs,"
    echo "# compile definitions and the system libs / frameworks they need."
    echo 'if(TARGET spc::deps)'
    echo '  return()'
    echo 'endif()'
    echo 'get_filename_component(SPC_DEPS_PREFIX "${CMAKE_CURRENT_LIST_DIR}" ABSOLUTE)'
    echo "set(SPC_DEPS_TARGET \"$SPC_TARGET\")"
    echo "set(SPC_DEPS_PJ_VERSION \"$PJ_VER\")"
    echo 'set(_spc_static_libs'
    for rel in $libs; do echo "  \"\${SPC_DEPS_PREFIX}/$rel\""; done
    echo ')'
    echo 'add_library(spc::deps INTERFACE IMPORTED GLOBAL)'
    echo 'target_include_directories(spc::deps INTERFACE "${SPC_DEPS_PREFIX}/include")'
    if [ "${SPC_WEBRTC_AEC:-1}" = 1 ]; then
      echo 'target_compile_definitions(spc::deps INTERFACE PJ_AUTOCONF=1 PJMEDIA_HAS_WEBRTC_AEC=1 PJMEDIA_HAS_WEBRTC_AEC3=1)'
    else
      echo 'target_compile_definitions(spc::deps INTERFACE PJ_AUTOCONF=1)'
    fi
    if [ "${SPC_LINK_GROUP:-0}" = 1 ]; then
      echo '# pjmedia <-> pjmedia-audiodev and others are mutually dependent: let the ELF linker rescan.'
      echo 'target_link_libraries(spc::deps INTERFACE "$<LINK_GROUP:RESCAN,${_spc_static_libs}>")'
    else
      echo 'target_link_libraries(spc::deps INTERFACE ${_spc_static_libs})'
    fi
    if [ "${SPC_ANDROID_AUDIO:-}" = opensl ]; then echo 'target_compile_definitions(spc::deps INTERFACE PJMEDIA_AUDIO_DEV_HAS_OPENSL=1)'; fi
    if [ -n "${SPC_SYSTEM_LIBS:-}" ]; then
      echo "target_link_libraries(spc::deps INTERFACE $SPC_SYSTEM_LIBS)"
    fi
    if [ -n "${SPC_LINK_OPTIONS:-}" ]; then
      echo "target_link_options(spc::deps INTERFACE $SPC_LINK_OPTIONS)"
    fi
    echo 'unset(_spc_static_libs)'
  } > "$f"
  log "wrote $f"
  SPC_LIBS_FOUND="$libs"
}

spc_summary() {
  local t1; t1=$(date +%s)
  echo
  echo "==================== SUMMARY ===================="
  echo "target     : $SPC_TARGET"
  echo "prefix     : $SPC_OUT"
  echo "pjproject  : $PJ_VER   openssl: $OPENSSL_VER   opus: $OPUS_VER   bcg729: $BCG729_VER${SPC_WITH_OBOE:+   oboe: $OBOE_VER}"
  echo "libs:"
  for rel in ${SPC_LIBS_FOUND:-}; do printf '  %-48s %s\n' "$rel" "$(du -h "$SPC_OUT/$rel" | cut -f1)"; done
  echo "entry point: include($SPC_OUT/spc_deps.cmake)"
  echo "elapsed    : $((t1 - SPC_T0))s"
  echo "================================================="
}

spc_build_all() {
  spc_fetch
  spc_build_openssl
  spc_build_opus
  spc_build_bcg729
  if [ "${SPC_WITH_OBOE:-0}" = 1 ]; then spc_build_oboe; fi
  spc_build_pjproject
  spc_write_deps_cmake
  spc_summary
}
