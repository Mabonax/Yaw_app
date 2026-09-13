import 'package:flutter/material.dart';

import '../../core/auth/auth_controller.dart';
import '../../features/aircraft/presentation/aircraft_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/shell/presentation/app_shell.dart';

class YawRouter extends StatefulWidget {
  const YawRouter({
    super.key,
    required this.authController,
    required this.aircraftController,
  });

  final AuthController authController;
  final AircraftController aircraftController;

  @override
  State<YawRouter> createState() => _YawRouterState();
}

class _YawRouterState extends State<YawRouter> {
  @override
  void initState() {
    super.initState();
    widget.authController.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authController,
      builder: (context, _) {
        final state = widget.authController.state;

        return switch (state.status) {
          AuthStatus.bootstrapping => const SplashScreen(),
          AuthStatus.authenticated => AppShell(
            authController: widget.authController,
            aircraftController: widget.aircraftController,
          ),
          AuthStatus.unauthenticated || AuthStatus.failure => LoginScreen(
            authController: widget.authController,
          ),
        };
      },
    );
  }
}
