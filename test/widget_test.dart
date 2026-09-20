import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yaw_app/app/app.dart';
import 'package:yaw_app/core/api/api_client.dart';
import 'package:yaw_app/core/auth/auth_controller.dart';
import 'package:yaw_app/core/auth/auth_models.dart';
import 'package:yaw_app/core/auth/auth_repository.dart';
import 'package:yaw_app/core/storage/token_store.dart';
import 'package:yaw_app/features/aircraft/data/aircraft_repository.dart';
import 'package:yaw_app/features/aircraft/presentation/aircraft_controller.dart';
import 'package:yaw_app/features/missions/data/mission_repository.dart';
import 'package:yaw_app/features/missions/presentation/mission_controller.dart';
import 'package:yaw_app/features/pilot/presentation/pilot_profile_screen.dart';
import 'package:yaw_app/features/auth/presentation/role_selection_screen.dart';

void main() {
  testWidgets('account setup is reachable after a session restore failure', (
    tester,
  ) async {
    final app = _appWithToken(
      'unavailable-token',
      handler: (request) async =>
          _error('service_unavailable', 'Service unavailable', 503),
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Create one'));
    expect(find.text('Create Your Account'), findsOneWidget);
  });
  testWidgets('role cards fit a standard phone without clipping', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(412, 915);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(home: RoleSelectionScreen(onContinue: (_) {})),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await _tapVisible(tester, find.text('Continue'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows login validation before authentication', (tester) async {
    final app = _appWithToken(null);

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await _openLogin(tester);

    await _tapVisible(tester, find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });

  testWidgets('login success enters authenticated shell', (tester) async {
    final app = _appWithToken(null);

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await _openLogin(tester);
    await tester.enterText(find.byType(EditableText).at(0), 'pilot@yaw.test');
    await tester.enterText(find.byType(EditableText).at(1), 'password');
    await _tapVisible(tester, find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Yaw'), findsOneWidget);
    expect(find.text('My Profile'), findsOneWidget);
  });

  testWidgets('login error is shown without token leakage', (tester) async {
    final app = _appWithToken(
      null,
      handler: (request) async => _error(
        'validation_failed',
        'The provided credentials are incorrect.',
        422,
        errors: {
          'email': ['The provided credentials are incorrect.'],
        },
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await _openLogin(tester);
    await tester.enterText(find.byType(EditableText).at(0), 'bad@yaw.test');
    await tester.enterText(find.byType(EditableText).at(1), 'wrong');
    await _tapVisible(tester, find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(
      find.text('The provided credentials are incorrect.'),
      findsOneWidget,
    );
    expect(find.textContaining('token'), findsNothing);
  });

  testWidgets(
    'restored session routes authenticated users into shell and More profile area',
    (tester) async {
      final app = _appWithToken('existing-token');

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.text('Yaw'), findsOneWidget);

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('My Pilot Profile'), findsOneWidget);
      expect(find.text('My Operators'), findsOneWidget);
    },
  );

  testWidgets('pilot profile screen renders backend supplied sections', (
    tester,
  ) async {
    final pilot = AuthFixtures.pilot();

    await tester.pumpWidget(TestApp(child: PilotProfileScreen(pilot: pilot)));
    await tester.pumpAndSettle();

    expect(find.text('Identity'), findsOneWidget);
    expect(find.text('Pilot credentials'), findsOneWidget);
    expect(find.text('RPC category'), findsOneWidget);
    expect(find.text('Multi Rotor'), findsOneWidget);
  });

  testWidgets('logout clears authenticated shell and returns to login', (
    tester,
  ) async {
    final app = _appWithToken('existing-token');

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.text('YP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(app.authController.state.status, AuthStatus.unauthenticated);
    expect(find.text('Yaw'), findsNothing);
    await _openLogin(tester);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets(
    'logout removes private routes and the next login reloads domain state',
    (tester) async {
      var missionCalls = 0;
      final app = _appWithToken(
        'existing-token',
        handler: (request) async {
          if (request.url.path.endsWith('/missions') && missionCalls++ == 0) {
            return _error(
              'forbidden',
              'Previous account permission failure',
              403,
            );
          }
          return _defaultHandler(request);
        },
      );
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Missions'));
      await tester.pumpAndSettle();
      expect(missionCalls, 1);
      expect(find.text('Missions could not be loaded'), findsOneWidget);
      final context = tester.element(find.text('Missions could not be loaded'));
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              const Scaffold(body: Text('Private previous session view')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Private previous session view'), findsOneWidget);
      await app.authController.logout();
      await tester.pumpAndSettle();
      expect(find.text('Private previous session view'), findsNothing);
      await _openLogin(tester);
      await tester.enterText(find.byType(EditableText).at(0), 'pilot@yaw.test');
      await tester.enterText(find.byType(EditableText).at(1), 'password');
      await _tapVisible(tester, find.text('Sign In'));
      await tester.tap(find.text('Missions'));
      await tester.pumpAndSettle();
      expect(missionCalls, 2);
      expect(find.text('Missions could not be loaded'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [
    const Size(320, 568),
    const Size(393, 852),
    const Size(412, 915),
  ]) {
    for (final scale in [1.0, 1.3]) {
      testWidgets(
        'auth usable at $size scale $scale with keyboard and errors',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          var fail = true;
          final app = _appWithToken(
            null,
            handler: (request) async {
              if (fail && request.url.path.endsWith('/auth/login')) {
                return _error(
                  'validation_failed',
                  'The provided credentials are incorrect.',
                  422,
                );
              }
              return _defaultHandler(request);
            },
          );
          await tester.pumpWidget(app);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await _openLogin(tester);
          await _tapVisible(tester, find.text('Sign In'));
          expect(find.text('Email is required.'), findsOneWidget);
          expect(find.text('Password is required.'), findsOneWidget);
          expect(tester.takeException(), isNull);

          tester.view.viewInsets = const FakeViewPadding(bottom: 240);
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.byType(TextFormField).first);
          await tester.enterText(
            find.byType(EditableText).at(0),
            'pilot@yaw.test',
          );
          await tester.ensureVisible(find.byType(TextFormField).last);
          await tester.enterText(find.byType(EditableText).at(1), 'password');
          await _tapVisible(tester, find.text('Sign In'));
          final error = find.text('The provided credentials are incorrect.');
          await tester.ensureVisible(error);
          await tester.pumpAndSettle();
          expect(error.hitTestable(), findsOneWidget);
          expect(app.authController.state.status, AuthStatus.failure);
          expect(tester.takeException(), isNull);
          fail = false;
          await _tapVisible(tester, find.text('Sign In'));
          tester.view.resetViewInsets();
          await tester.pumpAndSettle();
          expect(app.authController.state.isAuthenticated, isTrue);
          expect(find.text('Yaw'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _openLogin(WidgetTester tester) async {
  expect(find.text('Get Started'), findsOneWidget);
  await _tapVisible(tester, find.text('Get Started'));
  expect(find.text('Welcome\nBack'), findsOneWidget);
  expect(find.byType(TextFormField), findsNWidgets(2));
}

YawApp _appWithToken(
  String? token, {
  Future<http.Response> Function(http.Request request)? handler,
}) {
  final tokenStore = MemoryTokenStore();
  if (token != null) {
    tokenStore.saveToken(token);
  }

  final apiClient = ApiClient(
    baseUrl: Uri.parse('https://example.test/api/v1'),
    tokenProvider: tokenStore.readToken,
    onUnauthorized: tokenStore.clear,
    httpClient: MockClient(handler ?? _defaultHandler),
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
  );
}

Future<http.Response> _defaultHandler(http.Request request) async {
  if (request.url.path.endsWith('/auth/login')) {
    return _ok({
      'token_type': 'Bearer',
      'access_token': 'plain-token',
      'user': {'id': 11, 'name': 'Yaw Pilot', 'email': 'pilot@yaw.test'},
    }, statusCode: 201);
  }
  if (request.url.path.endsWith('/auth/logout')) {
    return _ok({});
  }
  if (request.url.path.endsWith('/me/pilot')) {
    return _ok({'pilot': AuthFixtures.pilotJson()});
  }
  if (request.url.path.endsWith('/me/operators')) {
    return _ok({
      'operators': [AuthFixtures.operatorJson()],
    });
  }
  if (request.url.path.endsWith('/missions')) {
    return _ok({'missions': []});
  }
  if (request.url.path.endsWith('/aircraft')) {
    return _ok({'aircraft': []});
  }
  if (request.url.path.endsWith('/missions')) {
    return _ok({'missions': []});
  }
  if (request.url.path.endsWith('/aircraft')) {
    return _ok({'aircraft': []});
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

  return _error('not_found', 'Not found.', 404);
}

class TestApp extends StatelessWidget {
  const TestApp({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: child);
  }
}

class AuthFixtures {
  static YawPilotProfile pilot() => YawPilotProfile.fromJson(pilotJson());

  static Map<String, Object?> pilotJson() {
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

  static Map<String, Object?> operatorJson() {
    return {
      'id': 5,
      'legal_entity': 'Active API Operator',
      'trading_name': null,
      'uasoc_number': 'UASOC-001',
      'membership_role': 'operations_manager',
      'membership_status': 'active',
    };
  }
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
