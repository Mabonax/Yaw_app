import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import 'workos_browser.dart';
import 'auth_models.dart';

class AuthRepository {
  const AuthRepository({
    required ApiClient apiClient,
    WorkosBrowser workosBrowser = const SystemWorkosBrowser(),
  }) : _apiClient = apiClient,
       _workosBrowser = workosBrowser;

  final WorkosBrowser _workosBrowser;

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String email,
    required String password,
    String deviceName = 'yaw-mobile',
  }) async {
    final response = await _apiClient.post(
      'auth/login',
      body: {'email': email, 'password': password, 'device_name': deviceName},
    );

    final data = response.data;
    final user = data['user'];

    return AuthSession(
      token: data['access_token'] as String,
      user: YawUser.fromJson(user is Map<String, Object?> ? user : const {}),
    );
  }

  Future<AuthSession> loginWithWorkos({bool signUp = false}) async {
    final random = Random.secure();
    String nonce() => base64Url
        .encode(List<int>.generate(32, (_) => random.nextInt(256)))
        .replaceAll('=', '');
    final verifier = nonce();
    final state = nonce();
    final challenge = base64Url
        .encode(sha256.convert(utf8.encode(verifier)).bytes)
        .replaceAll('=', '');
    final start = await _apiClient.post(
      'auth/workos/authorize',
      body: {
        'state': state,
        'code_challenge': challenge,
        'screen_hint': signUp ? 'sign-up' : 'sign-in',
      },
    );
    final url = Uri.parse(start.data['authorization_url'] as String);
    final callback = Uri.parse(start.data['redirect_uri'] as String);
    if (url.scheme != 'https' ||
        url.host != 'api.workos.com' ||
        url.userInfo.isNotEmpty ||
        url.path != '/user_management/authorize' ||
        callback.toString() != 'za.co.vmt.yaw://auth/callback') {
      throw const FormatException('Unexpected authentication configuration.');
    }

    final result = Uri.parse(
      await _workosBrowser.authenticate(url.toString(), callback.scheme),
    );
    if (result.scheme != callback.scheme ||
        result.host != callback.host ||
        result.path != callback.path ||
        result.userInfo.isNotEmpty ||
        result.hasPort ||
        result.hasFragment ||
        result.queryParametersAll['state']?.length != 1 ||
        result.queryParameters['state'] != state) {
      throw const ApiException(
        type: ApiExceptionType.validation,
        message: 'The sign-in response was invalid. Please start again.',
      );
    }
    if (result.queryParameters.containsKey('error')) {
      throw const ApiException(
        type: ApiExceptionType.validation,
        message: 'Sign-in was not completed. Please try again.',
      );
    }
    final code = result.queryParameters['code'];
    if (code == null ||
        code.isEmpty ||
        result.queryParametersAll['code']?.length != 1) {
      throw const FormatException('Missing authorization code.');
    }
    final response = await _apiClient.post(
      'auth/workos/exchange',
      body: {
        'state': state,
        'code_verifier': verifier,
        'code': code,
        'device_name': 'yaw-mobile',
      },
    );
    final user = response.data['user'];
    return AuthSession(
      token: response.data['access_token'] as String,
      user: YawUser.fromJson(user is Map<String, Object?> ? user : const {}),
    );
  }

  Future<void> logout() async {
    await _apiClient.post('auth/logout');
  }

  Future<YawUser> currentUser() async {
    final response = await _apiClient.get('me');
    final user = response.data['user'];

    if (user is Map<String, Object?>) {
      return YawUser.fromJson(user);
    }

    throw const FormatException('Missing current user payload.');
  }

  Future<YawPilotProfile?> currentPilot() async {
    final response = await _apiClient.get('me/pilot');
    final pilot = response.data['pilot'];

    if (pilot == null) {
      return null;
    }

    if (pilot is Map<String, Object?>) {
      return YawPilotProfile.fromJson(pilot);
    }

    throw const FormatException('Unexpected pilot payload.');
  }

  Future<List<YawOperatorContext>> currentOperators() async {
    final response = await _apiClient.get('me/operators');
    final operators = response.data['operators'];

    if (operators is! List) {
      throw const FormatException('Unexpected operators payload.');
    }

    return operators
        .whereType<Map<String, Object?>>()
        .map(YawOperatorContext.fromJson)
        .toList(growable: false);
  }

  Future<IdentityContext> loadIdentityContext() async {
    final user = await currentUser();
    final pilot = await currentPilot();
    final operators = await currentOperators();

    return IdentityContext(user: user, pilot: pilot, operators: operators);
  }
}
