# TR-008 — Flutter Operator Workspace

## Status
Implemented in the Flutter client repository.

## Architecture
The mobile app now persists a selected operator independently from the access token.

- SecureTokenStore -> YAW access token
- SecureOperatorStore -> active operator ID
- ApiClient -> automatically emits X-YAW-Operator when an active operator exists

This mirrors the Laravel tenant contract while keeping identity and workspace selection separate.

## Workspace lifecycle
After authentication the app loads operator memberships.

- one active membership: automatically selected and persisted
- multiple active memberships: operator selection screen is required
- no active memberships: personal/pilot mode remains available
- pending invitations: displayed with accept/decline controls
- stored operator that is no longer active: automatically cleared

## UI
- OperatorWorkspaceScreen lists invitations and active workspaces.
- AppShell shows the selected operator as persistent workspace context.
- Operator switcher can be reopened from operational screens.
- Switching workspace forces aircraft and mission refreshes.

## Security
Tenant-bound requests receive X-YAW-Operator from secure local workspace state. The persisted tenant is reconciled against server membership state before use; a suspended or ended membership causes the local selection to be discarded on refresh.

## Backend dependencies
Requires TR-005 membership lifecycle endpoints and TR-002/TR-003 active operator context.

## Next
TR-009 should propagate operator context into audit evidence consistently across tenant actions and expose operator identity in audit/reporting views.
