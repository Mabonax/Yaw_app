# YAW Mobile Implementation Roadmap

## Phase M0 - Foundation

Completed in this pass:

- Flutter project architecture.
- Design tokens and reusable components.
- API client aligned to the backend envelope.
- Secure token persistence abstraction.
- Auth state and guarded routing.
- Splash, login, authenticated shell, dashboard shell, More modules.
- Foundation tests and documentation.

## Phase M1 - Authentication + User/Pilot

Build only against existing API routes:

- Wire login to `POST /api/v1/auth/login`.
- Wire logout to `POST /api/v1/auth/logout`.
- Fetch account context from `GET /api/v1/me`.
- Fetch pilot profile from `GET /api/v1/me/pilot`.
- Fetch operator context from `GET /api/v1/me/operators`.
- Add profile and operator selection screens if the response shape supports it.

Backend gap to resolve if needed:

- Dedicated current pilot compliance summary.
- Account settings update endpoint.

## Phase M2 - Aircraft + Readiness

Use current API:

- `GET /api/v1/aircraft`
- `GET /api/v1/aircraft/{aircraft}`
- `GET /api/v1/aircraft-catalogue`
- `GET /api/v1/aircraft-catalogue/{aircraftModel}`

Deliver:

- Fleet list and detail.
- Catalogue model lookup.
- Readiness display only where backend response provides readiness data.

Backend gaps:

- Battery API.
- Aircraft flight folio API.
- Defect API.

## Phase M3 - Missions + Compliance + Release

Use current API:

- `GET /api/v1/missions`
- `GET /api/v1/missions/{mission}`
- `GET /api/v1/missions/{mission}/compliance`

Deliver:

- Mission list.
- Mission detail.
- Mission compliance screen.

Backend gap:

- Mission release endpoint.

## Phase M4 - Flight/Post-flight + Logbook + Defects

Use current API:

- `GET /api/v1/missions/{mission}/post-flight-propagation`
- `POST /api/v1/missions/{mission}/post-flight-propagation`

Deliver:

- Post-flight propagation summary.
- Confirmed post-flight close-out flow.

Backend gaps:

- Pilot logbook API.
- Defect list/reporting API.
- Flight track/mobile capture API.

## Phase M5 - Operators + Regulatory

Build after API expansion for:

- Regulatory forms.
- Regulatory compliance register.
- Certificates/licences and expiries.
- Operator renewal packs.
- Compliance notifications.

## Phase M6 - GIS

Build after API expansion for:

- GIS projects.
- Datasets/layers.
- Mission relationships.
- Aviation overlays suitable for mobile.

## Phase M7 - Offline/resilience + Production Hardening

Add after core workflows are stable:

- Offline read caching.
- Retry queues for safe operations.
- Session expiry UX.
- Telemetry and diagnostics.
- Device/emulator proof for Android and iOS builds.
- Accessibility and larger-screen audits.

## Recommended Next Slice

Phase M1: wire real authentication and current user/pilot/operator fetches into the existing shell, then replace placeholder shell copy with backend-backed account context.
## Phase M1 - Authentication + User/Pilot

Completed in this pass:

- Backend-connected login/logout.
- Secure bearer token persistence.
- Stored-token session restoration.
- Current user fetch from `/api/v1/me`.
- Pilot context fetch from `/api/v1/me/pilot`.
- Operator context fetch from `/api/v1/me/operators`.
- Authenticated Home identity summary.
- Pilot Profile screen using backend-presented fields.
- More/Profile actions for refresh and logout.
- YAW branding assets registered and applied.

Remaining M1 backend gaps:

- Mobile pilot profile create/update endpoints are not exposed in API V1.
- Account settings update endpoint is not exposed in API V1.

Next recommended phase remains M2: Aircraft + Readiness using the existing aircraft and aircraft-catalogue API routes.
