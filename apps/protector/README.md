# AntiTheft Protector

Flutter application for Android and iOS. Phase 1 and Phase 2 provide:

- explicit security onboarding with persisted, non-looping permission requests;
- a refreshable platform-capability and security-readiness dashboard;
- MP3/WAV signature and 10 MiB size validation;
- an app-private audio copy with metadata in platform-backed secure storage;
- 10-second preview and bounded 60-second local playback;
- optional looping plus an immediate in-app stop control; and
- narrow Kotlin/Media3 and Swift/AVAudioPlayer platform adapters.

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Android builds require a configured Android SDK. iOS compilation and signing require macOS with Xcode. Physical devices are required to validate permission prompts, audio focus/interruptions, background lifecycle stops, volume/silent/Focus/DND behavior, and vendor battery policies. See [`docs/PHASE_1_2_DEVICE_TESTS.md`](../../docs/PHASE_1_2_DEVICE_TESTS.md).

Playback is intentionally local and active-app only in these phases. The app does not bypass background-execution, silent/DND, or platform recovery-service restrictions.

