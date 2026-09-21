import 'package:flutter/material.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/widgets/yaw_widgets.dart';
import '../../operators/presentation/operator_workspace_controller.dart';
import '../../operators/presentation/operator_workspace_screen.dart';
import '../../pilot/presentation/pilot_profile_screen.dart';

class PersonalPilotDashboardScreen extends StatelessWidget {
  const PersonalPilotDashboardScreen({
    super.key,
    required this.authController,
    required this.operatorWorkspaceController,
    required this.onWorkspaceChanged,
  });

  final AuthController authController;
  final OperatorWorkspaceController operatorWorkspaceController;
  final VoidCallback onWorkspaceChanged;

  @override
  Widget build(BuildContext context) {
    final auth = authController.state;
    final pilot = auth.pilot;
    final memberships = operatorWorkspaceController.state.memberships;
    final invitations = memberships.where((m) => m.isInvitation).length;
    final requests = memberships.where((m) => m.isJoinRequest).length;

    return RefreshIndicator(
      onRefresh: () async {
        await authController.refreshIdentityContext();
        await operatorWorkspaceController.load();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(YawSpacing.page),
        children: [
          Text('Personal Pilot', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: YawSpacing.xs),
          Text(
            'Your YAW identity and pilot records remain available without an operator workspace.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: YawColors.textMuted),
          ),
          const SizedBox(height: YawSpacing.lg),
          YawSectionCard(
            title: pilot?.displayName ?? auth.user?.name ?? 'Pilot profile',
            subtitle: pilot == null ? 'Complete your pilot profile to build your personal aviation record.' : 'Independent YAW pilot identity',
            child: Column(
              children: [
                YawInfoRow(label: 'Profile', value: pilot?.profileStatus ?? 'Not linked'),
                YawInfoRow(label: 'SACAA certificate', value: pilot?.sacaaCertificateNumber ?? 'Not supplied'),
                YawInfoRow(label: 'RPC category', value: pilot?.rpcCategory ?? 'Not supplied'),
                YawInfoRow(label: 'Medical', value: pilot?.medicalStatus ?? 'Not supplied'),
                const SizedBox(height: YawSpacing.sm),
                YawPrimaryButton(
                  label: pilot == null ? 'Pilot profile unavailable' : 'Open pilot profile',
                  icon: Icons.badge_outlined,
                  onPressed: pilot == null ? null : () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => PilotProfileScreen(pilot: pilot)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: YawSpacing.lg),
          YawSectionCard(
            title: 'Operator relationships',
            subtitle: 'Move into an operator workspace only when you are performing operator work.',
            child: Column(
              children: [
                YawInfoRow(label: 'Invitations', value: invitations.toString()),
                YawInfoRow(label: 'Pending join requests', value: requests.toString()),
                const SizedBox(height: YawSpacing.sm),
                YawSecondaryButton(
                  label: 'Manage operator workspaces',
                  icon: Icons.business_outlined,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => OperatorWorkspaceScreen(
                        controller: operatorWorkspaceController,
                        onSelected: onWorkspaceChanged,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: YawSpacing.lg),
          const YawSectionCard(
            title: 'Personal aviation tools',
            subtitle: 'These stay separate from operator-owned fleet and mission records.',
            child: Column(
              children: [
                YawListTile(
                  title: 'Credentials & compliance',
                  subtitle: 'Pilot certificate, ratings and medical status are available in your pilot profile.',
                  leading: Icon(Icons.verified_user_outlined, color: YawColors.aviationBlue),
                  onTap: null,
                ),
                YawListTile(
                  title: 'Logbook',
                  subtitle: 'Personal logbook API is the next integration required.',
                  leading: Icon(Icons.menu_book_outlined, color: YawColors.aviationBlue),
                  onTap: null,
                ),
                YawListTile(
                  title: 'Expiry reminders',
                  subtitle: 'Personal notification API is required before reminders can be enabled.',
                  leading: Icon(Icons.notifications_active_outlined, color: YawColors.aviationBlue),
                  onTap: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: YawSpacing.lg),
          const YawCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, color: YawColors.aviationBlue),
                SizedBox(width: YawSpacing.md),
                Expanded(child: Text('Operator aircraft, missions, defects, GIS and organisation compliance are intentionally unavailable in Personal Pilot mode.')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
