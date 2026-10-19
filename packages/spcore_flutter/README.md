# spcore_flutter

Packaging-only Flutter FFI plugin: it ships the **prebuilt** SoftphonePro engine (`spcore`, C + PJSIP) with the
app on Android, iOS, macOS and Windows. It contains no Dart bindings and no native sources; the FFI layer and
library-name resolution live in `packages/spcore_dart` (`SpcoreLibrary.load()`).
(`SpcoreFlutter.libraryPath` only returns the platform's library name.)

## Where the binaries come from

Nothing here is committed (see `.gitignore`); `native/scripts/build_spcore.sh` and
`native/scripts/build_spcore_windows.ps1` build them against the dependency prefixes in `native/out/<target>` and copy them in:

| Platform | Location in this package | Produced by | How it is bundled |
|---|---|---|---|
| Android | `android/src/main/jniLibs/<abi>/libspcore.so` (arm64-v8a, armeabi-v7a, x86_64; stripped, 16 KB aligned) | `build_spcore.sh android` | Standard Gradle `jniLibs` merge; no `externalNativeBuild`. |
| iOS | `ios/Frameworks/spcore.xcframework` (dynamic; device arm64 + simulator arm64/x86_64; min iOS 13) | `build_spcore.sh ios` (needs Xcode) | podspec `vendored_frameworks`; CocoaPods embeds + signs it. |
| macOS | `macos/Frameworks/spcore.xcframework` (universal arm64+x86_64 `spcore.framework`; min macOS 11; ad-hoc signed) | `build_spcore.sh macos` | podspec `vendored_frameworks` -> `<App>.app/Contents/Frameworks/spcore.framework`, re-signed by the Xcode "Embed Pods Frameworks" phase. |
| Windows | `windows/prebuilt/spcore.dll` (x64, static CRT) | `build_spcore_windows.ps1` | `spcore_flutter_bundled_libraries` in `windows/CMakeLists.txt` -> copied next to the `.exe`. |

The app's build fails early with a clear message when the binaries for the platform being built are missing
(Android: Gradle check, Windows: CMake check; Apple: CocoaPods cannot find the xcframework).

Library names used by `spcore_dart`: `libspcore.so` (Android), `spcore.framework/spcore` (macOS, iOS), `spcore.dll` (Windows).

## Using it

```yaml
dependencies:
  spcore_flutter:
    path: ../packages/spcore_flutter
```
The `example/` app loads the library through `spcore_dart` and shows the engine version string (packaging smoke test).
Android example needs `minSdk >= 24` (this plugin's minSdk).
