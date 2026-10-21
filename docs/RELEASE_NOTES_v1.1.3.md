# SoftphonePro v1.1.3

Release date: 2026-10-21.

A bug-fix release for every platform. It installs over 1.1.2 and keeps your accounts and settings. Everything in [v1.1.2](RELEASE_NOTES_v1.1.2.md) is still here.

## Fixed

**Turning on LAN Link stopped the calling engine**
* In 1.1.2, switching LAN Link on while the app was running (LAN page → Turn on LAN Link, or a provisioning file that enables it) stopped the calling engine about three seconds later. Accounts unregistered and the app showed "Couldn't start the calling engine" until you pressed Retry. LAN Link itself worked after the Retry.
* Cause: two engine restarts ran at the same time, one for the settings change and one from LAN Link asking for its SIP listener. The second started a new engine while the first was still stopping the old one, failed, and its cleanup stopped the engine in use.
* Restarts now share one run, and the app reports "starting" from the first moment of a restart, so nothing acts on an engine that is being stopped.

**Level meters without graphics acceleration**
* On computers that draw the screen in software (virtual machines, remote desktops, Linux with Mesa's software renderer), the live meters on the idle keypad cost about a quarter of a CPU core. They now update twice a second there while no call, test or recording runs; with a GPU nothing changes.

**Linux: file chooser titles**
* The file choosers for audio files, LAN Link, contacts and provisioning files were titled "Unnamed Window". They now say what they are for.

## Downloads

Get the files from the [Releases page](https://github.com/cyberkyd01/SoftphonePro/releases/tag/v1.1.3). The files and install steps are the same as for [v1.1.2](RELEASE_NOTES_v1.1.2.md), with `1.1.3` in the file names.

## How it was tested

* All automated suites pass: 741 app tests (one new test reproduces the restart race with an engine that, like the native one, refuses a second start and takes time to stop: it fails on 1.1.2 and passes now), 70 `spcore_dart` tests, 58 LAN Link tests and 244 native engine tests in Release and AddressSanitizer builds.
* The released 1.1.2 Linux packages were installed and run on Debian 12 and 13 and Ubuntu 22.04 and 24.04 (arm64) and Debian 12 and Ubuntu 24.04 (amd64): calls, the musicbed at the far end, the live meters, the echo test, test sounds, tray, notifications, links, keyring unlock and LAN Link between two devices. That run found the LAN Link bug; the fix was then checked on a 1.1.3 Linux build. Details: [QA_LINUX.md](QA_LINUX.md).
* CI builds and launch-tests every platform for the release.
