# Persona Journey Foundation

This slice applies the persona-oriented product patterns learned from Ready4School/Khita to YAW without weakening YAW's aviation tenancy or compliance controls.

## Implemented

- Mobile identity bootstrap now uses one server-owned `GET /api/v1/me/bootstrap` contract.
- Auth state retains the resolved persona, workspace type, onboarding progress, readiness and capabilities.
- Workspace changes refresh the bootstrap contract before operational lists are refreshed.
- The shell surfaces the current persona and readiness percentage.
- Parsing coverage exists for the experience contract.

## Product rule

Flutter does not decide aviation permissions or readiness locally. The backend owns persona resolution, onboarding state and capability flags. Flutter renders those decisions.

## Next slices

1. Dedicated persona dashboards for operator manager, operator pilot, compliance and maintenance.
2. Journey/action centre driven by bootstrap `next_action`.
3. Capability-driven bottom navigation.
4. Mission journey workspace: planning → crew → aircraft → airspace → compliance → release → flight → post-flight.
5. Notification centre and expiry/action inbox.


## Mission journey workspace slice

Mission detail now renders the server-owned chronological mission journey:

Planning → Crew → Aircraft → Airspace → Risk → Compliance → Release → Flight → Post-flight.

Flutter parses this from the mission detail contract rather than deriving aviation state locally.

Mobile mission release is now connected to `POST /api/v1/missions/{mission}/release`; the existing Laravel release action remains authoritative for all release gates and audit evidence.
