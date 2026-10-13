# AntiTheft

AntiTheft is a cross-platform recovery-assistance product for an owner's own Android and iOS devices. The repository contains the Phase 0 foundation plus the **Phase 1 and Phase 2 mobile implementation**: security onboarding, a readiness dashboard, private MP3/WAV recovery-audio management, and active-app native playback controls.

The project deliberately does not claim to bypass operating-system restrictions. Push delivery is not proof of siren execution, iOS cannot guarantee arbitrary 60-second background playback, and Android background starts, DND behavior, and vendor battery policies can prevent playback.

## Repository layout

```text
apps/
  protector/          Flutter application (Android and iOS)
  recovery-web/       Next.js recovery portal
services/
  api/                FastAPI service
packages/
  shared_contracts/   Versioned transport contracts
infra/                Docker Compose development stack
docs/                 Product, architecture, security, and delivery docs
tests/                Cross-service test documentation/placeholders
```

## Prerequisites

- Flutter 3.29.3 or a newer compatible stable release
- Dart 3.7.2 or newer compatible release
- Node.js 22.13 or newer supported LTS patch and npm 10+
- Python 3.11+
- Docker Desktop with Compose (optional for PostgreSQL/container workflow)
- Android Studio/SDK for Android; macOS with Xcode is required for iOS builds

## First-time setup

### Mobile

```powershell
cd apps\protector
flutter pub get
flutter run
```

Run checks with `flutter analyze` and `flutter test`.

### API

```powershell
cd services\api
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -e ".[dev]"
Copy-Item .env.example .env
.\.venv\Scripts\python.exe -m uvicorn antitheft_api.main:app --reload --port 8000
```

Open `http://localhost:8000/health/live`, `http://localhost:8000/health/ready`, or `http://localhost:8000/docs`.

### Recovery web

```powershell
cd apps\recovery-web
npm.cmd install
Copy-Item .env.example .env.local
npm.cmd run dev
```

Open `http://localhost:3000` or `http://localhost:3000/api/health`.

### Docker Compose

```powershell
Copy-Item .env.example .env
docker compose --env-file .env -f infra/docker-compose.yml up --build
```

The web portal is exposed on port 3000, the API on 8000, and PostgreSQL on 5432 by default. Local direct-service development can run only PostgreSQL with:

```powershell
docker compose --env-file .env -f infra/docker-compose.yml up database
```

## Documentation

- [Product requirements](docs/PRD.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Security model](docs/SECURITY.md)
- [Platform limitations](docs/PLATFORM_LIMITATIONS.md)
- [Roadmap](docs/ROADMAP.md)
- [Test plan](docs/TEST_PLAN.md)
- [Phase 1-2 real-device checklist](docs/PHASE_1_2_DEVICE_TESTS.md)
- [Development environment snapshot](docs/DEVELOPMENT_ENVIRONMENT.md)

## Current milestone

Phase 1 and Phase 2 are implemented in the mobile source and covered by Dart/widget tests. Native Android compilation still requires an installed Android SDK; iOS compilation and real-device validation require macOS/Xcode. The next product milestone is **Phase 3: authentication and device enrollment** after the Phase 1-2 physical-device checklist is signed off.

