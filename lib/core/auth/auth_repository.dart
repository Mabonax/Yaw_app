import '../api/api_client.dart';
import 'auth_models.dart';

class AuthRepository {
  const AuthRepository({required ApiClient apiClient}) : _apiClient = apiClient;

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
