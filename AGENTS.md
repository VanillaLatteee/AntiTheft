# Repository instructions

## Scope and product integrity

- This repository contains the AntiTheft cross-platform mobile security product.
- Implement only behavior supported by official Android and iOS APIs.
- Never claim that push delivery, background execution, siren playback, DND bypass, or recovery is guaranteed.
- Do not add root, bootloader-unlock, factory-reset, Device Owner, private API, or security-bypass requirements.
- Location tracking and automatic sensor/Bluetooth theft detection are outside the MVP unless the product scope is explicitly changed.

## Language and naming

- Use English for source code, identifiers, technical documentation, API payloads, and commit messages.
- Keep user-visible copy ready for localization; do not scatter platform capability claims through UI code.

## Architecture

- Mobile (`apps/protector`): Flutter presentation/domain/data boundaries, Riverpod dependency injection/state, and narrow platform channels implemented in Kotlin and Swift.
- Web (`apps/recovery-web`): Next.js App Router with server-side authorization for every owner/device operation.
- API (`services/api`): FastAPI application factory, API/domain/data separation, Pydantic boundaries, SQLAlchemy persistence, and Alembic migrations.
- Shared contracts (`packages/shared_contracts`): versioned transport schemas only; never place secrets or platform implementation details here.
- Preserve distinct command states: `QUEUED`, `SENT`, `ACKNOWLEDGED`, `EXECUTED`, `FAILED`, and `EXPIRED`. Delivery is not execution.

## Security requirements

- Never commit credentials, signing keys, Firebase service accounts, APNs keys, push tokens, or production identifiers.
- Validate authentication and device ownership server-side. Owner identifiers alone are not authorization.
- Commands must expire, be idempotent, reject replay, be rate-limited, and produce redacted audit events.
- Store mobile secrets only in platform-backed secure storage. Do not log tokens or command payload secrets.
- Keep public browser environment variables limited to values safe to disclose.

## Development workflow

- Read the nearest nested `AGENTS.md` before changing files in that subtree.
- Make changes within the current phase; do not prematurely add later-phase features.
- Add or update tests for behavior changes. Run the relevant formatter, linter, type checker, and tests before handoff.
- Do not edit generated Flutter platform files unless a platform integration requires it and the reason is documented.
- Keep `.env.example` files current and use placeholders only.

## Required checks

- Mobile: `flutter analyze` and `flutter test` from `apps/protector`.
- Web: `npm.cmd run lint` and `npm.cmd run build` from `apps/recovery-web` on Windows PowerShell.
- API on Windows: `.\.venv\Scripts\python.exe -m ruff check .` and `.\.venv\Scripts\python.exe -m pytest` from `services/api`.
- Infrastructure: `docker compose --env-file .env.example -f infra/docker-compose.yml config` from the repository root.

