cmake_minimum_required(VERSION 3.14)

set(PROJECT_NAME "spcore_flutter")
project(${PROJECT_NAME} LANGUAGES CXX)

# Packaging-only plugin: libspcore.so is prebuilt by native/scripts/build_deps_linux.sh +
# native/scripts/build_spcore.sh linux (app/linux/packaging/build_linux.sh runs both, with
# ALSA enabled and without test hooks) and bundled next to the app's other libraries.
# Override the location with -DSPCORE_PREBUILT_SO=<path> or the SPCORE_PREBUILT_SO environment variable.
set(SPCORE_PREBUILT_SO "${CMAKE_CURRENT_SOURCE_DIR}/../../../native/build/linux/libspcore.so"
  CACHE FILEPATH "Prebuilt libspcore.so for this architecture")
if(DEFINED ENV{SPCORE_PREBUILT_SO} AND NOT "$ENV{SPCORE_PREBUILT_SO}" STREQUAL "")
  set(SPCORE_PREBUILT_SO "$ENV{SPCORE_PREBUILT_SO}")
endif()
get_filename_component(SPCORE_PREBUILT_SO "${SPCORE_PREBUILT_SO}" ABSOLUTE)
if(NOT EXISTS "${SPCORE_PREBUILT_SO}")
  message(FATAL_ERROR
    "spcore_flutter: ${SPCORE_PREBUILT_SO} not found. Run app/linux/packaging/build_linux.sh, or "
    "native/scripts/build_deps_linux.sh and native/scripts/build_spcore.sh linux first.")
endif()

# Absolute paths of libraries the app's install step copies into the bundle's lib/ directory.
set(spcore_flutter_bundled_libraries
  "${SPCORE_PREBUILT_SO}"
  PARENT_SCOPE
)
