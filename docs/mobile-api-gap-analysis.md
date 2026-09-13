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

## M2 Confirmed Aircraft Gaps

| Required mobile capability | Backend domain | Existing web/backend functionality | Missing API endpoint | Suggested method | Suggested route | Expected request | Expected response | Priority |
| -------------------------- | -------------- | ---------------------------------- | -------------------- | ---------------- | --------------- | ---------------- | ----------------- | -------- |
| Physical aircraft onboarding | Aircraft | `CreatePhysicalAircraft` creates the aircraft, assigns operator, instantiates package assets, and records audit evidence | Mobile aircraft onboarding | POST | `/api/v1/aircraft` | catalogue model id or custom aircraft fields, registration, serial number, operator id, base location, acquisition metadata | created aircraft presenter with readiness and package instantiation | High |
| Physical aircraft update | Aircraft | Web/backend aircraft requests and actions support managed aircraft records | Mobile aircraft update | PATCH | `/api/v1/aircraft/{aircraft}` | allowed editable aircraft fields | updated aircraft presenter | Medium |
| Aircraft operator assignment | Operators/Aircraft | Operator-aircraft relationship exists in backend and is assigned during creation | Mobile operator-aircraft assignment | POST/PATCH | `/api/v1/aircraft/{aircraft}/operators` | operator id, assignment role, effective dates/status | updated aircraft operator relationship | Medium |

M2 implementation intentionally stays read-only for physical aircraft because API V1 exposes only aircraft list/detail and catalogue list/detail routes.

## M3 Confirmed Mission Gaps

| Required mobile capability | Backend domain | Existing web/backend functionality | Current API capability | Missing mobile need | Suggested method | Suggested route | Expected request | Expected response | Server-authoritative service/action | Priority |
| -------------------------- | -------------- | ---------------------------------- | ---------------------- | ------------------- | ---------------- | --------------- | ---------------- | ----------------- | ----------------------------------- | -------- |
| Mission release | Missions | Web route `POST /missions/{mission}/release` calls `ReleaseMission`, records audit evidence, stores compliance snapshot, allows green/amber, rejects red | No API V1 release route | Release from mobile after reviewing compliance | POST | `/api/v1/missions/{mission}/release` | optional confirmation/evidence metadata if required; mission id in route | updated mission presenter with refreshed compliance and release gate results; validation errors on blocked release | `ReleaseMission`, `MissionComplianceSummary`, `MissionLifecycle` | High |
| Mission creation/planning | Missions | Web `StoreMissionRequest` validates purpose, location, geometry, operator, aircraft, pilot, dates, operation type, visibility, risk, approvals; `CreateMission` creates draft and evaluates release gate | No API V1 create route | Mobile planning wizard or quick mission creation | POST | `/api/v1/missions` | fields matching `StoreMissionRequest` and mobile-safe operator/pilot/aircraft selection | created mission presenter with lifecycle and compliance | `CreateMission`, `StoreMissionRequest`, `MissionReleaseGate` | High |
| Mission update/planning edits | Missions | Mission update policy exists and lifecycle blocks closed/cancelled updates; web create route exists, update route not currently exposed in web resource list | No API V1 update route | Edit planned mission details, dates, aircraft, pilot, operator, location, risk, approvals | PATCH | `/api/v1/missions/{mission}` | editable planning fields matching backend validation | updated mission presenter with refreshed compliance | Mission policy, lifecycle, future update action/request | High |
| Operator selection for planning | Operators/Missions | Operator membership scoping and `CurrentOperatorContext` exist; web request validates access | `/api/v1/me/operators` supplies current user's operators | Planning needs selectable operator options scoped to permissions | GET | `/api/v1/missions/options` or `/api/v1/operators` | none or filters | operators current user can use for mission planning | `CurrentOperatorContext`, `MissionOptions` | High |
| Aircraft selection for planning | Aircraft/Missions | Operator-aircraft relationship validation exists in `StoreMissionRequest` | `/api/v1/aircraft` supplies accessible aircraft | Planning needs aircraft options with readiness context | GET | `/api/v1/missions/options` or filtered `/api/v1/aircraft` | operator id filter | aircraft assigned to selected operator with readiness summary | `CurrentOperatorContext`, aircraft presenters/readiness | High |
| Pilot selection for planning | Pilots/Missions | Operator-pilot relationship validation exists in `StoreMissionRequest` | `/api/v1/me/pilot` supplies current pilot only | Planning needs pilot options when permissions allow assignment | GET | `/api/v1/missions/options` or `/api/v1/pilots` | operator id filter | active pilots assigned to selected operator with compliance summary | `CurrentOperatorContext`, pilot compliance services | High |
| Location/site planning | Geography/Missions | Mission geometry, GIS assignment, spatial evaluator, and web GIS mission assignment exist | Mission presenter returns location/coordinates/polygon when already planned | Mobile needs location search/geometry/site selection APIs | GET/POST | `/api/v1/mission-sites`, `/api/v1/gis-projects/{project}/missions` | location query or GIS assignment payload | selected site/geometry and spatial review hints | `MissionSpatialRuleEvaluator`, GIS assignment services | Medium |
| Pre-flight checklist capture | Checklists/Missions | Web pre-flight checklist routes and `RecordMissionChecklist` exist; compliance requires active pre-flight checklist | No API V1 checklist route | Complete/update mission pre-flight checklist from mobile | GET/POST | `/api/v1/missions/{mission}/pre-flight-checklist` | checklist item responses, state, evidence | recorded checklist and refreshed mission compliance | `RecordMissionChecklist`, checklist templates | High |
| Defects affecting release | Defects/Missions | Mission defects and aircraft defects exist; web defect route exists | No API V1 defect route | View/report defects tied to mission release blockers | GET/POST | `/api/v1/missions/{mission}/defects` | defect fields and evidence | defect presenter and refreshed compliance | defect reporting action, aircraft readiness/compliance services | High |
| Mission cancellation | Missions | Lifecycle supports transition to `cancelled` from early states | No API V1 cancellation route | Cancel planned mission with audit reason | POST | `/api/v1/missions/{mission}/cancel` | cancellation reason | updated mission presenter | `MissionLifecycle`, future cancel action | Medium |
| Mission completion/post-flight entry | Missions/Post-flight | API V1 post-flight propagation exists for completed/post-flight-review missions | API supports propagation, not full execution/completion capture | Mark mission completed and enter actuals before propagation | POST/PATCH | `/api/v1/missions/{mission}/complete` | actual takeoff/landing/duration, notes, declaration | updated mission presenter and propagation readiness | `PropagatePostFlightRecords`, lifecycle services | High |

