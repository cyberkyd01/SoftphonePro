cmake_minimum_required(VERSION 3.20)
project(spcore C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_C_VISIBILITY_PRESET hidden)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
if(MSVC)
  # prebuilt deps are /MT
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

set(SPC_DEPS_PREFIX "" CACHE PATH "Dependency prefix: native/out/<target> (has spc_deps.cmake) or a pjproject CMake install (dev)")
option(SPC_APPLE_FRAMEWORK "Build spcore as a macOS/iOS framework" OFF)
option(SPC_SANITIZE "Build with -fsanitize=address,undefined" OFF)
option(SPC_BUILD_CLI "Build tools/spcore_cli" ON)
option(SPC_TEST_HOOKS "Compile hidden __* test methods (offline voice-isolation harness); ON for test builds only" OFF)

if(NOT SPC_DEPS_PREFIX)
  message(FATAL_ERROR "Set -DSPC_DEPS_PREFIX=<prefix> (e.g. native/out/macos-arm64)")
endif()

if(EXISTS "${SPC_DEPS_PREFIX}/spc_deps.cmake")
  include("${SPC_DEPS_PREFIX}/spc_deps.cmake")
  set(SPC_DEPS_LIBS spc::deps)
  message(STATUS "spcore: using production deps ${SPC_DEPS_PREFIX}")
else()
  list(PREPEND CMAKE_PREFIX_PATH "${SPC_DEPS_PREFIX}")
  find_package(Pj CONFIG REQUIRED)
  set(SPC_DEPS_LIBS Pj::pjsua-lib Pj::pjsip-ua Pj::pjsip-simple Pj::pjsip Pj::pjmedia-codec
      Pj::pjmedia-audiodev Pj::pjmedia Pj::pjnath Pj::pjlib-util Pj::pjlib)
  message(STATUS "spcore: using dev pjproject install ${SPC_DEPS_PREFIX}")
endif()

set(SPC_SOURCES
  src/spc_core.c src/spc_json.c src/spc_port.c src/spc_account.c src/spc_call.c src/spc_callreq.c
  src/spc_media.c src/spc_stats.c src/spc_presence.c src/spc_trace.c src/spc_diag.c src/spc_dns.c
  src/spc_lan.c src/spc_player.c src/spc_rec.c src/spc_mp3.c src/spc_tls.c src/spc_ws_transport.c src/spc_iax2.c src/spc_iax2_proto.c
  src/spc_denoise.c
  third_party/cjson/cJSON.c third_party/dart_api/dart_api_dl.c)

# RNNoise v0.1.1 (BSD-3, vendored, model compiled in); see third_party/rnnoise/README.md
set(SPC_RNNOISE_SOURCES
  third_party/rnnoise/src/denoise.c third_party/rnnoise/src/rnn.c third_party/rnnoise/src/rnn_data.c
  third_party/rnnoise/src/pitch.c third_party/rnnoise/src/kiss_fft.c third_party/rnnoise/src/celt_lpc.c)
list(APPEND SPC_SOURCES ${SPC_RNNOISE_SOURCES})

add_library(spcore SHARED ${SPC_SOURCES})
target_include_directories(spcore PRIVATE src include third_party/cjson third_party/dart_api third_party/rnnoise/include third_party/minimp3)
# arch.h/common.h/config.h of RNNoise are visible to the RNNoise sources only
set_source_files_properties(${SPC_RNNOISE_SOURCES} PROPERTIES INCLUDE_DIRECTORIES "${CMAKE_CURRENT_SOURCE_DIR}/third_party/rnnoise/src")
target_compile_definitions(spcore PRIVATE SPC_BUILDING=1)
if(SPC_TEST_HOOKS)
  target_compile_definitions(spcore PRIVATE SPC_TEST_HOOKS=1)
endif()
if(NOT WIN32)
  target_compile_definitions(spcore PRIVATE _GNU_SOURCE=1 _DEFAULT_SOURCE=1)
endif()
target_link_libraries(spcore PRIVATE ${SPC_DEPS_LIBS})
find_package(Threads REQUIRED)
target_link_libraries(spcore PRIVATE Threads::Threads)

if(MSVC)
  target_compile_options(spcore PRIVATE /W3 /D_CRT_SECURE_NO_WARNINGS /D_USE_MATH_DEFINES)
else()
  target_compile_options(spcore PRIVATE -Wall -Wextra -Wno-unused-parameter)
  set_source_files_properties(third_party/cjson/cJSON.c third_party/dart_api/dart_api_dl.c ${SPC_RNNOISE_SOURCES} src/spc_mp3.c
    PROPERTIES COMPILE_OPTIONS "-w")
endif()

if(SPC_SANITIZE AND NOT MSVC)
  target_compile_options(spcore PRIVATE -fsanitize=address,undefined -fno-omit-frame-pointer -g)
  target_link_options(spcore PRIVATE -fsanitize=address,undefined)
endif()

# export only spc_* symbols
if(APPLE)
  target_link_options(spcore PRIVATE "LINKER:-exported_symbols_list,${CMAKE_CURRENT_SOURCE_DIR}/src/exports.list")
elseif(UNIX)
  target_link_options(spcore PRIVATE "LINKER:--version-script=${CMAKE_CURRENT_SOURCE_DIR}/src/exports.map")
endif()
if(UNIX AND NOT ANDROID)
  target_link_libraries(spcore PRIVATE resolv m)
endif()
if(WIN32)
  target_link_libraries(spcore PRIVATE iphlpapi ws2_32)   # also in spc::deps; explicit for GetNetworkParams
endif()
if(ANDROID)
  target_link_options(spcore PRIVATE "LINKER:-z,max-page-size=16384" "LINKER:-z,common-page-size=16384")
  target_link_libraries(spcore PRIVATE log)
endif()

if(APPLE AND SPC_APPLE_FRAMEWORK)
  set_target_properties(spcore PROPERTIES
    FRAMEWORK TRUE
    FRAMEWORK_VERSION A
    MACOSX_FRAMEWORK_IDENTIFIER org.softphonepro.spcore
    PUBLIC_HEADER include/spcore.h
    MACOSX_FRAMEWORK_BUNDLE_VERSION 1.0.0
    MACOSX_FRAMEWORK_SHORT_VERSION_STRING 1.0.0)
endif()

if(SPC_BUILD_CLI AND NOT ANDROID)
  add_executable(spcore_cli tools/spcore_cli.c third_party/cjson/cJSON.c)
  target_include_directories(spcore_cli PRIVATE include third_party/cjson)
  target_link_libraries(spcore_cli PRIVATE spcore Threads::Threads)
  if(NOT MSVC)
    target_compile_options(spcore_cli PRIVATE -Wall -Wextra)
    set_source_files_properties(third_party/cjson/cJSON.c PROPERTIES COMPILE_OPTIONS "-w")
  endif()
  if(SPC_SANITIZE AND NOT MSVC)
    target_compile_options(spcore_cli PRIVATE -fsanitize=address,undefined -g)
    target_link_options(spcore_cli PRIVATE -fsanitize=address,undefined)
  endif()
endif()
