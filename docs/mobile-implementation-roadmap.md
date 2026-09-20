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

## Phase M2 - Aircraft + Readiness

Completed in this pass:

- Fleet list from `/api/v1/aircraft`.
- Aircraft detail from `/api/v1/aircraft/{aircraft}`.
- Catalogue list/search from `/api/v1/aircraft-catalogue`.
- Catalogue detail from `/api/v1/aircraft-catalogue/{aircraftModel}`.
- Server-provided aircraft readiness display.
- Server-provided package instantiation state, battery list, and component list display.
- Dashboard aircraft readiness counts derived from the aircraft endpoint.
- Tests for aircraft DTO parsing, repository routes, controller state, and widget rendering.

Remaining M2 backend gaps:

- Mobile physical aircraft onboarding route is not exposed in API V1.
- Mobile physical aircraft update route is not exposed in API V1.
- Dedicated battery/component detail routes are not exposed in API V1, but M2 uses the embedded aircraft detail payload where available.

Next recommended phase: M3 Missions + Compliance + Release using the existing mission and mission-compliance API routes, while recording release as an API gap until the backend exposes it.

## Phase M3 - Missions + Compliance + Release

Completed in this pass:

- Mission list from `/api/v1/missions`.
- Mission detail from `/api/v1/missions/{mission}`.
- Mission compliance model/repository support for `/api/v1/missions/{mission}/compliance`.
- Mission lifecycle enum mapping from the backend enum.
- Mission Detail hierarchy for header, overview, aircraft, compliance, release readiness, and planning gaps.
- Mission aircraft context reuses the M2 aircraft repository/controller for navigation to Aircraft Detail.
- Compliance tab now surfaces mission compliance attention and aircraft readiness context.
- Home dashboard now shows mission compliance counts from loaded mission data.
- Tests for mission DTO parsing, repository routes/errors, controller states, release API gap handling, and widgets.

Remaining M3 backend gaps:

- API V1 mission release route is not exposed.
- API V1 mission create/update/planning routes are not exposed.
- API V1 mission option endpoints for operator/aircraft/pilot/location selection are not exposed.
- API V1 pre-flight checklist and defect workflows are not exposed.

Next recommended phase remains M4: Mission Execution + Post-flight Close-out + Pilot Logbook + Aircraft Folio + Defects. The existing post-flight propagation API can be used there, but mission completion, checklist capture, logbook, folio, and defects still need careful backend API verification before mobile writes.

## Phase M4 - Mission Execution + Post-flight Close-out + Operational Records

Completed in this pass:

- Post-flight propagation summary from `GET /api/v1/missions/{mission}/post-flight-propagation`.
- Close-out submission to `POST /api/v1/missions/{mission}/post-flight-propagation` using the backend request contract: `actual_takeoff_at`, `actual_landing_at`, `pilot_confirmed`, `aircraft_confirmed`, `defects_declared`, `occurrence_declared`, and optional `closure_notes`.
- Mission Detail now shows execution actuals, post-flight checklist state, server blocking reasons, and propagation status.
- Propagated results now surface pilot logbook entry id, aircraft flight folio id, battery usage counts/cycles, flight track count, and defect/open-defect counts returned by Laravel.
- Post-flight validation and duplicate-propagation errors are surfaced from API validation envelopes.
- Tests cover model parsing, repository GET/POST routes, controller success/failure state, and the close-out form.

Remaining M4 backend gaps:

- API V1 does not expose mission completion/status transition before propagation.
- API V1 does not expose mobile pre-flight or post-flight checklist capture.
- API V1 does not expose mobile battery usage entry routes.
- API V1 does not expose mobile aircraft/mission defect reporting routes.
- API V1 does not expose direct logbook or aircraft folio list/detail routes; M4 displays only IDs and counts returned by post-flight propagation.

Next recommended phase: add backend API routes for checklist capture, battery usage, defect reporting, and mission completion, then extend the mobile M4 workflow from close-out propagation into full mission execution capture.

## 2026-09-15 - Pre-flight aeronautical briefing

IMPLEMENTED: mission briefing, generation using current mission context, source/interpretation detail, source-health/currentness display, reviewed acknowledgement and revision history. All business/release calculations remain in the canonical backend. Flutter analysis and 24 combined briefing/mission tests pass. Full-suite authentication failures, Android build diagnostics and pending official-feed/device acceptance are documented in [integration evidence](aeronautical-information-integration.md).

## FR-AIM-009 — 2026-09-16

Authentication follows the existing onboarding flow with constrained scrolling, wrapping controls and preserved branding. Logout removes private routes and retires mission/aircraft controllers; the next account reloads its own domain data. Provider `health_status` and `reason` are rendered from Laravel. Failed briefing refresh clears actionable cached state and successful refresh restores only the server result.

Final automation: Flutter analysis reports zero issues; all 62 tests pass, including three phone sizes at text scales 1.0/1.3 with keyboard insets and validation/API errors, private-route logout/relogin and briefing failure/recovery. Android debug build passes. Runtime/browser/external acceptance is reported separately in `C:\xampp\htdocs\myaviation\docs\10-verification\remediation\fr-aim-009-operational-acceptance.md`; compilation is not runtime proof. Required official ATNS access remains unavailable and release stays blocked.

## Reference UI — 2026-09-17

Implemented the six distinct supplied designs, responsive input and navigation,
native document selection, and a separate design gallery. The normal app retains
real authentication and server-owned operational state. See
[screen implementation](screen-implementation.md) for validation and remaining
registration/certificate API dependencies.