M3 implementation uses only current API V1 read routes for mission visibility/compliance and records release/planning write operations as gaps.

## M4 Confirmed Post-flight and Operational Record Gaps

| Required mobile capability | Backend domain | Existing web/backend functionality | Current API capability | Missing mobile need | Suggested method | Suggested route | Expected request | Expected response | Server-authoritative service/action | Priority |
| -------------------------- | -------------- | ---------------------------------- | ---------------------- | ------------------- | ---------------- | --------------- | ---------------- | ----------------- | ----------------------------------- | -------- |
| Post-flight propagation summary | Missions/FlightLogs/FlightFolios | `PostFlightPropagationSummary` evaluates readiness and propagated record ids/counts | `GET /api/v1/missions/{mission}/post-flight-propagation` exists | Implemented in mobile | GET | existing | none | propagation state, actuals, checklist state, blockers, results | `PostFlightPropagationSummary` | Done |
| Post-flight close-out propagation | Missions/FlightLogs/FlightFolios | `PropagatePostFlightRecords` writes mission actuals, pilot logbook, aircraft folio, audit entry, and evidence references | `POST /api/v1/missions/{mission}/post-flight-propagation` exists | Implemented in mobile | POST | existing | actual takeoff/landing, pilot and aircraft confirmations, defect/occurrence declarations, closure notes | propagation results and validation errors | `PropagatePostFlightRecords`, `PropagatePostFlightRequest` | Done |
| Mission execution/completion | Missions | Lifecycle supports completed/post-flight-review states and propagation requires completed missions | No API V1 completion route | Mark mission flown/completed before propagation | POST/PATCH | `/api/v1/missions/{mission}/complete` | actuals, execution notes, completion declaration | updated mission presenter and propagation readiness | mission lifecycle service plus propagation summary | High |
| Post-flight checklist capture | Checklists/Missions | Web post-flight checklist routes and `RecordMissionChecklist` exist | No API V1 checklist route | Complete/update post-flight checklist from mobile | GET/POST | `/api/v1/missions/{mission}/post-flight-checklist` | checklist item results, state, exceptions, evidence | recorded checklist and refreshed propagation summary | `RecordMissionChecklist`, checklist templates | High |
| Battery mission usage | Batteries | Web `MissionBatteryUsageController` records cycles, state of charge, usage notes | No API V1 battery usage route | Record batteries used during the mission | POST | `/api/v1/missions/{mission}/batteries` | battery id, cycles added, start/end state of charge, used at, notes | mission battery report and refreshed propagation summary | `RecordMissionBatteryUsage`, `MissionBatteryReport` | High |
| Defect reporting | Defects | Web mission defects route and `ReportAircraftDefect` exist | No API V1 defect route | Report aircraft/mission defects discovered during close-out | POST | `/api/v1/missions/{mission}/defects` | aircraft id, title, severity, serviceability impact, description/evidence | created defect and refreshed propagation summary | `ReportAircraftDefect`, `MissionDefectReport` | High |
| Pilot logbook browsing | FlightLogs | `PilotLogEntry` is created by propagation and pilot logbook summary exists | No API V1 logbook list/detail route | View pilot logbook entries from mobile | GET | `/api/v1/me/logbook` | filters | logbook entries, totals, evidence refs | `PilotLogbookSummary`, `PilotLogEntry` | Medium |
| Aircraft folio browsing | FlightFolios | `AircraftFlightFolio` is created by propagation | No API V1 folio list/detail route | View aircraft folio records from mobile | GET | `/api/v1/aircraft/{aircraft}/flight-folio` | filters | folio entries, maintenance/battery/defect evidence | `AircraftFlightFolio` presenters | Medium |

M4 implementation uses only the current post-flight propagation API for writes. It does not create fake battery, defect, logbook, or folio records on-device; those remain server-owned operational records.
