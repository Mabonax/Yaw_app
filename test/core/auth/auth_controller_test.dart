import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yaw_app/core/api/api_client.dart';
import 'package:yaw_app/core/auth/auth_controller.dart';
import 'package:yaw_app/core/auth/auth_repository.dart';
import 'package:yaw_app/core/storage/token_store.dart';

void main() {
  test('bootstrap starts unauthenticated when no token exists', () async {
    final controller = _controllerWithResponses((request) async => _ok({}));

    await controller.bootstrap();

    expect(controller.state.status, AuthStatus.unauthenticated);
  });

  test('login stores token and exposes authenticated user', () async {
    final tokenStore = MemoryTokenStore();
    final controller = _controllerWithResponses(
      (request) async => _ok({
        'token_type': 'Bearer',
        'access_token': 'plain-token',
        'user': {'id': 11, 'name': 'Yaw Pilot', 'email': 'pilot@yaw.test'},
      }, statusCode: 201),
      tokenStore: tokenStore,
    );

    final result = await controller.login(
      email: 'pilot@yaw.test',
      password: 'secret',
    );

    expect(result, isTrue);
    expect(await tokenStore.readToken(), 'plain-token');
    expect(controller.state.status, AuthStatus.authenticated);
    expect(controller.state.user?.name, 'Yaw Pilot');
  });

  test('logout clears local token even when remote logout fails', () async {
    final tokenStore = MemoryTokenStore();
    await tokenStore.saveToken('plain-token');
    final controller = _controllerWithResponses(
      (request) async => _error('server_error', 'Failure', 500),
      tokenStore: tokenStore,
    );

    await controller.logout();

    expect(await tokenStore.readToken(), isNull);
    expect(controller.state.status, AuthStatus.unauthenticated);
  });
}

AuthController _controllerWithResponses(
  Future<http.Response> Function(http.Request request) handler, {
  MemoryTokenStore? tokenStore,
}) {
  final store = tokenStore ?? MemoryTokenStore();
  final apiClient = ApiClient(
    baseUrl: Uri.parse('https://example.test/api/v1'),
    tokenProvider: store.readToken,
    onUnauthorized: store.clear,
    httpClient: MockClient(handler),
  );

  return AuthController(
    repository: AuthRepository(apiClient: apiClient),
    tokenStore: store,
  );
}

http.Response _ok(Map<String, Object?> data, {int statusCode = 200}) {
  return http.Response(
    jsonEncode({
      'success': true,
      'message': null,
      'data': data,
      'errors': null,
      'error': null,
      'meta': {'contract_version': 'v1.0'},
    }),
    statusCode,
  );
}

http.Response _error(String error, String message, int statusCode) {
  return http.Response(
    jsonEncode({
      'success': false,
      'message': message,
      'data': null,
      'errors': null,
      'error': error,
      'meta': {'contract_version': 'v1.0'},
    }),
    statusCode,
  );
}
