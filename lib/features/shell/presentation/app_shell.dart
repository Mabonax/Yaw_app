import 'package:flutter/material.dart';

import '../../../core/auth/auth_controller.dart';
import '../../dashboard/presentation/dashboard_view.dart';
import '../../onboarding/presentation/setup_widgets.dart';
import '../../../core/branding/yaw_logo.dart';
import '../../../core/widgets/yaw_widgets.dart';
import '../../aircraft/presentation/aircraft_controller.dart';
import '../../aircraft/presentation/aircraft_screens.dart';
import '../../dashboard/presentation/home_dashboard_screen.dart';
import '../../missions/presentation/mission_controller.dart';
import '../../missions/presentation/mission_screens.dart';
import 'more_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.authController,
    required this.aircraftController,
    required this.missionController,
  });

  final AuthController authController;
  final AircraftController aircraftController;
  final MissionController missionController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _titles = ['Home', 'Missions', 'Aircraft', 'Compliance', 'More'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: setupBackground,
      appBar: _selectedIndex == 0
          ? null
          : YawAppBar(
              title: _titles[_selectedIndex],
              leading: const Padding(
                padding: EdgeInsets.all(10),
                child: YawLogo(variant: YawLogoVariant.icon),
              ),
              actions: [
                IconButton(
                  tooltip: 'Refresh account context',
                  onPressed: widget.authController.refreshIdentityContext,
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  tooltip: 'Sign out',
                  onPressed: widget.authController.logout,
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
      body: [
        HomeDashboardScreen(
          onNavigate: (index) => setState(() => _selectedIndex = index),
          authController: widget.authController,
          aircraftController: widget.aircraftController,
          missionController: widget.missionController,
        ),
        MissionListScreen(
          controller: widget.missionController,
          aircraftController: widget.aircraftController,
        ),
        AircraftListScreen(controller: widget.aircraftController),
        MissionComplianceOverviewScreen(
          missionController: widget.missionController,
          aircraftController: widget.aircraftController,
        ),
        MoreScreen(authController: widget.authController),
      ][_selectedIndex],
      bottomNavigationBar: YawBottomNavigation(
        index: _selectedIndex,
        onChanged: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
