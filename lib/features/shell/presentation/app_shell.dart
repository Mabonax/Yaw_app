import 'package:flutter/material.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/widgets/yaw_widgets.dart';
import '../../dashboard/presentation/home_dashboard_screen.dart';
import 'more_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.authController});

  final AuthController authController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _titles = ['Home', 'Missions', 'Aircraft', 'Compliance', 'More'];

  @override
  Widget build(BuildContext context) {
    return YawScaffold(
      appBar: YawAppBar(
        title: _titles[_selectedIndex],
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: widget.authController.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeDashboardScreen(),
          _ModuleShell(
            title: 'Missions',
            message:
                'Mission list and compliance detail can be wired to /api/v1/missions.',
            icon: Icons.route,
          ),
          _ModuleShell(
            title: 'Aircraft',
            message:
                'Aircraft and aircraft catalogue APIs are available for the next slice.',
            icon: Icons.airplanemode_active,
          ),
          _ModuleShell(
            title: 'Compliance',
            message:
                'Mission compliance exists by mission. Broader compliance endpoints are backend gaps.',
            icon: Icons.fact_check_outlined,
          ),
          MoreScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.route_outlined),
            label: 'Missions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight_outlined),
            label: 'Aircraft',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_outlined),
            label: 'Compliance',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }
}

class _ModuleShell extends StatelessWidget {
  const _ModuleShell({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return YawEmptyState(title: title, message: message, action: Icon(icon));
  }
}
