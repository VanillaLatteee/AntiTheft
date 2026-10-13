# Platform Limitations

## Shared limitations

- Push delivery is best-effort and may be delayed, throttled, or dropped.
- A provider delivery response is not proof that the app ran or audio played.
- Network loss, device shutdown, revoked permission, force-stop, and OS policy can prevent execution.
- The app cannot guarantee recovery of a device.

## Android

- Phase 2 playback is deliberately limited to the active app. It uses standard media audio attributes and stops when the activity is no longer visible; it does not start a foreground service or claim background execution.

- Background execution and foreground-service starts are restricted and continue to evolve; implementation must target the installed SDK behavior and use an allowed `mediaPlayback` foreground service only when legally startable.
- Playback requiring a foreground service must show a visible notification. Notification permission denial can affect the experience and must be reported accurately.
- High-priority FCM is not a general background-execution bypass and may be deprioritized if misused.
- The application cannot assume it can override silent mode or Do Not Disturb. Policy access is user-controlled and should not be required merely to simulate guaranteed playback.
- Battery optimization, force-stop state, and Xiaomi HyperOS process management may delay or prevent work. Provide setup guidance and a truthful last-result state rather than vendor-setting automation.
- Reboot restoration is limited to explicitly supported broadcasts/work scheduling and does not permit prohibited background service starts.

## iOS

- Phase 2 playback uses a normal application audio session and is stopped when the application enters the background. This is not a Critical Alert or a background-playback bypass.

- iOS does not permit arbitrary background execution after a remote notification.
- APNs delivery does not guarantee app execution.
- Standard custom notification sounds must be under 30 seconds. A selected 60-second file cannot be used directly as a standard notification sound.
- A 60-second remote siren cannot be guaranteed while the app is suspended or terminated.
- Critical Alerts require a special Apple entitlement and user permission. The product must behave correctly without that entitlement.
- Full custom 60-second playback is limited to an active app/session and other OS-permitted audio contexts. When unavailable, the fallback is a standard notification with a compliant bundled sound and clear portal status.

## Development environment

Android builds can be produced and tested on Windows with the Android SDK. iOS compilation, signing, APNs entitlement validation, and device testing require macOS with Xcode and an Apple Developer account.

Permission dialogs, app-settings transitions, audio routing/focus, interruption handling, lifecycle stops, volume/silent/Focus/DND behavior, and OEM battery policy must be validated on physical devices. Host-side widget tests cannot establish those outcomes.

