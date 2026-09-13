# YAW Mobile Audit

## Scope

Audited on 2026-09-13:

- Backend source: `C:\xampp\htdocs\myaviation`
- Reference Flutter application: `C:\xampp\htdocs\mobile\app`
- YAW Flutter application: `C:\xampp\htdocs\yaw_app`

The backend implementation and tests were treated as authoritative. Documentation was used as supporting context only.

## Backend Findings

`routes/api.php` exposes an API V1 foundation under `/api/v1`.

Implemented mobile-callable API routes:

- `POST /api/v1/auth/login`
- `POST /api/v1/auth/logout`
- `GET /api/v1/me`
- `GET /api/v1/me/pilot`
- `GET /api/v1/me/operators`
- `GET /api/v1/aircraft-catalogue`
- `GET /api/v1/aircraft-catalogue/{aircraftModel}`
- `GET /api/v1/aircraft`
- `GET /api/v1/aircraft/{aircraft}`
- `GET /api/v1/missions`
- `GET /api/v1/missions/{mission}`
- `GET /api/v1/missions/{mission}/compliance`
- `GET /api/v1/missions/{mission}/post-flight-propagation`
- `POST /api/v1/missions/{mission}/post-flight-propagation`

The API response envelope is implemented by `App\Domains\Uas\Api\Application\ApiResponse`:

- `success`
- `message`
- `data`
- `errors`
- `error`
- `meta.contract_version`

Sanctum bearer-token authentication is used after login.

## Backend Domain Coverage

The UAS domain contains implemented application, domain, HTTP, policy, model, service, and query code across pilots, operators, aircraft, missions, batteries, checklists, crew, defects, tracks, geography/GIS, notifications, training, regulatory records, documents, audit records, flight logs, and flight folios.

The API surface is smaller than the web/backend domain. Mobile must therefore wire only the current API and record the missing endpoints.

## Mobile Implementation Matrix

| Domain | Backend implemented | API available | Mobile required | Status |
| ------ | ------------------- | ------------- | --------------- | ------ |
| Authentication | Yes | Yes: login/logout | Login, logout, token persistence, auth guard | M0 foundation implemented |
| Current user | Yes | Yes: `/me` | Account context and shell personalization | API client ready; screen pending |
| Pilot profile | Yes | Yes: `/me/pilot` | Profile/readiness entry point | API available; screen pending |
| Pilot compliance | Yes | Partial via pilot/domain and mission compliance | Compliance summary | API gap for broad pilot compliance summary |
| Operators | Yes | Yes: `/me/operators` | Operator context list | API available; screen pending |
| Aircraft | Yes | Yes: `/aircraft`, `/aircraft/{id}` | Fleet list/detail | API available; screen pending |
| Aircraft catalogue/models | Yes | Yes: `/aircraft-catalogue` | Catalogue lookup | API available; screen pending |
| Aircraft readiness | Yes | Partial through aircraft presenters/services | Readiness summary | Verify response shape during M2 |
| Missions | Yes | Yes: `/missions`, `/missions/{id}` | Mission list/detail | API available; screen pending |
| Mission compliance | Yes | Yes: `/missions/{id}/compliance` | Compliance detail/gate | API available; screen pending |
| Mission release | Yes | No dedicated API found | Release workflow | API gap |
| Mission close-out / post-flight | Yes | Yes: post-flight propagation | Close-out propagation | API available; screen pending |
| Defects | Yes | No API V1 route found | Defect list/reporting | API gap |
| Pilot logbook | Yes | No API V1 route found | Logbook list/detail | API gap |
| Aircraft technical/flight folio | Yes | No API V1 route found | Flight folio view | API gap |
| Batteries | Yes | No API V1 route found | Battery health/usage | API gap |
| Regulatory forms | Yes | No API V1 route found | Forms register | API gap |
| Regulatory compliance | Yes | No API V1 route found | Regulatory dashboard | API gap |
| Certificates/licences | Yes | No API V1 route found | Expiry and licence status | API gap |
| Application/Renewal packs | Yes | No API V1 route found | Pack status/actions | API gap |
| GIS projects | Yes | No API V1 route found | GIS projects list/detail | API gap |
| GIS project to mission relationships | Yes | No API V1 route found | Mission/project linkage | API gap |
| Notifications/expiry information | Yes | No API V1 route found | Notification center | API gap |
| User/account settings | Basic user exists | No settings API found | Profile/settings | API gap |

## Reference Flutter Findings

`C:\xampp\htdocs\mobile\app` uses a feature-oriented Flutter structure with `app`, `features`, and `shared` layers. Useful patterns to adapt for YAW:

