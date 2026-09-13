import 'package:flutter/material.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_models.dart';
import '../../../core/widgets/yaw_widgets.dart';
import '../../aircraft/presentation/aircraft_controller.dart';
import '../../pilot/presentation/pilot_profile_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    super.key,
    required this.authController,
    required this.aircraftController,
  });

  final AuthController authController;
  final AircraftController aircraftController;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.aircraftController.state.status == AircraftLoadStatus.idle) {
      widget.aircraftController.loadAircraft();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.authController,
        widget.aircraftController,
      ]),
      builder: (context, _) {
        final state = widget.authController.state;
        final user = state.user;

        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              widget.authController.refreshIdentityContext(),
              widget.aircraftController.loadAircraft(refresh: true),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.all(YawSpacing.page),
            children: [
              YawSectionHeader(
                title: user == null
                    ? 'Operational overview'
                    : 'Welcome, ${user.name}',
                subtitle: 'Authenticated YAW mobile workspace.',
              ),
              if (state.contextErrorMessage != null) ...[
                YawErrorState(
                  title: 'Context refresh failed',
                  message: state.contextErrorMessage!,
                  action: YawSecondaryButton(
                    label: 'Retry',
                    icon: Icons.refresh,
                    onPressed: widget.authController.refreshIdentityContext,
                  ),
                ),
                const SizedBox(height: YawSpacing.lg),
              ],
              if (state.isContextLoading) ...[
                const YawLoadingState(message: 'Refreshing account context...'),
                const SizedBox(height: YawSpacing.lg),
              ],
              _AccountSummary(user: user),
              const SizedBox(height: YawSpacing.lg),
              _PilotSummary(
                pilot: state.pilot,
                onOpenProfile: state.pilot == null
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              PilotProfileScreen(pilot: state.pilot!),
                        ),
                      ),
              ),
              const SizedBox(height: YawSpacing.lg),
              _OperatorSummary(operators: state.operators),
              const SizedBox(height: YawSpacing.lg),
              _AircraftOperationalSummary(
                state: widget.aircraftController.state,
                onRetry: widget.aircraftController.loadAircraft,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AccountSummary extends StatelessWidget {
  const _AccountSummary({required this.user});

  final YawUser? user;

  @override
  Widget build(BuildContext context) {
    return YawSectionCard(
      title: 'Account',
      subtitle: 'Current authenticated user from /api/v1/me.',
      child: Column(
        children: [
          YawInfoRow(label: 'Name', value: user?.name ?? 'Unavailable'),
          YawInfoRow(
            label: 'Email',
            value: user?.email.isNotEmpty == true ? user!.email : 'Unavailable',
          ),
          YawInfoRow(
            label: 'Role',
            value: _formatToken(user?.role) ?? 'Not supplied',
          ),
        ],
      ),
    );
  }
}

class _PilotSummary extends StatelessWidget {
  const _PilotSummary({required this.pilot, required this.onOpenProfile});

  final YawPilotProfile? pilot;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    if (pilot == null) {
      return const YawEmptyState(
        title: 'Pilot profile required',
        message:
            'This account does not currently have a linked pilot profile. The backend exposes read-only current pilot context, but no mobile self-service profile creation endpoint yet.',
      );
    }

    return YawSectionCard(
      title: 'Pilot identity',
      subtitle: 'Linked profile from /api/v1/me/pilot.',
      action: TextButton(onPressed: onOpenProfile, child: const Text('View')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: YawSpacing.sm,
            runSpacing: YawSpacing.sm,
            children: [
              YawStatusChip(
                label:
                    _formatToken(pilot!.profileStatus) ??
                    'Profile status unknown',
                tone: pilot!.isActive
                    ? YawStatusTone.healthy
                    : YawStatusTone.warning,
              ),
              if (pilot!.medicalStatus != null)
                YawStatusChip(
                  label: 'Medical ${_formatToken(pilot!.medicalStatus)!}',
                  tone: pilot!.medicalStatus == 'valid'
                      ? YawStatusTone.healthy
                      : YawStatusTone.warning,
                ),
            ],
          ),
          const SizedBox(height: YawSpacing.md),
          YawInfoRow(label: 'Display name', value: pilot!.displayName),
          YawInfoRow(
            label: 'RPC category',
            value: _formatToken(pilot!.rpcCategory) ?? 'Not supplied',
          ),
          YawInfoRow(
            label: 'SACAA certificate',
            value: pilot!.sacaaCertificateNumber ?? 'Not supplied',
          ),
        ],
      ),
    );
  }
}

