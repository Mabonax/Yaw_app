import 'package:flutter/material.dart';
import '../../../core/auth/auth_controller.dart';
import '../../aircraft/presentation/aircraft_controller.dart';
import '../../missions/data/mission_models.dart';
import '../../missions/presentation/mission_controller.dart';
import '../../pilot/presentation/pilot_profile_screen.dart';
import '../../onboarding/presentation/setup_widgets.dart';
import '../../onboarding/data/registration_draft.dart';
import 'dashboard_view.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    super.key,
    required this.authController,
    required this.aircraftController,
    required this.missionController,
    this.onNavigate,
  });
  final AuthController authController;
  final AircraftController aircraftController;
  final MissionController missionController;
  final ValueChanged<int>? onNavigate;
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
    if (widget.missionController.state.status == MissionLoadStatus.idle) {
      widget.missionController.loadMissions();
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      widget.authController.refreshIdentityContext(),
      widget.aircraftController.loadAircraft(refresh: true),
      widget.missionController.loadMissions(refresh: true),
    ]);
  }

  void _action(int index) {
    if (index == 2) {
      final pilot = widget.authController.state.pilot;
      if (pilot == null) {
        _info(
          'Pilot Profile',
          'Your account does not have a pilot profile yet. Contact your operator to complete your profile.',
        );
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PilotProfileScreen(pilot: pilot),
        ),
      );
      return;
    }
    widget.onNavigate?.call(switch (index) {
      0 => 1,
      1 => 2,
      _ => 3,
    });
  }

  void _info(String title, String message) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
  void _account() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(widget.authController.state.user?.name ?? 'My Account'),
            subtitle: Text(widget.authController.state.user?.email ?? ''),
            leading: const Icon(Icons.person_outline),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh account context'),
            onTap: () {
              Navigator.pop(context);
              _refresh();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () {
              Navigator.pop(context);
              widget.authController.logout();
            },
          ),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([
      widget.authController,
      widget.aircraftController,
      widget.missionController,
    ]),
    builder: (context, _) {
      final auth = widget.authController.state;
      final aircraft = widget.aircraftController.state;
      final missions = widget.missionController.state;
      final now = DateTime.now();
      final upcoming =
          missions.missions.where((m) {
              final date = DateTime.tryParse(m.plannedStartAt ?? '');
              return date != null &&
                  !date.isBefore(now) &&
                  ![
                    YawMissionLifecycleStatus.cancelled,
                    YawMissionLifecycleStatus.closed,
                    YawMissionLifecycleStatus.completed,
                  ].contains(m.lifecycleStatus);
            }).toList()
            ..sort((a, b) => a.plannedStartAt!.compareTo(b.plannedStartAt!));
      final recent =
          missions.missions.where((m) => m.createdAt != null).toList()
            ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      final errors = [
        auth.contextErrorMessage,
        aircraft.errorMessage,
        missions.errorMessage,
      ].whereType<String>().toList();
      return RefreshIndicator(
        onRefresh: _refresh,
        child: DashboardView(
          name: auth.user?.name ?? 'Pilot',
          aircraftCount:
              [
                AircraftLoadStatus.loaded,
                AircraftLoadStatus.empty,
              ].contains(aircraft.status)
              ? '${aircraft.totalAircraft}'
              : '—',
          missionCount:
              [
                MissionLoadStatus.loaded,
                MissionLoadStatus.empty,
              ].contains(missions.status)
              ? '${missions.missions.where((m) => [YawMissionLifecycleStatus.planning, YawMissionLifecycleStatus.approved, YawMissionLifecycleStatus.readyForFlight].contains(m.lifecycleStatus)).length}'
              : '—',
          loading:
              auth.isContextLoading ||
              aircraft.status == AircraftLoadStatus.loading ||
              missions.status == MissionLoadStatus.loading,
          notice: errors.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SetupCard(
                    child: Column(
                      children: [
                        Text(
                          errors.join('\n'),
                          style: setupText(10, color: Colors.red.shade700),
                        ),
                        TextButton(
                          onPressed: _refresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
          activity: [
            for (final m in recent.take(4))
              DashboardEntry(
                'Mission added',
                m.displayTitle,
                Icons.map_outlined,
                trailing: formatSetupDate(DateTime.tryParse(m.createdAt ?? '')),
              ),
          ],
          upcoming: [
            for (final m in upcoming.take(3))
              DashboardEntry(
                formatSetupDate(DateTime.tryParse(m.plannedStartAt ?? '')),
                m.displaySubtitle,
                Icons.calendar_month_outlined,
              ),
          ],
          onAction: _action,
          onAccount: _account,
          onNotifications: () => _info(
            'Notifications',
            'Your notifications will appear here when the notification service is available.',
          ),
          onLearnMore: () => _info(
            'Smarter Operations. Safer Skies.',
            'Plan missions, manage aircraft and review compliance from your YAW workspace. Pull down on Home to refresh your operational information.',
          ),
        ),
      );
    },
  );
}
