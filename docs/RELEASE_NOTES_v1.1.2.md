# SoftphonePro v1.1.2

Release date: 2026-10-21.

A bug-fix release for audio, with a new Audio test page. It installs over 1.1.1 and keeps your accounts and settings. Everything in [v1.1.1](RELEASE_NOTES_v1.1.1.md) is still here.

## Fixed

**The microphone meter stayed flat outside calls**
* The engine closed the sound device a second after the last call ended, and measured the microphone only while something was listening to it, so the meters read zero until a call began.
* The app now asks the engine to keep the device open while a meter is on screen: always on desktop, and on phones only on the Audio test and Settings > Audio pages (so the microphone indicator is not on while you use the keypad). On iPhone the device is only open during a call, so nothing changes there.

**The echo test was inaudible with echo cancellation on**
* The canceller treated your own voice as echo and removed it. The engine now bypasses echo cancellation and noise suppression while the test runs and restores them when it ends or a call starts.
* The test stops by itself after 60 seconds. Use headphones: with loudspeakers you will hear feedback.

**Audio-device errors were silent**
* A failed device open now shows a notice, and the mixer says "Microphone unavailable: using a silent device" when the engine had to fall back.
* The engine retries the real device when you refresh devices, change devices or start a test, and no longer repeats the same error on every retry.

## Added

**Audio test page** (Settings > Audio, Diagnostics > Audio, or the button on the mixer card)
1. Devices: pick the microphone and speaker and see which one is in use.
2. Microphone: live level, microphone gain, and hints when the signal is silent, very quiet or clipping, with links to the system sound and privacy settings on Windows and macOS.
3. Speaker: plays a short chime; you confirm that you heard it.
4. Record and play back: records 5 seconds and plays them back.
5. Hear yourself: the echo test, with a headphones warning.
6. Background music: the musicbed controls and a preview of what callers hear (your voice and the music as they are sent).
7. Summary: the result of each step and a **Copy diagnostics** button.

During a call only steps 1 and 2 are available. On iPhone, steps 2 to 6 need a call.

**Engine contract v1.3:** `media.monitor`, `media.audioState`, `media.playLocal`, `media.playStop`, `media.loopback` with `timeoutMs`, the `chime` tone, `send` in `media.levels`, and the events `media.monitor`, `media.loopback` and `media.playDone`. See [ENGINE_API.md](ENGINE_API.md) section 11.

## Downloads

Get the files from the [Releases page](https://github.com/cyberkyd01/SoftphonePro/releases/tag/v1.1.2). The files and install steps are the same as for [v1.1.0](RELEASE_NOTES_v1.1.0.md#downloads-and-install-notes), with `1.1.2` in the file names. **None of the builds are code-signed or notarised yet**, so your system will warn you the first time. On Windows choose **More info → Run anyway**.

## How it was tested

* The Dart package and the app have automated tests for the new engine calls, the Audio test page, the live monitor on desktop and phones, the echo test and the device-error notice, and all 14 languages are checked for the new texts.
* The engine changes are covered by the engine tests and were driven directly against a Windows sound device.
