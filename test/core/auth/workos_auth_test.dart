import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:yaw_app/features/auth/presentation/register_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yaw_app/core/api/api_client.dart';
import 'package:yaw_app/core/api/api_exception.dart';
import 'package:yaw_app/core/auth/auth_controller.dart';
import 'package:yaw_app/core/auth/auth_repository.dart';
import 'package:yaw_app/core/auth/workos_browser.dart';
import 'package:yaw_app/core/storage/token_store.dart';

class _Browser implements WorkosBrowser {
  _Browser(this.callback);
  final Future<String> Function(String) callback;
  @override
  Future<String> authenticate(String url, String callbackScheme) {
    expect(callbackScheme, 'za.co.vmt.yaw');
    return callback(url);
  }
}

http.Response _ok(Map<String, Object?> data) => http.Response(
  jsonEncode({
    'success': true,
    'data': data,
    'meta': {'contract_version': 'v1.0'},
  }),
  200,
);

void main() {
  for (final width in [320.0, 393.0, 412.0]) {
    testWidgets(
      'registration launches WorkOS and shows cancellation at width $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var started = false;
        final controller = AuthController(
          tokenStore: MemoryTokenStore(),
          repository: AuthRepository(
            workosBrowser: _Browser(
              (_) async => throw const ApiException(
                type: ApiExceptionType.validation,
                message: 'Sign-in was cancelled.',
              ),
            ),
            apiClient: ApiClient(
              baseUrl: Uri.parse('https://example.test/api/v1'),
              tokenProvider: () async => null,
              httpClient: MockClient((request) async {
                expect(
                  (jsonDecode(request.body)
                      as Map<String, dynamic>)['screen_hint'],
                  'sign-up',
                );
                started = true;
                return _ok({
                  'authorization_url':
                      'https://api.workos.com/user_management/authorize',
                  'redirect_uri': 'za.co.vmt.yaw://auth/callback',
                });
              }),
            ),
          ),
        );
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: RegisterScreen(
              authController: controller,
              onBack: () {},
              onSignIn: () {},
            ),
          ),
        );
        expect(find.byType(TextFormField), findsNothing);
        final button = find.text('Create Account with WorkOS');
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(started, isTrue);
        expect(find.text('Sign-in was cancelled.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final signUp in [false, true]) {
    test(
      'WorkOS uses PKCE and exchanges only validated callback (signup=$signUp)',
      () async {
        late String state;
        late String challenge;
        final calls = <String>[];
        final repository = AuthRepository(
          workosBrowser: _Browser((url) async {
            expect(Uri.parse(url).host, 'api.workos.com');
            return 'za.co.vmt.yaw://auth/callback?state=$state&code=one-time-code';
          }),
          apiClient: ApiClient(
            baseUrl: Uri.parse('https://example.test/api/v1'),
            tokenProvider: () async => null,
            httpClient: MockClient((request) async {
              calls.add(request.url.path);
              final body = jsonDecode(request.body) as Map<String, dynamic>;
              if (request.url.path.endsWith('/authorize')) {
                state = body['state'] as String;
                challenge = body['code_challenge'] as String;
                expect(state, matches(RegExp(r'^[A-Za-z0-9_-]{43}$')));
                expect(body['screen_hint'], signUp ? 'sign-up' : 'sign-in');
                expect(body.containsKey('code_verifier'), isFalse);
                return _ok({
                  'authorization_url':
                      'https://api.workos.com/user_management/authorize',
                  'redirect_uri': 'za.co.vmt.yaw://auth/callback',
                });
              }
              expect(body['state'], state);
              expect(body['code'], 'one-time-code');
              expect(body['device_name'], 'yaw-mobile');
              final verifier = body['code_verifier'] as String;
              expect(
                base64Url
                    .encode(sha256.convert(utf8.encode(verifier)).bytes)
                    .replaceAll('=', ''),
                challenge,
              );
              return _ok({
                'access_token': 'local-token',
                'user': {
                  'id': 1,
                  'name': 'Pilot',
                  'email': 'pilot@example.test',
                },
              });
            }),
          ),
        );
        expect(
          (await repository.loginWithWorkos(signUp: signUp)).token,
          'local-token',
        );
        expect(calls, [
          '/api/v1/auth/workos/authorize',
          '/api/v1/auth/workos/exchange',
        ]);
      },
    );
  }

  for (final failure in [
    'state',
    'duplicate-state',
    'scheme',
    'host',
    'path',
    'fragment',
    'duplicate-code',
    'missing-code',
    'cancel',
  ]) {
    test('WorkOS rejects $failure callback without exchanging', () async {
      late String state;
      var requests = 0;
      final repository = AuthRepository(
        workosBrowser: _Browser((_) async {
          final good = 'za.co.vmt.yaw://auth/callback?state=$state&code=code';
          return switch (failure) {
            'state' => good.replaceFirst(state, 'wrong'),
            'duplicate-state' => '$good&state=$state',
            'scheme' => good.replaceFirst('za.co.vmt.yaw', 'other.app'),
            'host' => good.replaceFirst('://auth', '://evil'),
            'path' => good.replaceFirst('/callback', '/other'),
            'fragment' => '$good#fragment',
            'duplicate-code' => '$good&code=another',
            'missing-code' => good.replaceFirst('&code=code', ''),
            _ => good.replaceFirst('&code=code', '&error=access_denied'),
          };
        }),
        apiClient: ApiClient(
          baseUrl: Uri.parse('https://example.test/api/v1'),
          tokenProvider: () async => null,
          httpClient: MockClient((request) async {
            requests++;
            state =
                (jsonDecode(request.body) as Map<String, dynamic>)['state']
                    as String;
            return _ok({
              'authorization_url':
                  'https://api.workos.com/user_management/authorize',
              'redirect_uri': 'za.co.vmt.yaw://auth/callback',
            });
          }),
        ),
      );
      await expectLater(
        repository.loginWithWorkos(),
        throwsA(anyOf(isA<ApiException>(), isA<FormatException>())),
      );
      expect(requests, 1);
    });
  }

  test(
    'WorkOS refuses unexpected authorization host before opening browser',
    () async {
      final repository = AuthRepository(
        workosBrowser: _Browser(
          (_) async => throw StateError('Browser must not open'),
        ),
        apiClient: ApiClient(
          baseUrl: Uri.parse('https://example.test/api/v1'),
          tokenProvider: () async => null,
          httpClient: MockClient(
            (_) async => _ok({
              'authorization_url':
                  'https://evil.example/user_management/authorize',
              'redirect_uri': 'za.co.vmt.yaw://auth/callback',
            }),
          ),
        ),
      );
      await expectLater(repository.loginWithWorkos(), throwsFormatException);
    },
  );

  for (final contextFails in [false, true]) {
    test(
      'WorkOS controller stores identity or cleans failed session (failure=$contextFails)',
      () async {
        final store = MemoryTokenStore();
        late String state;
        var loggedOut = false;
        final repository = AuthRepository(
          workosBrowser: _Browser(
            (_) async => 'za.co.vmt.yaw://auth/callback?state=$state&code=code',
          ),
          apiClient: ApiClient(
            baseUrl: Uri.parse('https://example.test/api/v1'),
            tokenProvider: store.readToken,
            httpClient: MockClient((request) async {
              if (request.url.path.endsWith('/authorize')) {
                state =
                    (jsonDecode(request.body) as Map<String, dynamic>)['state']
                        as String;
                return _ok({
                  'authorization_url':
                      'https://api.workos.com/user_management/authorize',
                  'redirect_uri': 'za.co.vmt.yaw://auth/callback',
                });
              }
              if (request.url.path.endsWith('/exchange')) {
                return _ok({
                  'access_token': 'session-token',
                  'user': {
                    'id': 1,
                    'name': 'Pilot',
                    'email': 'pilot@example.test',
                  },
                });
              }
              expect(request.headers['Authorization'], 'Bearer session-token');
              if (request.url.path.endsWith('/logout')) {
                loggedOut = true;
                return _ok({});
              }
              if (contextFails) {
                return http.Response(
                  '{"success":false,"message":"Unavailable"}',
                  503,
                );
              }
              if (request.url.path.endsWith('/me/pilot')) {
                return _ok({'pilot': null});
              }
              if (request.url.path.endsWith('/me/operators')) {
                return _ok({'operators': []});
              }
              return _ok({
                'user': {
                  'id': 1,
                  'name': 'Pilot',
                  'email': 'pilot@example.test',
                },
              });
            }),
          ),
        );
        final controller = AuthController(
          repository: repository,
          tokenStore: store,
        );
        addTearDown(controller.dispose);
        expect(await controller.loginWithWorkos(signUp: true), !contextFails);
        expect(controller.state.isAuthenticated, !contextFails);
        expect(await store.readToken(), contextFails ? null : 'session-token');
        expect(loggedOut, contextFails);
        expect(controller.state.isSubmitting, isFalse);
      },
    );
  }
}
