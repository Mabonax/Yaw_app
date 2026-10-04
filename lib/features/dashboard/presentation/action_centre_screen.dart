import 'package:flutter/material.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_models.dart';
import '../../../core/widgets/yaw_widgets.dart';
import '../../aircraft/presentation/aircraft_controller.dart';
import '../../missions/presentation/mission_controller.dart';

class ActionCentreScreen extends StatelessWidget {
  const ActionCentreScreen({
    super.key,
    required this.authController,
    required this.aircraftController,
    required this.missionController,
  });

  final AuthController authController;
  final AircraftController aircraftController;
  final MissionController missionController;

  @override
  Widget build(BuildContext context) {
    final items = _items();
    final critical = items.where((item) => item.priority == _ActionPriority.critical).length;
    final warning = items.where((item) => item.priority == _ActionPriority.warning).length;

    return Scaffold(
      appBar: const YawAppBar(title: 'Action Centre'),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            authController.refreshIdentityContext(),
            aircraftController.loadAircraft(refresh: true),
            missionController.loadMissions(refresh: true),
          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(YawSpacing.page),
          children: [
            const YawSectionHeader(
              title: 'Operational actions',
              subtitle: 'Prioritised from server-provided pilot, mission and aircraft readiness states.',
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
                  label: '${warning} warning',
                  tone: warning > 0 ? YawStatusTone.warning : YawStatusTone.healthy,
                ),
                YawStatusChip(
                  label: '${items.length} total',
                  tone: YawStatusTone.info,
                ),
              ],
            ),
            const SizedBox(height: YawSpacing.lg),
            if (items.isEmpty)
              const YawEmptyState(
                title: 'No outstanding actions',
                message: 'The currently loaded server readiness states do not require attention.',
              )
            else
              for (final item in items) ...[
                _ActionTile(item: item),
                const SizedBox(height: YawSpacing.sm),
              ],
          ],
        ),
      ),
    );
  }

  List<_ActionItem> _items() {
    final serverItems = authController.state.experience?.actionCentre.items ?? const <YawActionItem>[];

    return serverItems
        .map((item) => _ActionItem(
              title: item.title,
              summary: item.summary,
              priority: switch (item.priority) {
                'critical' => _ActionPriority.critical,
                'warning' => _ActionPriority.warning,
                _ => _ActionPriority.info,
              },
              entity: item.entityType.replaceAll('_', ' '),
            ))
        .toList(growable: false);
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.item});

  final _ActionItem item;

  @override
  Widget build(BuildContext context) {
    final tone = switch (item.priority) {
      _ActionPriority.critical => YawStatusTone.critical,
      _ActionPriority.warning => YawStatusTone.warning,
      _ActionPriority.info => YawStatusTone.info,
    };

    return YawCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.priority == _ActionPriority.critical
                ? Icons.error_outline
                : item.priority == _ActionPriority.warning
                    ? Icons.warning_amber_outlined
                    : Icons.info_outline,
          ),
          const SizedBox(width: YawSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(item.title, style: Theme.of(context).textTheme.titleSmall)),
                    YawStatusChip(label: item.priority.name, tone: tone),
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
    );
  }
}

enum _ActionPriority { critical, warning, info }

class _ActionItem {
  const _ActionItem({
    required this.title,
    required this.summary,
    required this.priority,
    required this.entity,
  });

  final String title;
  final String summary;
  final _ActionPriority priority;
  final String entity;
}
