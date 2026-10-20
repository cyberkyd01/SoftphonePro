# SoftphonePro v1.1.1

Release date: 2026-10-20.

A bug-fix release for Windows. It installs over 1.1.0 and keeps your accounts and settings. Everything in [v1.1.0](RELEASE_NOTES_v1.1.0.md) is still here.

## Fixed

**Windows: microphone and speaker could not be chosen**
* In 1.1.0 the microphone and speaker pickers (Settings → Audio, the mixer, and in calls) offered only **System default** on many PCs, and no other device could be selected.
* Cause: Windows reports audio device names in the ANSI code page. A name with a character such as `®` (for example "Microphone Array (Intel® Smart Sound…)") made the engine's device list invalid UTF-8, and the app discarded it.
* The engine now converts device names to UTF-8, so every microphone and speaker is listed and can be selected. It also makes sure no other message from the engine can be lost this way (for example error messages on Windows set to a language other than English).

**Tip:** outside a call the microphone meter stays at zero, because the sound device only opens when audio is needed. To hear yourself, turn on **Settings → Audio → Echo test**.

## Downloads

Get the files from the [Releases page](https://github.com/cyberkyd01/SoftphonePro/releases/tag/v1.1.1). The files and install steps are the same as for [v1.1.0](RELEASE_NOTES_v1.1.0.md#downloads-and-install-notes), with `1.1.1` in the file names. **None of the builds are code-signed or notarised yet**, so your system will warn you the first time. On Windows choose **More info → Run anyway**.

## How it was tested

* On a Windows 11 PC with an Intel Smart Sound microphone array, a Realtek speaker and VB-Audio virtual cables, the engine was driven directly: the device list decodes as strict UTF-8 and names every device, selecting the Intel microphone and the Realtek speaker succeeds, and a recording from the selected microphone has signal.
* The full Windows app is built and launch-tested in CI.
