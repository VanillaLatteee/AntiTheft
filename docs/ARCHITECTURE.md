# Architecture

## Context

AntiTheft uses a Flutter client, a Next.js owner portal, and a FastAPI command service backed by PostgreSQL. Firebase Authentication supplies owner identity, while FCM and APNs are planned delivery adapters. Phase 0 includes only the service shells and health contracts.

## Boundaries

```text
Owner browser -> Recovery Web -> FastAPI -> PostgreSQL
                                   |
                                   +-> FCM -> Android app
                                   +-> APNs -> iOS app

Mobile app -> FastAPI (enrollment, token updates, acknowledgments)
Mobile app -> Android/iOS native APIs through narrow platform channels
```

Push providers carry a command hint or opaque command identifier. The device obtains/validates the authenticated command, checks identity and expiry, rejects duplicates, attempts only OS-permitted behavior, and returns a separate execution result.

## Mobile

- `presentation`: screens and view state exposed through Riverpod.
- `domain`: capability and command policies independent of Flutter/platform APIs.
- `data`: API clients, repositories, and secure local persistence.
- `platform`: narrow method/event channels implemented in Kotlin and Swift.

Platform capability reporting is data, not a single cross-platform boolean. Android and iOS results must identify supported, denied, restricted, disabled, or unknown states and include a user-actionable next step.

## API

The Python package uses an application factory and separates:

- `api`: transport routes and dependency wiring.
- `schemas`: validated request/response models.
- `domain`: command state machine and security policies (Phase 3+).
- `db`: SQLAlchemy base, sessions, and repositories (Phase 3+).
- `integrations`: Firebase/APNs adapters (Phase 5).

FastAPI's generated OpenAPI document is the authoritative HTTP description until a generated client workflow is added. Database schema changes must use Alembic migrations.

## Web

The portal uses the Next.js App Router. Browser-visible values use `NEXT_PUBLIC_` only when safe to disclose. Authentication/session verification and ownership authorization occur on the server; client UI state never authorizes a command.

## Shared contracts

`packages/shared_contracts` contains versioned JSON Schema artifacts for language-neutral payloads. Changes that remove or reinterpret fields require a new contract version. Generated Dart/Python/TypeScript types may be introduced after the command API stabilizes.

## Deployment posture

- TLS terminates at a trusted managed ingress/reverse proxy.
- API and workers use least-privilege service identities.
- PostgreSQL is not publicly reachable in production.
- Push-provider credentials remain server-side in a secrets manager.
- Health endpoints contain no secret or dependency connection details.