class _OperatorSummary extends StatelessWidget {
  const _OperatorSummary({required this.operators});

  final List<YawOperatorContext> operators;

  @override
  Widget build(BuildContext context) {
    if (operators.isEmpty) {
      return const YawEmptyState(
        title: 'No operator relationship',
        message:
            'No active operator memberships were returned for this account.',
      );
    }

    return YawSectionCard(
      title: 'Operator context',
      subtitle: operators.length == 1
          ? 'One active operator relationship.'
          : '${operators.length} operator relationships available.',
      child: Column(
        children: [
          for (final operator in operators)
            YawListTile(
              title: operator.displayName,
              subtitle: [
                if (operator.uasocNumber != null) operator.uasocNumber!,
                if (operator.membershipRole != null)
                  _formatToken(operator.membershipRole)!,
                if (operator.isGlobal) 'Global access',
              ].join(' · '),
              leading: const Icon(
                Icons.business_outlined,
                color: YawColors.aviationBlue,
              ),
              trailing: YawStatusChip(
                label: _formatToken(operator.membershipStatus) ?? 'Unknown',
                tone: operator.isGlobal
                    ? YawStatusTone.info
                    : YawStatusTone.healthy,
              ),
            ),
        ],
      ),
    );
  }
}

class _AircraftOperationalSummary extends StatelessWidget {
  const _AircraftOperationalSummary({
    required this.state,
    required this.onRetry,
  });

  final AircraftState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.status == AircraftLoadStatus.loading ||
        state.status == AircraftLoadStatus.idle) {
      return const YawLoadingState(message: 'Loading aircraft readiness...');
    }

    if (state.status == AircraftLoadStatus.failure) {
      return YawErrorState(
        title: 'Aircraft summary unavailable',
        message: state.errorMessage ?? 'Aircraft could not be loaded.',
        action: YawSecondaryButton(
          label: 'Retry',
          icon: Icons.refresh,
          onPressed: onRetry,
        ),
      );
    }

    if (state.status == AircraftLoadStatus.empty) {
      return const YawEmptyState(
        title: 'No aircraft assigned',
        message:
            'No mobile aircraft records were returned for this authenticated account.',
      );
    }

    return YawSectionCard(
      title: 'Aircraft readiness',
      subtitle: 'Counts are derived from /api/v1/aircraft readiness results.',
      child: Wrap(
        spacing: YawSpacing.md,
        runSpacing: YawSpacing.md,
        children: [
          _DashboardMetric(
            label: 'Fleet',
            value: '${state.totalAircraft}',
            icon: Icons.flight_outlined,
            tone: YawStatusTone.info,
          ),
          _DashboardMetric(
            label: 'Ready',
            value: '${state.readyAircraft}',
            icon: Icons.check_circle_outline,
            tone: YawStatusTone.healthy,
          ),
          _DashboardMetric(
            label: 'Review',
            value: '${state.reviewAircraft}',
            icon: Icons.warning_amber_outlined,
            tone: YawStatusTone.warning,
          ),
          _DashboardMetric(
            label: 'Blocked',
            value: '${state.blockedAircraft}',
            icon: Icons.block_outlined,
            tone: YawStatusTone.critical,
          ),
        ],
      ),
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  const _DashboardMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
  });

  final String label;
  final String value;
  final IconData icon;
  final YawStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors;

    return SizedBox(
      width: 132,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(YawRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(YawSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colors.foreground),
              const SizedBox(height: YawSpacing.sm),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              Text(label, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
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
