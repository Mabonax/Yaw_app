import 'package:flutter/material.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/widgets/yaw_widgets.dart';
import '../../aircraft/presentation/aircraft_controller.dart';
import '../../missions/presentation/mission_controller.dart';

class OperatorActionCentreScreen extends StatelessWidget {
  const OperatorActionCentreScreen({
    super.key,
    required this.aircraftController,
    required this.missionController,
  });

  final AircraftController aircraftController;
  final MissionController missionController;

  @override
  Widget build(BuildContext context) {
    final items = <_OperatorActionItem>[];

    for (final mission in missionController.state.missions) {
      final next = mission.journey.nextAction;
      if (next == null) continue;
      final status = mission.journey.readiness['status']?.toString();
      items.add(_OperatorActionItem(
        title: '${mission.displayTitle}: ${next['label'] ?? 'Mission action'}',
        summary: next['summary']?.toString() ?? mission.compliance.label ?? 'Mission review required.',
        critical: status == 'red',
        entity: 'Mission',
      ));
    }

    for (final aircraft in aircraftController.state.aircraft) {
      final readiness = aircraft.readiness;
      if (readiness == null) continue;
      for (final check in readiness.checks.where((check) => check.status == 'red' || check.status == 'amber')) {
        items.add(_OperatorActionItem(
          title: '${aircraft.registration ?? aircraft.displayName}: ${check.label ?? 'Readiness'}',
          summary: check.summary ?? 'Aircraft readiness requires review.',
          critical: check.status == 'red',
          entity: 'Aircraft',
        ));
      }
    }

    items.sort((a, b) {
      if (a.critical == b.critical) return a.title.compareTo(b.title);
      return a.critical ? -1 : 1;
    });

    final critical = items.where((item) => item.critical).length;

    return Scaffold(
      appBar: const YawAppBar(title: 'Action Centre'),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            aircraftController.loadAircraft(refresh: true),
            missionController.loadMissions(refresh: true),
          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(YawSpacing.page),
          children: [
            const YawSectionHeader(
              title: 'Operator actions',
              subtitle: 'Prioritised from mission compliance and aircraft readiness returned by the YAW server.',
            ),
            const SizedBox(height: YawSpacing.lg),
            Wrap(
              spacing: YawSpacing.sm,
              runSpacing: YawSpacing.sm,
              children: [
                YawStatusChip(
                  label: '${critical} critical',
                  tone: critical > 0 ? YawStatusTone.critical : YawStatusTone.healthy,
                ),
                YawStatusChip(
                  label: '${items.length - critical} warning',
                  tone: items.length > critical ? YawStatusTone.warning : YawStatusTone.healthy,
                ),
                YawStatusChip(label: '${items.length} total', tone: YawStatusTone.info),
              ],
            ),
            const SizedBox(height: YawSpacing.lg),
            if (items.isEmpty)
              const YawEmptyState(
                title: 'No outstanding operator actions',
                message: 'Loaded missions and aircraft currently report no warning or blocked readiness states.',
              )
            else
              for (final item in items) ...[
                YawCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.critical ? Icons.error_outline : Icons.warning_amber_outlined),
                      const SizedBox(width: YawSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(item.title, style: Theme.of(context).textTheme.titleSmall)),
                                YawStatusChip(
                                  label: item.critical ? 'critical' : 'warning',
                                  tone: item.critical ? YawStatusTone.critical : YawStatusTone.warning,
                                ),
                              ],
                            ),
                            const SizedBox(height: YawSpacing.xs),
                            Text(item.summary, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: YawColors.textMuted)),
                            const SizedBox(height: YawSpacing.xs),
                            Text(item.entity, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: YawColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: YawSpacing.sm),
              ],
          ],
        ),
      ),
    );
  }
}

class _OperatorActionItem {
  const _OperatorActionItem({
    required this.title,
    required this.summary,
    required this.critical,
    required this.entity,
  });

  final String title;
  final String summary;
  final bool critical;
  final String entity;
}
