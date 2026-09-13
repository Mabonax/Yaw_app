# YAW Mobile Architecture

## Architecture Direction

YAW mobile uses a feature-oriented Flutter architecture with a small shared core. The structure is intentionally ready for growth without forcing unused abstractions into the first pass.

```text
lib/
  app/
    app.dart
    router/
    theme/
  core/
    api/
    auth/
    config/
    storage/
    widgets/
  features/
    auth/
    dashboard/
    shell/
```

Future feature folders should follow:

```text
features/<feature>/
  data/
  domain/
  presentation/
```

Use those subfolders when the feature actually needs them. Simple presentation-only shells do not need empty layers.

## App Layer

`lib/app/app.dart` composes runtime dependencies:

- `AppConfig`
- `SecureTokenStore`
- `ApiClient`
- `AuthRepository`
- `AuthController`
- `YawRouter`

`lib/app/router/yaw_router.dart` is the auth guard. It displays:

- splash while bootstrapping
- login when unauthenticated
- app shell when authenticated

## Core Layer

`core/api` models the backend API envelope and errors. `ApiClient` supports:

- base URL configuration
- JSON requests and responses
- bearer token headers
- 401 local session clearing hook
- 403, 404, 422, and 500 error mapping
- timeout and connectivity errors

`core/storage` exposes a `TokenStore` contract with:

- `SecureTokenStore` for runtime secure storage
- `MemoryTokenStore` for tests

`core/auth` owns mobile auth state. Server-side authorization and compliance remain authoritative.

## Configuration

The API base URL is read from:

```text
--dart-define=YAW_API_BASE_URL=<url>
```

Default local emulator value:

```text
http://10.0.2.2:8000/api/v1
```

No secrets or environment-specific credentials are committed.

## Navigation

Initial bottom navigation:

- Home
- Missions
- Aircraft
- Compliance
- More

`More` groups secondary modules:

- Pilot Profile
- Operators
- Logbook
- Defects
- GIS Projects
- Regulatory
- Notifications
- Settings

This keeps the shell concise while the backend API surface matures.

## Backend Alignment Rules

- Do not invent endpoints.
- Do not duplicate server compliance rules in Flutter.
- Do not treat client readiness calculations as authoritative.
- Use API presenters/envelopes from `myaviation` as the source of truth.
- Record missing endpoints in `docs/mobile-api-gap-analysis.md`.

## Next Architecture Steps

- Add typed data models per API response as each feature is implemented.
- Add feature repositories only when a feature starts calling the backend.
- Add offline/resilience services after M1-M4 core workflows are concrete.