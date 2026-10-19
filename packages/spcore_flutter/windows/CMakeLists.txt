cmake_minimum_required(VERSION 3.14)

set(PROJECT_NAME "spcore_flutter")
project(${PROJECT_NAME} LANGUAGES CXX)

# Packaging-only plugin: spcore.dll is prebuilt by native/scripts/build_spcore_windows.ps1
# (static MSVC runtime, so no vcruntime dependency) and copied here.
set(SPCORE_PREBUILT_DLL "${CMAKE_CURRENT_SOURCE_DIR}/prebuilt/spcore.dll")
if(NOT EXISTS "${SPCORE_PREBUILT_DLL}")
  message(FATAL_ERROR
    "spcore_flutter: ${SPCORE_PREBUILT_DLL} not found. Run native/scripts/build_spcore_windows.ps1 first.")
endif()

# Absolute paths of libraries the app's install step copies next to the .exe.
set(spcore_flutter_bundled_libraries
  "${SPCORE_PREBUILT_DLL}"
  PARENT_SCOPE
)
