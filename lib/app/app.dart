import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/auth/auth_controller.dart';
import '../core/auth/auth_repository.dart';
import '../core/config/app_config.dart';
import '../core/storage/token_store.dart';
import '../features/aircraft/data/aircraft_repository.dart';
import '../features/aircraft/presentation/aircraft_controller.dart';
import 'router/yaw_router.dart';
import 'theme/yaw_theme.dart';

class YawApp extends StatelessWidget {
  const YawApp({
    super.key,
    required this.authController,
    required this.aircraftController,
  });

  factory YawApp.create() {
    final config = AppConfig.fromEnvironment();
    final tokenStore = SecureTokenStore();
    final apiClient = ApiClient(
      baseUrl: config.apiBaseUrl,
      tokenProvider: tokenStore.readToken,
      onUnauthorized: tokenStore.clear,
    );

    return YawApp(
      authController: AuthController(
        repository: AuthRepository(apiClient: apiClient),
        tokenStore: tokenStore,
      ),
      aircraftController: AircraftController(
        repository: AircraftRepository(apiClient: apiClient),
      ),
    );
  }

  final AuthController authController;
  final AircraftController aircraftController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YAW',
      debugShowCheckedModeBanner: false,
      theme: YawTheme.light(),
      home: YawRouter(
        authController: authController,
        aircraftController: aircraftController,
      ),
    );
  }
}
