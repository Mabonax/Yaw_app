import 'package:flutter/material.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/widgets/yaw_widgets.dart';
import '../../aircraft/presentation/aircraft_controller.dart';
import '../../aircraft/presentation/aircraft_screens.dart';
import '../data/mission_models.dart';
import 'mission_controller.dart';

class MissionListScreen extends StatefulWidget {
  const MissionListScreen({
    super.key,
    required this.controller,
    required this.aircraftController,
  });

  final MissionController controller;
  final AircraftController aircraftController;

  @override
  State<MissionListScreen> createState() => _MissionListScreenState();
}

class _MissionListScreenState extends State<MissionListScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.state.status == MissionLoadStatus.idle) {
      widget.controller.loadMissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;

        return RefreshIndicator(
          onRefresh: () => widget.controller.loadMissions(refresh: true),
          child: ListView(
            padding: const EdgeInsets.all(YawSpacing.page),
            children: [
              const YawSectionHeader(
                title: 'Missions',
                subtitle:
                    'Mission planning context and release readiness from /api/v1/missions.',
              ),
              MissionSummaryStrip(state: state),
              const SizedBox(height: YawSpacing.lg),
              if (state.status == MissionLoadStatus.loading) ...[
                const _MissionSkeletonList(),
              ] else if (state.status == MissionLoadStatus.failure) ...[
                YawErrorState(
                  title: 'Missions could not be loaded',
                  message: state.errorMessage ?? 'Try again.',
                  action: YawSecondaryButton(
                    label: 'Retry',
                    icon: Icons.refresh,
                    onPressed: widget.controller.loadMissions,
                  ),
                ),
              ] else if (state.status == MissionLoadStatus.empty) ...[
                const YawEmptyState(
                  title: 'No missions available',
                  message:
                      'The mission endpoint returned no records for this account.',
                ),
              ] else ...[
                for (final mission in state.missions) ...[
                  MissionCard(
                    mission: mission,
                    onTap: () => _openMission(context, mission),
                  ),
                  const SizedBox(height: YawSpacing.md),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _openMission(BuildContext context, YawMission mission) async {
    await widget.controller.loadMissionDetail(mission.id);
    if (!context.mounted) {
      return;
    }

    final selected = widget.controller.state.selectedMission ?? mission;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MissionDetailScreen(
          mission: selected,
          controller: widget.controller,
          aircraftController: widget.aircraftController,
        ),
      ),
    );
  }
}

class MissionDetailScreen extends StatelessWidget {
  const MissionDetailScreen({
    super.key,
    required this.mission,
    required this.controller,
    required this.aircraftController,
  });

  final YawMission mission;
  final MissionController controller;
  final AircraftController aircraftController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YawAppBar(title: mission.displayTitle),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final current = controller.state.selectedMission ?? mission;
          final compliance =
              controller.state.selectedCompliance ?? current.compliance;

          return RefreshIndicator(
            onRefresh: () async {
              await controller.loadMissionDetail(current.id);
            },
            child: ListView(
              padding: const EdgeInsets.all(YawSpacing.page),
              children: [
                MissionHeaderCard(mission: current),
                const SizedBox(height: YawSpacing.lg),
                MissionReleaseBanner(
                  mission: current,
                  compliance: compliance,
                  isReleasing: controller.state.isReleasing,
                  errorMessage: controller.state.releaseErrorMessage,
                  successMessage: controller.state.releaseMessage,
                  onRelease: current.apiReleaseSupported
                      ? controller.releaseSelectedMission
                      : null,
                ),
                const SizedBox(height: YawSpacing.lg),
                MissionOverviewCard(mission: current),
                const SizedBox(height: YawSpacing.lg),
                MissionAircraftCard(
                  mission: current,
                  aircraftController: aircraftController,
                ),
                const SizedBox(height: YawSpacing.lg),
                MissionComplianceCard(compliance: compliance),
                const SizedBox(height: YawSpacing.lg),
                MissionPlanningGapCard(mission: current),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MissionComplianceOverviewScreen extends StatefulWidget {
  const MissionComplianceOverviewScreen({
    super.key,
    required this.missionController,
    required this.aircraftController,
  });

  final MissionController missionController;
  final AircraftController aircraftController;

  @override
  State<MissionComplianceOverviewScreen> createState() =>
      _MissionComplianceOverviewScreenState();
}

class _MissionComplianceOverviewScreenState
    extends State<MissionComplianceOverviewScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.missionController.state.status == MissionLoadStatus.idle) {
      widget.missionController.loadMissions();
    }
    if (widget.aircraftController.state.status == AircraftLoadStatus.idle) {
      widget.aircraftController.loadAircraft();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.missionController,
        widget.aircraftController,
      ]),
      builder: (context, _) {
        final missionState = widget.missionController.state;
        final aircraftState = widget.aircraftController.state;
        final attention = missionState.missions
            .where((mission) => mission.compliance.status != 'green')
            .toList(growable: false);

        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              widget.missionController.loadMissions(refresh: true),
              widget.aircraftController.loadAircraft(refresh: true),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.all(YawSpacing.page),
            children: [
              const YawSectionHeader(
                title: 'Compliance',
                subtitle:
                    'Server-provided mission compliance and aircraft readiness summaries.',
              ),
              MissionSummaryStrip(state: missionState),
              const SizedBox(height: YawSpacing.lg),
              YawSectionCard(
                title: 'Aircraft readiness context',
                subtitle: 'From /api/v1/aircraft readiness results.',
                child: Wrap(
                  spacing: YawSpacing.sm,
                  runSpacing: YawSpacing.sm,
                  children: [
                    YawStatusChip(
                      label: '${aircraftState.readyAircraft} ready',
                      tone: YawStatusTone.healthy,
                    ),
                    YawStatusChip(
                      label: '${aircraftState.reviewAircraft} review',
                      tone: YawStatusTone.warning,
                    ),
                    YawStatusChip(
                      label: '${aircraftState.blockedAircraft} blocked',
                      tone: YawStatusTone.critical,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: YawSpacing.lg),
              if (missionState.status == MissionLoadStatus.loading) ...[
                const YawLoadingState(message: 'Loading mission compliance...'),
              ] else if (missionState.status == MissionLoadStatus.failure) ...[
                YawErrorState(
                  title: 'Mission compliance unavailable',
                  message: missionState.errorMessage ?? 'Try again.',
                  action: YawSecondaryButton(
                    label: 'Retry',
                    icon: Icons.refresh,
                    onPressed: widget.missionController.loadMissions,
                  ),
                ),
              ] else if (attention.isEmpty) ...[
                const YawEmptyState(
                  title: 'No mission compliance attention',
                  message:
                      'Loaded missions do not currently report warning or blocked compliance states.',
                ),
              ] else ...[
                YawSectionCard(
                  title: 'Mission attention queue',
                  subtitle:
                      'Warnings and blockers are reported by MissionComplianceSummary.',
                  child: Column(
                    children: [
                      for (final mission in attention)
                        MissionComplianceTile(mission: mission),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class MissionCard extends StatelessWidget {
  const MissionCard({super.key, required this.mission, this.onTap});

  final YawMission mission;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return YawCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(YawRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.route_outlined, color: YawColors.aviationBlue),
                const SizedBox(width: YawSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.displayTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: YawSpacing.xs),
                      Text(
                        mission.displaySubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: YawColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                YawStatusChip(
                  label:
                      mission.compliance.label ??
                      _format(mission.compliance.status),
                  tone: _toneForStatus(mission.compliance.status),
                  icon: Icons.verified_outlined,
                ),
              ],
            ),
            const SizedBox(height: YawSpacing.md),
            Wrap(
              spacing: YawSpacing.sm,
              runSpacing: YawSpacing.sm,
              children: [
                YawStatusChip(
                  label: mission.lifecycleStatus.label,
                  tone: _toneForLifecycle(mission.lifecycleStatus),
                ),
                if (mission.aircraft != null)
                  YawStatusChip(
                    label: mission.aircraft!.displayName,
                    tone: YawStatusTone.info,
                    icon: Icons.flight_outlined,
                  ),
                if (mission.pilot != null)
                  YawStatusChip(
                    label: mission.pilot!.displayName ?? 'Assigned pilot',
                    tone: YawStatusTone.info,
                    icon: Icons.person_outline,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MissionHeaderCard extends StatelessWidget {
  const MissionHeaderCard({super.key, required this.mission});

  final YawMission mission;

  @override
  Widget build(BuildContext context) {
    return YawCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mission.displayTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: YawSpacing.xs),
          Text(
            mission.displaySubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: YawColors.textMuted),
          ),
          const SizedBox(height: YawSpacing.md),
          Wrap(
            spacing: YawSpacing.sm,
            runSpacing: YawSpacing.sm,
            children: [
              YawStatusChip(
                label: mission.lifecycleStatus.label,
                tone: _toneForLifecycle(mission.lifecycleStatus),
              ),
              YawStatusChip(
                label:
                    mission.compliance.label ??
                    _format(mission.compliance.status),
                tone: _toneForStatus(mission.compliance.status),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MissionOverviewCard extends StatelessWidget {
  const MissionOverviewCard({super.key, required this.mission});

  final YawMission mission;

  @override
  Widget build(BuildContext context) {
    return YawSectionCard(
      title: 'Mission overview',
      subtitle: 'Planning context returned by the mission presenter.',
      child: Column(
        children: [
          YawInfoRow(
            label: 'Purpose',
            value: mission.purpose ?? 'Not supplied',
          ),
          YawInfoRow(
            label: 'Client/project',
            value: mission.clientProject ?? 'Not supplied',
          ),
          YawInfoRow(
            label: 'Location',
            value: mission.location ?? 'Not supplied',
          ),
          YawInfoRow(
            label: 'Planned start',
            value: mission.plannedStartAt ?? 'Not supplied',
          ),
          YawInfoRow(
            label: 'Planned end',
            value: mission.plannedEndAt ?? 'Not supplied',
          ),
          YawInfoRow(
            label: 'Operation',
            value: _joinPresent([
              _format(mission.operationCategory),
              _format(mission.operationVisibility),
              _format(mission.dayNight),
            ]),
          ),
          YawInfoRow(
            label: 'Operator',
            value: mission.operator?.legalEntity ?? 'Not supplied',
          ),
          YawInfoRow(
            label: 'Pilot',
            value: mission.pilot?.displayName ?? 'Not supplied',
          ),
        ],
      ),
    );
  }
}

class MissionAircraftCard extends StatelessWidget {
  const MissionAircraftCard({
    super.key,
    required this.mission,
    required this.aircraftController,
  });

  final YawMission mission;
  final AircraftController aircraftController;

  @override
  Widget build(BuildContext context) {
    final aircraft = mission.aircraft;
    final aircraftControls = mission.compliance.controls
        .where((control) => control.key == 'aircraft_readiness')
        .toList(growable: false);
    final aircraftControl = aircraftControls.isEmpty
        ? null
        : aircraftControls.first;

    if (aircraft == null) {
      return const YawEmptyState(
        title: 'No aircraft assigned',
        message: 'Mission compliance reports no assigned aircraft.',
      );
    }

    return YawSectionCard(
      title: 'Aircraft',
      subtitle: 'Mission aircraft and server-calculated readiness context.',
      action: TextButton(
        onPressed: () => _openAircraft(context, aircraft.id),
        child: const Text('View'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YawInfoRow(
            label: 'Registration',
            value: aircraft.registration ?? 'Not supplied',
          ),
          YawInfoRow(label: 'Model', value: aircraft.model ?? 'Not supplied'),
          if (aircraftControl != null) ...[
            const SizedBox(height: YawSpacing.md),
            YawStatusChip(
              label: aircraftControl.summary ?? _format(aircraftControl.status),
              tone: _toneForStatus(aircraftControl.status),
              icon: Icons.flight_takeoff_outlined,
            ),
            for (final reason in aircraftControl.reasons)
              Padding(
                padding: const EdgeInsets.only(top: YawSpacing.sm),
                child: Text(reason),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _openAircraft(BuildContext context, int aircraftId) async {
    await aircraftController.loadAircraftDetail(aircraftId);
    if (!context.mounted) {
      return;
    }

    final aircraft = aircraftController.state.selectedAircraft;
    if (aircraft == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aircraft detail could not be loaded.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AircraftDetailScreen(aircraft: aircraft),
      ),
    );
  }
}

class MissionComplianceCard extends StatelessWidget {
  const MissionComplianceCard({super.key, required this.compliance});

  final YawMissionCompliance compliance;

  @override
  Widget build(BuildContext context) {
    return YawSectionCard(
      title: 'Mission compliance',
      subtitle: compliance.evaluatedAt == null
          ? 'Server-calculated release controls.'
          : 'Server-calculated at ${compliance.evaluatedAt}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YawReadinessIndicator(
            label: compliance.label ?? _format(compliance.status),
            value: compliance.completionRatio,
            tone: _toneForStatus(compliance.status),
          ),
          const SizedBox(height: YawSpacing.md),
          Wrap(
            spacing: YawSpacing.sm,
            runSpacing: YawSpacing.sm,
            children: [
              YawStatusChip(
                label: '${compliance.blockingCount} blockers',
                tone: compliance.blockingCount > 0
                    ? YawStatusTone.critical
                    : YawStatusTone.healthy,
              ),
              YawStatusChip(
                label: '${compliance.warningCount} warnings',
                tone: compliance.warningCount > 0
                    ? YawStatusTone.warning
                    : YawStatusTone.healthy,
              ),
            ],
          ),
          const SizedBox(height: YawSpacing.md),
          for (final control in compliance.controls)
            MissionComplianceControlTile(control: control),
        ],
      ),
    );
  }
}

class MissionComplianceControlTile extends StatelessWidget {
  const MissionComplianceControlTile({super.key, required this.control});

  final YawMissionComplianceControl control;

  @override
  Widget build(BuildContext context) {
    return YawListTile(
      title: control.label ?? _format(control.key),
      subtitle: _joinPresent([
        control.summary,
        if (control.reasons.isNotEmpty) control.reasons.join(' · '),
      ]),
      leading: Icon(
        _iconForStatus(control.status),
        color: _toneForStatus(control.status).colors.foreground,
      ),
      trailing: YawStatusChip(
        label: _format(control.status),
        tone: _toneForStatus(control.status),
      ),
    );
  }
}

class MissionReleaseBanner extends StatelessWidget {
  const MissionReleaseBanner({
    super.key,
    required this.mission,
    required this.compliance,
    required this.isReleasing,
    this.errorMessage,
    this.successMessage,
    this.onRelease,
  });

  final YawMission mission;
  final YawMissionCompliance compliance;
  final bool isReleasing;
  final String? errorMessage;
  final String? successMessage;
  final Future<bool> Function()? onRelease;

  @override
  Widget build(BuildContext context) {
    final apiSupported = mission.apiReleaseSupported;
    final blocked = compliance.isBlocked;

    return YawSectionCard(
      title: 'Release readiness',
      subtitle:
          'Flutter presents server readiness; Laravel remains authoritative for release.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YawStatusChip(
            label: compliance.label ?? _format(compliance.status),
            tone: _toneForStatus(compliance.status),
            icon: Icons.verified_outlined,
          ),
          const SizedBox(height: YawSpacing.md),
          Text(
            apiSupported
                ? 'Release is available through API V1 and will be revalidated by the server.'
                : 'Mission release exists in the Laravel web workflow, but API V1 does not expose POST /api/v1/missions/{mission}/release yet.',
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: YawSpacing.md),
            Text(
              errorMessage!,
              style: const TextStyle(color: YawColors.critical),
            ),
          ],
          if (successMessage != null) ...[
            const SizedBox(height: YawSpacing.md),
            Text(
              successMessage!,
              style: const TextStyle(color: YawColors.healthy),
            ),
          ],
          const SizedBox(height: YawSpacing.lg),
          YawPrimaryButton(
            label: apiSupported ? 'Release Mission' : 'Release API required',
            icon: Icons.flight_takeoff_outlined,
            isLoading: isReleasing,
            onPressed:
                apiSupported && !blocked && !isReleasing && onRelease != null
                ? () => onRelease!.call()
                : null,
          ),
        ],
      ),
    );
  }
}

class MissionPlanningGapCard extends StatelessWidget {
  const MissionPlanningGapCard({super.key, required this.mission});

  final YawMission mission;

  @override
  Widget build(BuildContext context) {
    return const YawSectionCard(
      title: 'Planning actions',
      subtitle:
          'API V1 currently exposes mission visibility, not planning writes.',
      child: Text(
        'Mission creation, editing, aircraft selection, pilot selection, and operator selection remain backend API gaps for mobile. Existing mission data is displayed read-only.',
      ),
    );
  }
}

class MissionSummaryStrip extends StatelessWidget {
  const MissionSummaryStrip({super.key, required this.state});

  final MissionState state;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: YawSpacing.md,
      runSpacing: YawSpacing.md,
      children: [
        _SummaryPill(
          icon: Icons.route_outlined,
          label: 'Missions',
          value: '${state.totalMissions}',
          tone: YawStatusTone.info,
        ),
        _SummaryPill(
          icon: Icons.check_circle_outline,
          label: 'Ready',
          value: '${state.readyMissions}',
          tone: YawStatusTone.healthy,
        ),
        _SummaryPill(
          icon: Icons.warning_amber_outlined,
          label: 'Warning',
          value: '${state.warningMissions}',
          tone: YawStatusTone.warning,
        ),
        _SummaryPill(
          icon: Icons.block_outlined,
          label: 'Blocked',
          value: '${state.blockedMissions}',
          tone: YawStatusTone.critical,
        ),
      ],
    );
  }
}

class MissionComplianceTile extends StatelessWidget {
  const MissionComplianceTile({super.key, required this.mission});

  final YawMission mission;

  @override
  Widget build(BuildContext context) {
    return YawListTile(
      title: mission.displayTitle,
      subtitle: mission.compliance.label,
      leading: Icon(
        _iconForStatus(mission.compliance.status),
        color: _toneForStatus(mission.compliance.status).colors.foreground,
      ),
      trailing: YawStatusChip(
        label: _format(mission.compliance.status),
        tone: _toneForStatus(mission.compliance.status),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final YawStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors;

    return Container(
      width: 152,
      padding: const EdgeInsets.all(YawSpacing.md),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(YawRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.foreground),
          const SizedBox(width: YawSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleMedium),
                Text(label, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionSkeletonList extends StatelessWidget {
  const _MissionSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < 3; index++) ...[
          const YawCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                YawSkeleton(height: 24, width: 220),
                SizedBox(height: YawSpacing.md),
                YawSkeleton(height: 16, width: 180),
                SizedBox(height: YawSpacing.md),
                YawSkeleton(height: 36),
              ],
            ),
          ),
          const SizedBox(height: YawSpacing.md),
        ],
      ],
    );
  }
}

String _format(String? value) {
  if (value == null || value.isEmpty) {
    return 'Not supplied';
  }
  return value
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _joinPresent(List<String?> values) {
  final parts = values
      .where(
        (value) => value != null && value.isNotEmpty && value != 'Not supplied',
      )
      .cast<String>()
      .toList();
  return parts.isEmpty ? 'Not supplied' : parts.join(' · ');
}

YawStatusTone _toneForStatus(String? status) {
  return switch (status) {
    'green' => YawStatusTone.healthy,
    'amber' => YawStatusTone.warning,
    'red' => YawStatusTone.critical,
    _ => YawStatusTone.info,
  };
}

YawStatusTone _toneForLifecycle(YawMissionLifecycleStatus status) {
  return switch (status) {
    YawMissionLifecycleStatus.readyForFlight ||
    YawMissionLifecycleStatus.inProgress ||
    YawMissionLifecycleStatus.completed ||
    YawMissionLifecycleStatus.closed => YawStatusTone.healthy,
    YawMissionLifecycleStatus.cancelled => YawStatusTone.critical,
    YawMissionLifecycleStatus.approved ||
    YawMissionLifecycleStatus.awaitingApproval ||
    YawMissionLifecycleStatus.complianceReview => YawStatusTone.warning,
    _ => YawStatusTone.info,
  };
}

IconData _iconForStatus(String? status) {
  return switch (status) {
    'green' => Icons.check_circle_outline,
    'amber' => Icons.warning_amber_outlined,
    'red' => Icons.error_outline,
    _ => Icons.info_outline,
  };
}
