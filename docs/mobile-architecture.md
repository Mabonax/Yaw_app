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

## M1 Update - Authenticated Session State

The authenticated session is now represented by one `AuthController` state containing:

- `YawUser`
- nullable `YawPilotProfile`
- `List<YawOperatorContext>`
- authentication status
- context loading status
- authentication and context error messages

Session restoration flow:

```text
Launch
-> read secure token
-> no token: Login
-> token exists: load /me, /me/pilot, /me/operators
-> valid context: authenticated shell
-> 401: clear token and return to Login with an expired-session message
-> network/server/malformed response: show a safe user-facing error
```

The API base URL remains configured through:

```text
--dart-define=YAW_API_BASE_URL=<url>
```

Development examples:

- Android emulator to Laravel on host: `http://10.0.2.2:8000/api/v1`
- Windows desktop local server: `http://127.0.0.1:8000/api/v1`
- Physical devices: use a reachable LAN/Tailscale HTTPS or HTTP development URL configured at run time.
- Production: provide the production API URL through build or release configuration; do not commit secrets or private network addresses.

## M2 Update - Aircraft Feature Structure

Added feature folder:

```text
features/aircraft/
  data/
    aircraft_models.dart
    aircraft_repository.dart
  presentation/
    aircraft_controller.dart
    aircraft_screens.dart
```

Runtime dependency flow:

```text
YawApp.create
-> ApiClient
-> AircraftRepository
-> AircraftController
-> YawRouter
-> AppShell
-> HomeDashboardScreen and AircraftListScreen
```

The aircraft feature follows the M1 state-management pattern: API access stays in the repository, loading/error/selection state stays in a `ChangeNotifier`, and widgets render only state supplied by the controller. Readiness remains server-authoritative; Flutter only groups and displays the status values already returned by the API.
