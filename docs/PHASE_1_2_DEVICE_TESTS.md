# Phase 1-2 Real-Device Test Checklist

## Purpose

Host-side Flutter tests cover policy, persistence, validation, and UI behavior. They cannot prove operating-system permission dialogs, audio focus, routing, interruptions, lifecycle handling, or vendor policies. Run this checklist before declaring Phase 1 and Phase 2 fully accepted.

Record the app commit, device model, OS/build, permission state, audio route, expected result, actual result, timestamp, and redacted logs for every run.

## Android

Run on the primary Xiaomi POCO X6 Pro/HyperOS device and at least one Google-reference or near-reference device.

1. Install cleanly and confirm notifications are requested only after tapping **Allow notifications**.
2. Deny the prompt, restart the app, and confirm the prompt is not requested again automatically. Confirm **Open app settings** works.
3. Grant, revoke, and re-grant notifications in system settings; resume the app after each change and confirm the dashboard refreshes.
4. Open the Google Find Hub guide. Confirm the UI does not claim it can inspect whether Find Hub is enabled.
5. Import valid MP3 and WAV files, then reject renamed, corrupt, empty, and files larger than 10 MiB.
6. Restart the app and confirm the selected file metadata and private copy are restored. Replace and delete it, then confirm stale copies are inaccessible.
7. Run preview and 60-second playback with loop both enabled and disabled. Confirm **Stop siren** stops immediately.
8. During playback, test wired/Bluetooth route changes, another app taking audio focus, calls/alarms, volume changes, silent/DND, screen lock, Home, and app switching.
9. Confirm playback stops when the app is no longer visible and that no background service or hidden notification is created.
10. Record behavior under normal and restricted HyperOS battery settings without presenting either result as guaranteed future remote execution.

## iOS

Build and sign on macOS with Xcode, then run on the supported minimum iOS version and a current iOS version.

1. Repeat the notification grant, denial, settings, revocation, restart, and resume cases above.
2. Open the Apple Find My guide. Confirm the UI does not claim it can inspect whether Find My is enabled.
3. Repeat all import, corruption/size rejection, persistence, replacement, deletion, preview, loop, 60-second, and stop checks.
4. Test receiver/Bluetooth route changes, Control Center volume, interruptions, calls, silent mode, Focus modes, screen lock, Home, and app switching.
5. Confirm playback stops when the application enters the background and does not claim Critical Alert or arbitrary background capability.

## Acceptance

Phase 1 and Phase 2 are fully accepted only when automated checks pass, both native projects compile in their supported toolchains, and the applicable physical-device rows above have recorded results. A blocked or OS-restricted result is acceptable when the app reports it truthfully and fails safely.
