# YAW Mobile API Gap Analysis

## Current API Foundation

Verified API V1 routes in `C:\xampp\htdocs\myaviation\routes\api.php`:

- Authentication: `POST /api/v1/auth/login`, `POST /api/v1/auth/logout`
- Current user: `GET /api/v1/me`, `GET /api/v1/me/pilot`, `GET /api/v1/me/operators`
- Aircraft catalogue: `GET /api/v1/aircraft-catalogue`, `GET /api/v1/aircraft-catalogue/{aircraftModel}`
- Aircraft: `GET /api/v1/aircraft`, `GET /api/v1/aircraft/{aircraft}`
- Missions: `GET /api/v1/missions`, `GET /api/v1/missions/{mission}`
- Mission compliance: `GET /api/v1/missions/{mission}/compliance`
- Post-flight propagation: `GET /api/v1/missions/{mission}/post-flight-propagation`, `POST /api/v1/missions/{mission}/post-flight-propagation`

## Gap Register

| Required mobile capability | Backend domain | Existing web/backend functionality | Missing API endpoint | Suggested method | Suggested route | Expected request | Expected response | Priority |
| -------------------------- | -------------- | ---------------------------------- | -------------------- | ---------------- | --------------- | ---------------- | ----------------- | -------- |
| Dashboard aggregate | Compliance/Missions/Aircraft/Pilots | Domain queries exist separately | Mobile dashboard summary | GET | `/api/v1/dashboard` | none | readiness, upcoming missions, open actions | High |
| Pilot compliance summary | Pilots/Compliance | `PilotComplianceEvaluator`, pilot profile queries | Current pilot compliance | GET | `/api/v1/me/pilot/compliance` | none | compliance status, expiring credentials, blockers | High |
| Mission release action | Missions | `ReleaseMission`, `MissionReleaseGate` | Release mission | POST | `/api/v1/missions/{mission}/release` | release confirmation data | lifecycle state, release gate result | High |
| Defect list | Defects | Defect model, report action, web controller | Aircraft/mission defects | GET | `/api/v1/defects` | filters | defect list and status | High |
| Defect reporting | Defects | `ReportAircraftDefect` | Report defect | POST | `/api/v1/defects` | aircraft, mission, severity, description | created defect | High |
| Pilot logbook | FlightLogs | `PilotLogEntry`, summary service | Pilot logbook entries | GET | `/api/v1/me/logbook` | filters | entries and totals | Medium |
| Aircraft flight folio | FlightFolios | `AircraftFlightFolio` | Aircraft folio | GET | `/api/v1/aircraft/{aircraft}/flight-folio` | none | folio records | Medium |
| Batteries | Batteries | Battery models, health evaluator, usage actions | Battery list/detail | GET | `/api/v1/batteries` | filters | batteries and health state | Medium |
| Battery mission usage | Batteries | Mission battery usage action | Record battery usage | POST | `/api/v1/missions/{mission}/batteries` | battery ids, cycles, notes | mission battery report | Medium |
| Regulatory forms | Regulations | Regulatory form register | Regulatory form list | GET | `/api/v1/regulatory/forms` | filters | form register | Medium |
| Regulatory compliance | Compliance/Regulations | Compliance register/reporting | Compliance register | GET | `/api/v1/compliance/register` | filters | findings and register summary | Medium |
| Certificates/licences | Pilots/Operators | Pilot certificates and operator certificate cases | Certificate expiry summary | GET | `/api/v1/certificates/expiries` | filters | certificate status and expiry alerts | Medium |
| Application/renewal packs | Operators | Application renewal pack report | Renewal packs | GET | `/api/v1/operators/{operator}/renewal-packs` | none | pack readiness and documents | Low |
| GIS projects | Geography | GIS project register and presenters | GIS projects list/detail | GET | `/api/v1/gis-projects` | filters | projects and lifecycle state | Medium |
| GIS mission relationships | Geography/Missions | GIS project mission assignment | Link mission to project | POST | `/api/v1/gis-projects/{project}/missions` | mission id, role/context | assignment result | Medium |
| Notifications | Notifications | Compliance notification planner and presenters | Notification center | GET | `/api/v1/notifications` | filters | notification list and unread/action counts | Medium |
| Notification status | Notifications | Status update action | Update notification status | PATCH | `/api/v1/notifications/{notification}` | status | updated notification | Low |
| Account settings | Users/Profile | User model exists | Account settings | GET/PATCH | `/api/v1/me/settings` | profile settings | updated settings | Low |

## Implementation Rule

Until these endpoints exist, the Flutter app must show explicit empty/gap states or hide production workflows. Do not use fake compliance, readiness, or regulatory results as if they came from the backend.

## M1 Confirmed Gaps

| Required mobile capability | Backend domain | Existing web/backend functionality | Missing API endpoint | Suggested method | Suggested route | Expected request | Expected response | Priority |
| -------------------------- | -------------- | ---------------------------------- | -------------------- | ---------------- | --------------- | ---------------- | ----------------- | -------- |
| Mobile pilot profile self-service | Pilots | Web/self pilot profile actions exist outside API V1 | Create current user's pilot profile | POST | `/api/v1/me/pilot` | pilot profile fields matching backend validation | created pilot profile presenter | High |
| Mobile pilot profile update | Pilots | Web/self pilot update actions exist outside API V1 | Update current user's pilot profile | PATCH | `/api/v1/me/pilot` | allowed editable pilot fields | updated pilot profile presenter | High |

M1 implementation handles `pilot: null` as a useful pilot-profile-required state instead of treating it as a crash.
