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
}
