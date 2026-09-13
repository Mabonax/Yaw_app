import 'package:flutter/material.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/widgets/yaw_widgets.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(YawSpacing.page),
      children: const [
        YawSectionHeader(
          title: 'Operational overview',
          subtitle:
              'Foundation shell for API-backed readiness, mission, and compliance summaries.',
        ),
        YawMetricCard(
          label: 'API-backed modules ready for mobile wiring',
          value: '5',
          icon: Icons.api,
          tone: YawStatusTone.info,
        ),
        SizedBox(height: YawSpacing.lg),
        YawSectionCard(
          title: 'Readiness placeholders',
          subtitle: 'No compliance result is calculated on device.',
          child: Column(
            children: [
              YawReadinessIndicator(
                label: 'Pilot readiness',
                value: 0,
                tone: YawStatusTone.info,
              ),
              SizedBox(height: YawSpacing.lg),
              YawReadinessIndicator(
                label: 'Aircraft readiness',
                value: 0,
                tone: YawStatusTone.info,
              ),
            ],
          ),
        ),
        SizedBox(height: YawSpacing.lg),
        YawEmptyState(
          title: 'Dashboard data not connected yet',
          message:
              'The backend currently exposes authentication, current user, aircraft, aircraft catalogue, missions, mission compliance, and post-flight propagation APIs. Dashboard aggregates need a backend endpoint before production data appears here.',
        ),
      ],
    );
  }
}
