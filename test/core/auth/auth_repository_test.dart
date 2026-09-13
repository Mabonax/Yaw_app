import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yaw_app/core/api/api_client.dart';
import 'package:yaw_app/core/auth/auth_repository.dart';

void main() {
  test('AuthRepository logs in with backend token contract', () async {
    final repository = AuthRepository(
      apiClient: ApiClient(
        baseUrl: Uri.parse('https://example.test/api/v1'),
        tokenProvider: () async => null,
        httpClient: MockClient((request) async {
          expect(request.url.path, '/api/v1/auth/login');
          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['device_name'], 'test-device');

          return _ok({
            'token_type': 'Bearer',
            'access_token': 'token-123',
            'user': {'id': 1, 'name': 'User One', 'email': 'one@yaw.test'},
          }, statusCode: 201);
        }),
      ),
    );

    final session = await repository.login(
      email: 'one@yaw.test',
      password: 'password',
      deviceName: 'test-device',
    );

    expect(session.token, 'token-123');
    expect(session.user.email, 'one@yaw.test');
  });

  test('AuthRepository loads current identity context', () async {
    final repository = AuthRepository(
      apiClient: ApiClient(
        baseUrl: Uri.parse('https://example.test/api/v1'),
        tokenProvider: () async => 'token-123',
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('/me/pilot')) {
            return _ok({
              'pilot': {
                'id': 2,
                'display_name': 'Pilot Two',
                'profile_status': 'active',
              },
            });
          }
          if (request.url.path.endsWith('/me/operators')) {
            return _ok({
              'operators': [
                {
                  'id': 3,
                  'legal_entity': 'Operator Three',
                  'trading_name': null,
                  'uasoc_number': 'UASOC-003',
                  'membership_role': 'remote_pilot',
                  'membership_status': 'active',
                },
              ],
            });
          }
          return _ok({
            'user': {
              'id': 1,
              'name': 'User One',
              'email': 'one@yaw.test',
              'role': 'pilot',
            },
          });
        }),
      ),
    );

    final context = await repository.loadIdentityContext();

    expect(context.user.name, 'User One');
    expect(context.pilot?.displayName, 'Pilot Two');
    expect(context.operators.single.legalEntity, 'Operator Three');
  });
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
