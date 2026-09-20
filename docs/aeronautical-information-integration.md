# Aeronautical information integration

Date: 2026-09-15. Status: IMPLEMENTED; official feed and device acceptance remain open.

The mobile checkout is `C:\xampp\htdocs\yaw_app`. The canonical backend is `C:\xampp\htdocs\myaviation`. No project was created at the nonexistent `C:\xampp\htdocs\yaw\_app` path.

## Architecture and behavior

`lib/features/aeronautical_information/data/briefing_models.dart` maps the backend briefing snapshot, source records, current compliance, permissions and revisions. `presentation/briefing_controller.dart` uses the existing MissionRepository and YawApiClient, with ChangeNotifier lifecycle/disposal handling. Mission detail opens MissionBriefingScreen; BriefingItemScreen separates source content/provenance from the YAW interpretation.

The server computes spatial, altitude and time relevance, severity, release effect, source authority, freshness, currentness and acknowledgement eligibility. Flutter only displays those fields. It does not parse NOTAM text or derive release decisions. A failed refresh clears actionable cached state; app resume and a one-minute timer request current server state. Writes are online-only. Review confirmation is tied to a particular briefing ID.

## Verified API methods

| Method | Existing implemented route | Mobile behavior |
|---|---|---|
| GET | `/api/v1/missions/{mission}/briefing` | Load latest or `?revision=N` historical snapshot with current compliance. |
| POST | `/api/v1/missions/{mission}/briefing` | Generate from the existing mission context. |
| POST | `/api/v1/missions/{mission}/briefing/{briefing}/acknowledge` | Submit `{"reviewed":true}`; consume refreshed server result. |

The existing success/data/meta v1.0 envelope and token handling are reused. Backend register/detail API routes also exist. This mobile slice presents mission-specific item details from immutable briefing snapshots; it does not add a separate mobile register. Mission release and planning mutations remain explicit API gaps.

## Verification

- `flutter analyze --no-pub`: no issues.
- New briefing and existing mission tests: 24 passed.
- Full Flutter suite: 51 passed, four existing authentication widget tests failed in `test/widget_test.dart`, including a login-screen 70 px RenderFlex overflow.
- Eight new tests cover model/source separation, API contract, controller refresh failure, acknowledgement, empty/unavailable state and item detail.
- Android debug build passed with JDK 17 and a process-local short socket directory. Artifact: `build/app/outputs/apk/debug/app-debug.apk`; evidence: `build/aim-gradle-short-temp.log`. No authenticated emulator/device acceptance is claimed.

No fabricated operational feed is used. The required official source is unavailable by default, so the app displays the backend's blocked release control. Public summaries and imported references cannot establish operational clearance.

See `C:\xampp\htdocs\myaviation\docs\10-verification\remediation\aeronautical-information-integration.md` for the complete report, migration evidence, architecture decisions, build diagnostics and outstanding official ATNS/SACAA machine-to-machine access dependency.
