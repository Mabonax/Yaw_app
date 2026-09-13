import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yaw_app/app/app.dart';
import 'package:yaw_app/core/api/api_client.dart';
import 'package:yaw_app/core/auth/auth_controller.dart';
import 'package:yaw_app/core/auth/auth_repository.dart';
import 'package:yaw_app/core/storage/token_store.dart';

void main() {
  testWidgets('shows login validation before authentication', (tester) async {
    final app = _appWithToken(null);

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text('Sign in to YAW'), findsOneWidget);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });

  testWidgets('routes authenticated users into the application shell', (
    tester,
  ) async {
    final app = _appWithToken('existing-token');

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.text('Operational overview'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    expect(find.text('Modules'), findsOneWidget);
    expect(find.text('Pilot Profile'), findsOneWidget);
  });
}

YawApp _appWithToken(String? token) {
  final tokenStore = MemoryTokenStore();
  if (token != null) {
    tokenStore.saveToken(token);
  }

  final apiClient = ApiClient(
    baseUrl: Uri.parse('https://example.test/api/v1'),
    tokenProvider: tokenStore.readToken,
    onUnauthorized: tokenStore.clear,
    httpClient: MockClient((request) async {
      return http.Response(
        jsonEncode({
          'success': true,
          'message': null,
          'data': {},
          'errors': null,
          'error': null,
          'meta': {'contract_version': 'v1.0'},
        }),
        200,
      );
    }),
  );

  return YawApp(
    authController: AuthController(
      repository: AuthRepository(apiClient: apiClient),
      tokenStore: tokenStore,
    ),
  );
}
