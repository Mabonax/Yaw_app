import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/auth/auth_controller.dart';
import '../core/auth/auth_repository.dart';
import '../core/config/app_config.dart';
import '../core/storage/token_store.dart';
import '../core/storage/operator_store.dart';
import '../features/operators/data/operator_workspace_repository.dart';
import '../features/operators/presentation/operator_workspace_controller.dart';
import '../features/aircraft/data/aircraft_repository.dart';
import '../features/aircraft/presentation/aircraft_controller.dart';
import '../features/auth/presentation/auth_visuals.dart';
import '../features/missions/data/mission_repository.dart';
import '../features/missions/presentation/mission_controller.dart';
import 'router/yaw_router.dart';
import 'theme/yaw_theme.dart';

class YawApp extends StatelessWidget {
  const YawApp({
    super.key,
    required this.authController,
    required this.aircraftController,
    required this.missionController,
    required this.operatorWorkspaceController,
  });

  factory YawApp.create() {
    final config = AppConfig.fromEnvironment();
    final tokenStore = SecureTokenStore();
    final operatorStore = SecureOperatorStore();
    final apiClient = ApiClient(
      baseUrl: config.apiBaseUrl,
      tokenProvider: tokenStore.readToken,
      operatorProvider: operatorStore.readOperatorId,
      onUnauthorized: () async {
        await tokenStore.clear();
        await operatorStore.clear();
      },
    );

    return YawApp(
      authController: AuthController(
        repository: AuthRepository(apiClient: apiClient),
        tokenStore: tokenStore,
      ),
      aircraftController: AircraftController(
        repository: AircraftRepository(apiClient: apiClient),
      ),
      missionController: MissionController(
        repository: MissionRepository(apiClient: apiClient),
      ),
      operatorWorkspaceController: OperatorWorkspaceController(
        repository: OperatorWorkspaceRepository(apiClient: apiClient),
        store: operatorStore,
      ),
    );
  }

  final AuthController authController;
  final AircraftController aircraftController;
  final MissionController missionController;
  final OperatorWorkspaceController operatorWorkspaceController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YAW',
      debugShowCheckedModeBanner: false,
      theme: YawTheme.light(),
      scrollBehavior: const AuthNoStretchScrollBehavior(),
      home: YawRouter(
        authController: authController,
        aircraftController: aircraftController,
        missionController: missionController,
        operatorWorkspaceController: operatorWorkspaceController,
      ),
    );
  }
}
