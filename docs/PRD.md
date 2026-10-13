# Product Requirements Document

## Product summary

AntiTheft helps an authenticated owner prepare for and respond to the loss of their own Android or iOS phone. It complements Google Find Hub, Apple Find My, and external recovery options such as WhatsApp calls; it does not replace or bypass those systems.

## Users and problem

The primary user is a phone owner who wants a clear readiness checklist before loss and a secure, browser-based way to request a recovery siren afterward without installing a second mobile app.

## MVP goals

1. Explain, request, and continuously report supported protection permissions and settings.
2. Guide owners to enable Google Find Hub or Apple Find My.
3. Import, validate, preview, replace, delete, and locally play an MP3/WAV recovery sound.
4. Target 60 seconds of local playback, looping shorter media where the OS permits, with an immediate stop action.
5. Enroll a device to an authenticated owner and accept expiring, replay-resistant remote siren commands.
6. Display queued, delivery, acknowledgment, execution, failure, and expiry states accurately in a responsive web portal.

## Explicit non-goals for the initial MVP

- Location tracking
- Automatic theft detection using sensors or Bluetooth
- Root, factory reset, bootloader unlock, Device Owner, or private APIs
- Guaranteed push delivery or guaranteed background siren execution
- Silent/DND bypass or assumed Critical Alerts entitlement

## Phase 0 acceptance criteria

- The monorepo includes Flutter, Next.js, FastAPI, shared-contract, infrastructure, documentation, and test areas.
- Mobile analysis/tests, web lint/build, and API lint/tests can be run independently.
- The API exposes liveness and readiness endpoints; the web exposes a portal health endpoint.
- Environment examples contain no real credentials.
- Local Docker Compose configuration includes PostgreSQL, API, and web services.
- Platform limitations and future acceptance criteria are documented before security-sensitive implementation begins.

## Phase 1-2 feature acceptance criteria

The following behavior is implemented in source and automated tests. Acceptance remains provisional until the real-device checklist is completed on Android and iOS.

### Onboarding and readiness

- Each permission is preceded by a reason and requested only after user action.
- A denial is persisted and does not trigger a request loop.
- Revocation is reflected after app resume/restart.
- Unsupported or restricted capabilities are labelled accurately per platform.

### Siren

- Only supported MP3/WAV content within the configured size limit is copied into private storage.
- Playback can always be stopped from an in-app control while the app is active.
- Android foreground playback uses a visible notification when permitted and required.
- iOS remote behavior is reported as notification/fallback behavior unless the app is active; 60-second suspended playback is never promised.

### Remote command

- Authentication and server-side ownership checks are required.
- Commands expire, have an idempotency key, and cannot execute twice.
- Delivery and execution remain separate states.
- The portal shows the last truthful state and timestamp.

