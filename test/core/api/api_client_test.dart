import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yaw_app/core/api/api_client.dart';
import 'package:yaw_app/core/api/api_exception.dart';

void main() {
  test('sends bearer token and parses the YAW API envelope', () async {
    final client = ApiClient(
      baseUrl: Uri.parse('https://example.test/api/v1'),
      tokenProvider: () async => 'token-123',
      httpClient: MockClient((request) async {
        expect(request.url.toString(), 'https://example.test/api/v1/me');
        expect(request.headers['authorization'], 'Bearer token-123');

        return http.Response(
          jsonEncode({
            'success': true,
            'message': null,
            'data': {
              'user': {'id': 7, 'name': 'Pilot One'},
            },
            'errors': null,
            'error': null,
            'meta': {'contract_version': 'v1.0'},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final response = await client.get('me');

    expect(response.success, isTrue);
    expect(response.contractVersion, 'v1.0');
    expect((response.data['user'] as Map)['name'], 'Pilot One');
  });

  test('maps validation envelopes to ApiException validation errors', () async {
    final client = ApiClient(
      baseUrl: Uri.parse('https://example.test/api/v1'),
      tokenProvider: () async => null,
      httpClient: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'The email field is required.',
            'data': null,
            'errors': {
              'email': ['The email field is required.'],
            },
            'error': 'validation_failed',
            'meta': {'contract_version': 'v1.0'},
          }),
          422,
        );
      }),
    );

    await expectLater(
      client.post('auth/login', body: {'email': ''}),
      throwsA(
        isA<ApiException>()
            .having((error) => error.type, 'type', ApiExceptionType.validation)
            .having(
              (error) => error.errors?['email']?.first,
              'email error',
              'The email field is required.',
            ),
      ),
    );
  });

  test('clears local session when the API returns unauthorized', () async {
    var cleared = false;
    final client = ApiClient(
      baseUrl: Uri.parse('https://example.test/api/v1'),
      tokenProvider: () async => 'expired-token',
      onUnauthorized: () async => cleared = true,
      httpClient: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Unauthenticated.',
            'data': null,
            'errors': null,
            'error': 'unauthenticated',
            'meta': {'contract_version': 'v1.0'},
          }),
          401,
        );
      }),
    );

    await expectLater(client.get('me'), throwsA(isA<ApiException>()));

    expect(cleared, isTrue);
  });
}
