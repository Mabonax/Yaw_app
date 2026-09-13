import 'package:flutter/material.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/widgets/yaw_widgets.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _modules = [
    (
      'Pilot Profile',
      'Current user pilot profile API is available.',
      Icons.badge_outlined,
    ),
    (
      'Operators',
      'Current user operator context API is available.',
      Icons.business_outlined,
    ),
    (
      'Logbook',
      'Backend domain exists; mobile API endpoint is missing.',
      Icons.menu_book_outlined,
    ),
    (
      'Defects',
      'Backend domain exists; mobile API endpoint is missing.',
      Icons.report_problem_outlined,
    ),
    (
      'GIS Projects',
      'Backend domain exists; mobile API endpoint is missing.',
      Icons.map_outlined,
    ),
    (
      'Regulatory',
      'Backend domain exists; mobile API endpoint is missing.',
      Icons.policy_outlined,
    ),
    (
      'Notifications',
      'Backend domain exists; mobile API endpoint is missing.',
      Icons.notifications_outlined,
    ),
    (
      'Settings',
      'Account settings endpoint is not exposed yet.',
      Icons.settings_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(YawSpacing.page),
      children: [
        const YawSectionHeader(
          title: 'Modules',
          subtitle:
              'Secondary operations are grouped here until dedicated mobile APIs are available.',
        ),
        YawCard(
          padding: const EdgeInsets.symmetric(vertical: YawSpacing.sm),
          child: Column(
            children: [
              for (final module in _modules)
                YawListTile(
                  title: module.$1,
                  subtitle: module.$2,
                  leading: Icon(module.$3, color: YawColors.aviationBlue),
                  onTap: () {},
                ),
            ],
          ),
        ),
      ],
    );
  }
}
