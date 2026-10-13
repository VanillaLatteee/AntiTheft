# Development Environment Snapshot

Observed on 2026-10-13 during Phase 0 initialization. This is a workstation snapshot, not a production support matrix.

## Available tools

| Tool | Observed version | Status |
| --- | --- | --- |
| Git | 2.51.1.windows.1 | Available |
| Flutter | 3.29.3 stable | Available; newer stable release reported by Flutter |
| Dart bundled with Flutter | 3.7.2 | Used for this project |
| Standalone Dart on `PATH` | 3.5.4 | Misaligned; put `C:\Users\dimas\flutter\bin` first on `PATH` |
| Android Studio | 2024.3 | Available with bundled OpenJDK 21.0.5 |
| Node.js | 22.12.0 | Available, but update to at least 22.13 for the current web dependency engine requirement |
| npm | 10.9.0 | Available through `npm.cmd`; PowerShell blocks the `npm.ps1` shim |
| Python | 3.11.8 | Available through `python`; the Windows `py` launcher does not discover it |
| Docker | 29.7.2 | CLI available |
| Docker Compose | 5.5.1 | CLI available; configuration validation passes |

## Current blockers and limitations

- Flutter Doctor cannot locate an Android SDK. Android Studio is installed, but an SDK must be installed/configured with `flutter config --android-sdk <path>` before an Android build or POCO X6 Pro device run.
- iOS compilation, signing, CocoaPods, APNs validation, and device tests cannot run on Windows; use a macOS/Xcode environment.
- Docker Desktop's Linux engine was not running during verification, so full image builds and container startup could not be executed. `docker compose ... config` passed.
- Node 22.12.0 is one patch below the `>=22.13.0` engine requirement reported by a current lint dependency. Next.js lint and production build still passed, but Node should be updated before CI is established.
- Riverpod 3.4.3 requires Dart 3.12 and `flutter_secure_storage` 11.2.0 requires Dart 3.8. The current Flutter SDK bundles Dart 3.7.2, so Phase 0 uses the newest compatible stable lines: Riverpod 2.6.1 and `flutter_secure_storage` 9.2.4. Upgrade Flutter before taking those major package updates.

## Dependency audit note

`npm audit --omit=dev` reports zero production vulnerabilities. A full `npm audit` reports five high-severity findings in the development-only Next.js ESLint chain (`fast-glob` -> `micromatch` -> `braces`). The registry currently exposes `braces` 3.0.3 as latest while the advisory covers versions through 3.0.3. npm's suggested automatic fix downgrades `eslint-config-next` from 16.4.0 to 14.2.35, which is a breaking and unsupported mismatch with Next.js 16, so that downgrade was not applied. Re-run the audit when the upstream lint chain publishes a compatible fix.

