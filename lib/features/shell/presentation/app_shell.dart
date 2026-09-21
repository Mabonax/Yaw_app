import 'package:flutter/material.dart';

import '../../../core/auth/auth_controller.dart';
import '../../dashboard/presentation/dashboard_view.dart';
import '../../onboarding/presentation/setup_widgets.dart';
import '../../../core/branding/yaw_logo.dart';
import '../../../core/widgets/yaw_widgets.dart';
import '../../aircraft/presentation/aircraft_controller.dart';
import '../../aircraft/presentation/aircraft_screens.dart';
import '../../dashboard/presentation/home_dashboard_screen.dart';
import '../../dashboard/presentation/personal_pilot_dashboard_screen.dart';
import '../../missions/presentation/mission_controller.dart';
import '../../missions/presentation/mission_screens.dart';
import '../../operators/presentation/operator_workspace_controller.dart';
import '../../operators/presentation/operator_workspace_screen.dart';
import 'more_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.authController,
    required this.aircraftController,
    required this.missionController,
    required this.operatorWorkspaceController,
  });

  final AuthController authController;
  final AircraftController aircraftController;
  final MissionController missionController;
  final OperatorWorkspaceController operatorWorkspaceController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _titles = ['Home', 'Missions', 'Aircraft', 'Compliance', 'More'];

  Future<void> _switchWorkspace() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OperatorWorkspaceScreen(
          controller: widget.operatorWorkspaceController,
          onSelected: () => Navigator.of(context).pop(),
        ),
      ),
    );
    await Future.wait([
      widget.aircraftController.loadAircraft(refresh: true),
      widget.missionController.loadMissions(refresh: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.operatorWorkspaceController,
      builder: (context, _) {
        final workspace = widget.operatorWorkspaceController.state;
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
                      tooltip: 'Operator workspace',
                      onPressed: _switchWorkspace,
                      icon: const Icon(Icons.business_outlined),
                    ),
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
          body: Column(
            children: [
              if (workspace.activeOperatorName == null)
                Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: InkWell(
                    onTap: _switchWorkspace,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(children: [
                        Icon(Icons.person_outline, size: 18),
                        SizedBox(width: 8),
                        Expanded(child: Text('Personal pilot mode')),
                        Icon(Icons.swap_horiz, size: 18),
                      ]),
                    ),
                  ),
                ),
              if (workspace.activeOperatorName != null)
                Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: InkWell(
                    onTap: _switchWorkspace,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.business_outlined, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              workspace.activeOperatorName!,
                              style: Theme.of(context).textTheme.labelLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.swap_horiz, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: workspace.activeOperatorId == null
                    ? PersonalPilotDashboardScreen(
                        authController: widget.authController,
                        operatorWorkspaceController: widget.operatorWorkspaceController,
                        onWorkspaceChanged: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          setState(() => _selectedIndex = 0);
                        },
                      )
                    : [
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
              ),
            ],
          ),
          bottomNavigationBar: workspace.activeOperatorId == null ? null : YawBottomNavigation(
            index: _selectedIndex,
            onChanged: (index) => setState(() => _selectedIndex = index),
          ),
        );
      },
    );
  }
}
