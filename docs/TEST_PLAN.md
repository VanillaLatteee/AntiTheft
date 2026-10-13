# Test Plan

## Test principles

- Test policy/domain logic without platform dependencies where possible.
- Use real devices for background, audio, permission, vendor, and push behavior.
- Assert state terminology: transport delivery must never satisfy an execution assertion.
- Record OS/build/vendor/permission conditions with every manual result.

## Phase 0 automated checks

### Mobile

- `flutter analyze`
- `flutter test`
- Widget smoke test verifies product identity and Phase 0 status.

### Web

- `npm.cmd run lint`
- `npm.cmd run build`
- Build validates the `/api/health` route and App Router types.

### API

- `python -m ruff check .`
- `python -m pytest`
- Tests verify liveness/readiness payloads, request IDs, and unknown-route behavior.

### Infrastructure

- `docker compose --env-file .env.example -f infra/docker-compose.yml config`

## Later-phase matrix

### Mobile permission/onboarding

- First grant, denial, permanent denial/restriction, later grant, revocation, restart, and upgrade.
- No request loop after denial.
- Accurate Android/iOS unsupported and user-action-required states.

### Audio

- Valid/invalid MIME and extension, corrupt file, zero bytes, maximum/over-limit size.
- Short/exact/long duration, loop, stop latency, audio focus/interruption, route change, app background/foreground.
- Replacement and deletion remove inaccessible private copies and metadata safely.

### Remote command

- Wrong owner/device, expired identity token, revoked device, expired command, duplicate idempotency key, replayed command, out-of-order acknowledgment, rate limit.
- Provider accepted/rejected, offline device, delayed push, force-stop, reboot, locked screen, DND/silent mode, permission revoked.

### Required physical environments

- Xiaomi POCO X6 Pro on Android 16/HyperOS (primary)
- At least one Google-reference or near-reference Android device
- Supported iPhone versions covering current minimum and current iOS
- iOS testing/build/signing on macOS with Xcode

## Evidence

Automated checks publish machine-readable results in CI. Manual platform runs record timestamp, app commit, OS build, device model, permission state, expected outcome, actual outcome, and logs with secrets redacted.

