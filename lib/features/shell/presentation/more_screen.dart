import 'package:flutter/material.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_models.dart';
import '../../../core/branding/yaw_logo.dart';
import '../../../core/widgets/yaw_widgets.dart';
import '../../pilot/presentation/pilot_profile_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authController,
      builder: (context, _) {
        final state = authController.state;

        return ListView(
          padding: const EdgeInsets.all(YawSpacing.page),
          children: [
            YawCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const YawLogo(variant: YawLogoVariant.icon, height: 48),
                  const SizedBox(width: YawSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.user?.name ?? 'YAW account',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: YawSpacing.xs),
                        Text(
                          state.user?.email ??
                              'Authenticated account context unavailable',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: YawColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: YawSpacing.lg),
            YawSectionCard(
              title: 'Profile',
              subtitle: 'Account, pilot, and operator context.',
              child: Column(
                children: [
                  YawListTile(
                    title: 'My Pilot Profile',
                    subtitle: state.pilot == null
                        ? 'No linked pilot profile returned.'
                        : state.pilot!.displayName,
                    leading: const Icon(
                      Icons.badge_outlined,
                      color: YawColors.aviationBlue,
                    ),
                    onTap: state.pilot == null
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  PilotProfileScreen(pilot: state.pilot!),
                            ),
                          ),
                  ),
                  YawListTile(
                    title: 'My Operators',
                    subtitle: _operatorSummary(state.operators),
                    leading: const Icon(
                      Icons.business_outlined,
                      color: YawColors.aviationBlue,
                    ),
                    trailing: YawStatusChip(
                      label: state.operators.length.toString(),
                      tone: state.operators.isEmpty
                          ? YawStatusTone.warning
                          : YawStatusTone.healthy,
                    ),
                    onTap: () => _showOperators(context, state.operators),
                  ),
                  YawListTile(
                    title: 'Refresh account context',
                    subtitle: 'Reload /me, /me/pilot, and /me/operators.',
                    leading: const Icon(
                      Icons.refresh,
                      color: YawColors.aviationBlue,
                    ),
                    trailing: state.isContextLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: state.isContextLoading
                        ? null
                        : authController.refreshIdentityContext,
                  ),
                  YawListTile(
                    title: 'Logout',
                    subtitle: 'End this mobile session.',
                    leading: const Icon(
                      Icons.logout,
                      color: YawColors.critical,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: authController.logout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: YawSpacing.lg),
            const YawSectionHeader(
              title: 'Future modules',
              subtitle:
                  'Visible as roadmap modules until mobile APIs are available.',
            ),
            YawCard(
              padding: const EdgeInsets.symmetric(vertical: YawSpacing.sm),
              child: const Column(
                children: [
                  YawListTile(
                    title: 'Logbook',
                    subtitle:
                        'Backend domain exists; mobile API endpoint is missing.',
                    leading: Icon(
                      Icons.menu_book_outlined,
                      color: YawColors.aviationBlue,
                    ),
                    onTap: null,
                  ),
                  YawListTile(
                    title: 'Defects',
                    subtitle:
                        'Backend domain exists; mobile API endpoint is missing.',
                    leading: Icon(
                      Icons.report_problem_outlined,
                      color: YawColors.aviationBlue,
                    ),
                    onTap: null,
                  ),
                  YawListTile(
                    title: 'GIS Projects',
                    subtitle:
                        'Backend domain exists; mobile API endpoint is missing.',
                    leading: Icon(
                      Icons.map_outlined,
                      color: YawColors.aviationBlue,
                    ),
                    onTap: null,
                  ),
                  YawListTile(
                    title: 'Regulatory',
                    subtitle:
                        'Backend domain exists; mobile API endpoint is missing.',
                    leading: Icon(
                      Icons.policy_outlined,
                      color: YawColors.aviationBlue,
                    ),
                    onTap: null,
                  ),
                  YawListTile(
                    title: 'Notifications',
                    subtitle:
                        'Backend domain exists; mobile API endpoint is missing.',
                    leading: Icon(
                      Icons.notifications_outlined,
                      color: YawColors.aviationBlue,
                    ),
                    onTap: null,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _operatorSummary(List<YawOperatorContext> operators) {
    if (operators.isEmpty) {
      return 'No active operator relationships returned.';
    }

    if (operators.length == 1) {
      return operators.single.displayName;
    }

    return '${operators.length} operator relationships returned.';
  }

  void _showOperators(
    BuildContext context,
    List<YawOperatorContext> operators,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        if (operators.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(YawSpacing.xxl),
            child: YawEmptyState(
              title: 'No operators',
              message:
                  'No active operator memberships were returned for this account.',
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            YawSpacing.xxl,
            0,
            YawSpacing.xxl,
            YawSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Operators',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: YawSpacing.lg),
              for (final operator in operators)
                YawListTile(
                  title: operator.displayName,
                  subtitle: [
                    if (operator.uasocNumber != null) operator.uasocNumber!,
                    if (operator.membershipRole != null)
                      _formatToken(operator.membershipRole)!,
                    _formatToken(operator.membershipStatus) ??
                        operator.membershipStatus,
                  ].join(' · '),
                  leading: const Icon(
                    Icons.business_outlined,
                    color: YawColors.aviationBlue,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

String? _formatToken(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  return value
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
