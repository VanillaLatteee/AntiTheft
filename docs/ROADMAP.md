# Implementation Roadmap

## Phase 0 — Foundation (complete)

- Monorepo and framework scaffolds
- Environment examples and Docker Compose
- API/web health endpoints
- Architecture, product, security, limitations, and test documentation
- Baseline lint, build, and test commands

Exit: all available baseline checks pass, or environmental blockers are recorded precisely.

## Phase 1 — Onboarding and security readiness (implemented; device validation pending)

- Riverpod feature boundaries and persisted onboarding state
- Permission education and explicit request flows
- Android/iOS capability channels
- Native recovery service guidance
- Revocation detection on app resume
- Platform-specific dashboard states and tests

Exit: a real device displays truthful, refreshable readiness without repeated denied-permission prompts.

## Phase 2 — Local recovery siren (implemented; device validation pending)

- MP3/WAV document import, validation, size policy, and private copy
- Secure metadata persistence, preview, replace/delete
- Kotlin Media3 and Swift audio adapters
- Target 60-second local playback, safe looping, lifecycle handling, and immediate stop

Exit: local playback behavior and interruptions are tested on Android/iOS, with limitations shown in the UI.

## Phase 3 — Authentication and device enrollment (next)

- Firebase Authentication verification
- SQLAlchemy owner/device models and Alembic migrations
- Expiring enrollment challenge, device credential lifecycle, push-token update
- Ownership authorization, rate limiting, and audit foundation

Exit: an authenticated owner can enroll/revoke a device and cannot access another owner's device.

## Phase 4 — Recovery portal and command API

- Authenticated sessions and responsive device list
- Command model/state machine, expiry, idempotency, replay protection
- Play/stop requests and status history
- Server-side authorization and abuse controls

Exit: portal actions create auditable commands with accurate lifecycle states; no push delivery yet.

## Phase 5 — Remote delivery and platform integration

- FCM/APNs provider adapters
- Authenticated device fetch/acknowledgment/result reporting
- Android foreground playback where OS policy permits
- iOS compliant notification fallback and foreground execution
- Background, lock-screen, reboot, force-stop, and Xiaomi HyperOS test matrix

Exit: delivery/execution states remain separate and all blocked scenarios fail gracefully.

## Phase 6 — Hardening and release

- Threat-model review, dependency and secret scanning, load/rate-limit tests
- Accessibility, localization, privacy/retention, observability, and incident runbooks
- Store policy review, signing, release builds, rollback plan, and production readiness review