- Dedicated app entry and router files.
- Centralized configuration and API/networking utilities.
- Shared theme tokens for colors, spacing, radius, and reusable widgets.
- Feature folders grouped by models, providers, screens, and services.
- Shell widgets for bottom navigation.
- Consistent cards, state widgets, detail rows, and section layouts.
- Clear separation of network/service concerns from presentation widgets.

Patterns not copied:

- Medical/clinic domain terminology.
- Patient/doctor product split.
- Any API paths, workflows, branding, or business logic.

## Current YAW Flutter State Before Changes

The YAW Flutter app was the default Flutter scaffold:

- `lib/main.dart` counter app only.
- `test/widget_test.dart` counter smoke test only.
- Default Flutter dependencies plus `cupertino_icons`.
- No routing, API client, auth, feature structure, design tokens, custom widgets, or docs.

## Current YAW Flutter State After M0

Implemented a production foundation without building every feature screen:

- App composition and guarded router.
- Blue-white YAW design system.
- API envelope/client aligned to backend `ApiResponse`.
- Secure token store abstraction using `flutter_secure_storage`.
- Auth repository/controller.
- Login, splash, authenticated shell, dashboard shell, More screen.
- Reusable YAW widgets.
- Foundation tests.

## M1 Update - Authentication and Identity Context

Completed in M1:

- Real login against `POST /api/v1/auth/login`.
- Stored-token session restoration by verifying `/api/v1/me` and loading context.
- Current user model from `/api/v1/me`.
- Pilot profile model from `/api/v1/me/pilot`.
- Operator context model from `/api/v1/me/operators`.
- Authenticated Home now shows real user, pilot, and operator context.
- More/Profile area now exposes My Pilot Profile, My Operators, Refresh account context, and Logout.
- Pilot Profile screen renders only fields exposed by the backend presenter.
- Supplied YAW assets are registered and used for Splash, Login, App Shell, and More/Profile header.

Additional backend gap confirmed:

- `/api/v1/me/pilot` is read-only and can return `pilot: null`; no mobile self-service create/update pilot profile endpoint was found in API V1.

## M2 Update - Aircraft, Catalogue, Package, and Readiness

Completed in M2:

- `GET /api/v1/aircraft` now drives the Aircraft tab fleet list.
- `GET /api/v1/aircraft/{aircraft}` now drives the physical aircraft detail screen.
- `GET /api/v1/aircraft-catalogue` now drives catalogue browsing and search.
- `GET /api/v1/aircraft-catalogue/{aircraftModel}` now drives catalogue model detail.
- Aircraft readiness is displayed only from the backend `readiness` presenter payload: `status`, `label`, `as_of`, `checks`, `blocking_reasons`, and `review_reasons`.
- Aircraft package state is displayed from the backend `package_instantiation` presenter payload, including embedded batteries and components when returned by detail responses.
- Catalogue model package counts and package definition metadata are displayed from the backend catalogue presenter.
- Home aircraft metrics are derived from `/api/v1/aircraft` readiness status counts only.

Confirmed API boundary:

- Backend services support physical aircraft creation and package instantiation through `CreatePhysicalAircraft` and `InstantiateAircraftPackage`.
- API V1 does not expose a mobile `POST /api/v1/aircraft` onboarding route, so M2 does not implement mobile aircraft creation.

## M3 Update - Mission Planning Context, Compliance, and Release Readiness

Completed in M3:

- `GET /api/v1/missions` now drives the Missions tab list.
- `GET /api/v1/missions/{mission}` now drives Mission Detail.
- `GET /api/v1/missions/{mission}/compliance` is represented in the repository and used by detail state.
- Mission list/detail display the backend mission presenter fields: mission number, purpose, project, location, operator, pilot, aircraft, planned dates, lifecycle state, release gate state, and compliance.
- Mission compliance displays the backend `MissionComplianceSummary` contract: `status`, `label`, `blocking_count`, `warning_count`, `controls`, and `evaluated_at`.
- Compliance controls are rendered dynamically from the server contract and include aircraft readiness, pilot readiness, operator compliance, geometry/airspace, checklist, approvals, and risk assessment when returned.
- Mission aircraft context links into the M2 aircraft detail flow and does not recompute aircraft readiness in Flutter.
- Home dashboard now shows mission compliance counts derived from already-loaded `/api/v1/missions` data.
- Compliance tab now aggregates server-provided mission compliance attention and M2 aircraft readiness counts.

Confirmed API boundary:

- API V1 exposes mission list, mission detail, mission compliance, and post-flight propagation routes.
- API V1 does not expose `POST /api/v1/missions/{mission}/release`; the existing release action is a Laravel web route using `ReleaseMission`.
- API V1 does not expose mission creation or update/planning routes; the existing backend web request is `StoreMissionRequest`.
- Flutter presents release readiness and the missing release API state; Laravel remains authoritative for release decisions.
