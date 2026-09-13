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

  test(
    'bootstrap restores valid stored session with identity context',
    () async {
      final tokenStore = MemoryTokenStore();
      await tokenStore.saveToken('stored-token');
      final controller = _controllerWithResponses(
        _identityHandler,
        tokenStore: tokenStore,
      );

      await controller.bootstrap();

      expect(controller.state.status, AuthStatus.authenticated);
      expect(controller.state.user?.name, 'Yaw Pilot');
      expect(controller.state.pilot?.displayName, 'Linked Pilot');
      expect(
        controller.state.operators.single.legalEntity,
        'Active API Operator',
      );
    },
  );

  test('bootstrap clears expired stored session', () async {
    final tokenStore = MemoryTokenStore();
    await tokenStore.saveToken('expired-token');
    final controller = _controllerWithResponses(
      (request) async => _error('unauthenticated', 'Unauthenticated.', 401),
      tokenStore: tokenStore,
    );

    await controller.bootstrap();

    expect(await tokenStore.readToken(), isNull);
    expect(controller.state.status, AuthStatus.failure);
    expect(controller.state.errorMessage, contains('expired'));
  });

  test('login stores token and loads user pilot operator context', () async {
    final tokenStore = MemoryTokenStore();
    final controller = _controllerWithResponses((request) async {
      if (request.url.path.endsWith('/auth/login')) {
        return _ok({
          'token_type': 'Bearer',
          'access_token': 'plain-token',
          'user': {'id': 11, 'name': 'Yaw Pilot', 'email': 'pilot@yaw.test'},
        }, statusCode: 201);
      }

      return _identityHandler(request);
    }, tokenStore: tokenStore);

    final result = await controller.login(
      email: 'pilot@yaw.test',
      password: 'secret',
    );

    expect(result, isTrue);
    expect(await tokenStore.readToken(), 'plain-token');
    expect(controller.state.status, AuthStatus.authenticated);
    expect(controller.state.user?.name, 'Yaw Pilot');
    expect(controller.state.pilot?.rpcCategory, 'multi_rotor');
    expect(controller.state.operators.length, 1);
  });

  test('login invalid credentials exposes validation errors', () async {
    final controller = _controllerWithResponses(
      (request) async => _error(
        'validation_failed',
        'The provided credentials are incorrect.',
        422,
        errors: {
          'email': ['The provided credentials are incorrect.'],
        },
      ),
    );

    final result = await controller.login(
      email: 'bad@yaw.test',
      password: 'wrong',
    );

    expect(result, isFalse);
    expect(controller.state.status, AuthStatus.failure);
    expect(
      controller.state.fieldErrors?['email']?.first,
      contains('incorrect'),
    );
  });

  test('refresh supports absent pilot and multiple operators', () async {
    final tokenStore = MemoryTokenStore();
    await tokenStore.saveToken('stored-token');
    final controller = _controllerWithResponses((request) async {
      if (request.url.path.endsWith('/me/pilot')) {
        return _ok({'pilot': null});
      }
      if (request.url.path.endsWith('/me/operators')) {
        return _ok({
          'operators': [
            _operatorJson('Operator A', 'remote_pilot'),
            _operatorJson('Operator B', 'operations_manager'),
          ],
        });
      }
      return _identityHandler(request);
    }, tokenStore: tokenStore);

    await controller.bootstrap();

    expect(controller.state.pilot, isNull);
    expect(controller.state.operators, hasLength(2));
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
    expect(controller.state.user, isNull);
    expect(controller.state.operators, isEmpty);
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

Future<http.Response> _identityHandler(http.Request request) async {
  if (request.url.path.endsWith('/me/pilot')) {
    return _ok({'pilot': _pilotJson()});
  }
  if (request.url.path.endsWith('/me/operators')) {
    return _ok({
      'operators': [_operatorJson('Active API Operator', 'operations_manager')],
    });
  }
  if (request.url.path.endsWith('/me')) {
    return _ok({
      'user': {
        'id': 11,
        'name': 'Yaw Pilot',
        'email': 'pilot@yaw.test',
        'role': 'pilot',
      },
    });
  }
  if (request.url.path.endsWith('/auth/logout')) {
    return _ok({});
  }

  return _error('not_found', 'Not found.', 404);
}

Map<String, Object?> _pilotJson() {
  return {
    'id': 42,
    'display_name': 'Linked Pilot',
    'user_id': 11,
    'employee_number': 'P-001',
    'first_name': 'Linked',
    'last_name': 'Pilot',
    'preferred_name': null,
    'email': 'pilot@yaw.test',
    'phone': '0123456789',
    'nationality': 'South African',
    'date_of_birth': '1990-01-01',
    'sacaa_certificate_number': 'RPC-001',
    'rpc_category': 'multi_rotor',
    'ratings': ['vlos'],
    'medical_status': 'valid',
    'radiotelephony_qualification': 'restricted',
    'language_proficiency': 'Level 6',
    'training_history': [],
    'examiner_records': [],
    'operator_affiliations': [],
    'supporting_document_references': [],
    'profile_status': 'active',
    'regulatory_source': 'FR-PIL-001',
    'regulatory_source_version': 'v1.0',
    'regulatory_effective_date': '2026-09-09',
    'regulatory_applicability': 'API V1 pilot test record.',
    'responsible_role': 'Compliance Manager',
    'notes': null,
  };
}

Map<String, Object?> _operatorJson(String name, String role) {
  return {
    'id': name.hashCode.abs(),
    'legal_entity': name,
    'trading_name': null,
    'uasoc_number': 'UASOC-001',
    'membership_role': role,
    'membership_status': 'active',
  };
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

http.Response _error(
  String error,
  String message,
  int statusCode, {
  Map<String, List<String>>? errors,
}) {
  return http.Response(
    jsonEncode({
      'success': false,
      'message': message,
      'data': null,
      'errors': errors,
      'error': error,
      'meta': {'contract_version': 'v1.0'},
    }),
    statusCode,
  );
}
