import 'package:flutter/material.dart';

import '../../core/auth/auth_controller.dart';
import '../../features/aircraft/presentation/aircraft_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/onboarding/data/registration_draft.dart';
import '../../features/onboarding/presentation/pilot_setup_flow.dart';
import '../../features/missions/presentation/mission_controller.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/operators/presentation/operator_workspace_controller.dart';
import '../../features/operators/presentation/operator_workspace_screen.dart';

class YawRouter extends StatefulWidget {
  const YawRouter({
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
  State<YawRouter> createState() => _YawRouterState();
}

enum _AuthEntryScreen { onboarding, login, register, role, setup }

class _YawRouterState extends State<YawRouter> {
  _AuthEntryScreen _entryScreen = _AuthEntryScreen.onboarding;

  final RegistrationDraft _draft = RegistrationDraft();

  int? _sessionUserId;
  int _sessionNumber = 0;
  AircraftController? _sessionAircraft;
  MissionController? _sessionMissions;
  bool _workspaceLoaded = false;

  void _syncSession() {
    final state = widget.authController.state;
    final userId = state.isAuthenticated ? state.user!.id : null;
    if (_sessionUserId == userId) return;
    _sessionUserId = userId;
    _sessionNumber++;
    _sessionAircraft?.dispose();
    _sessionMissions?.dispose();
    _sessionAircraft = userId == null
        ? null
        : widget.aircraftController.forSession();
    _sessionMissions = userId == null
        ? null
        : widget.missionController.forSession();
    _workspaceLoaded = false;
    if (userId != null) {
      widget.operatorWorkspaceController.load().then((_) {
        if (mounted) setState(() => _workspaceLoaded = true);
      });
    }
  }

  @override
  void dispose() {
    widget.authController.removeListener(_syncSession);
    _sessionAircraft?.dispose();
    _sessionMissions?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.authController.addListener(_syncSession);
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
          AuthStatus.authenticated => !_workspaceLoaded
              ? const SplashScreen()
              : ListenableBuilder(
                  listenable: widget.operatorWorkspaceController,
                  builder: (context, _) {
                    final workspace = widget.operatorWorkspaceController.state;
                    if (workspace.status == OperatorWorkspaceStatus.selectionRequired) {
                      return OperatorWorkspaceScreen(
                        controller: widget.operatorWorkspaceController,
                        onSelected: () => setState(() => _sessionNumber++),
                      );
                    }
                    return Navigator(
                      key: ValueKey(_sessionNumber),
                      onGenerateRoute: (_) => MaterialPageRoute<void>(
                        builder: (_) => AppShell(
                          authController: widget.authController,
                          aircraftController: _sessionAircraft!,
                          missionController: _sessionMissions!,
                          operatorWorkspaceController: widget.operatorWorkspaceController,
                        ),
                      ),
                    );
                  },
                ),
          AuthStatus.failure || AuthStatus.unauthenticated =>
            switch (state.status == AuthStatus.failure &&
                    _entryScreen == _AuthEntryScreen.onboarding
                ? _AuthEntryScreen.login
                : _entryScreen) {
              _AuthEntryScreen.onboarding => OnboardingScreen(
                onSignIn: () =>
                    setState(() => _entryScreen = _AuthEntryScreen.login),
              ),
              _AuthEntryScreen.login => LoginScreen(
                authController: widget.authController,
                onCreateAccount: () =>
                    setState(() => _entryScreen = _AuthEntryScreen.register),
              ),
              _AuthEntryScreen.register => RegisterScreen(
                authController: widget.authController,
                onBack: () =>
                    setState(() => _entryScreen = _AuthEntryScreen.onboarding),
                onSignIn: () =>
                    setState(() => _entryScreen = _AuthEntryScreen.login),
              ),
              _AuthEntryScreen.setup => PilotSetupFlow(
                draft: _draft,
                onBack: () =>
                    setState(() => _entryScreen = _AuthEntryScreen.role),
                onSignIn: () =>
                    setState(() => _entryScreen = _AuthEntryScreen.login),
              ),
              _AuthEntryScreen.role => RoleSelectionScreen(
                onContinue: (role) {
                  setState(() {
                    _draft.role = role.title;
                    _entryScreen = _AuthEntryScreen.setup;
                  });
                },
              ),
            },
        };
      },
    );
  }
}
