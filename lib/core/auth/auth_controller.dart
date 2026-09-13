import 'package:flutter/foundation.dart';

import '../api/api_exception.dart';
import '../storage/token_store.dart';
import 'auth_models.dart';
import 'auth_repository.dart';

enum AuthStatus { bootstrapping, unauthenticated, authenticated, failure }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.fieldErrors,
    this.isSubmitting = false,
  });

  const AuthState.bootstrapping() : this(status: AuthStatus.bootstrapping);

  final AuthStatus status;
  final YawUser? user;
  final String? errorMessage;
  final Map<String, List<String>>? fieldErrors;
  final bool isSubmitting;

  AuthState copyWith({
    AuthStatus? status,
    YawUser? user,
    String? errorMessage,
    Map<String, List<String>>? fieldErrors,
    bool? isSubmitting,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthRepository repository,
    required TokenStore tokenStore,
  }) : _repository = repository,
       _tokenStore = tokenStore;

  final AuthRepository _repository;
  final TokenStore _tokenStore;

  AuthState _state = const AuthState.bootstrapping();

  AuthState get state => _state;

  Future<void> bootstrap() async {
    final token = await _tokenStore.readToken();
    _state = token == null
        ? const AuthState(status: AuthStatus.unauthenticated)
        : const AuthState(
            status: AuthStatus.authenticated,
            user: YawUser(id: 0, name: 'YAW operator', email: ''),
          );
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _state = _state.copyWith(
      status: AuthStatus.unauthenticated,
      isSubmitting: true,
    );
    notifyListeners();

    try {
      final session = await _repository.login(email: email, password: password);
      await _tokenStore.saveToken(session.token);
      _state = AuthState(status: AuthStatus.authenticated, user: session.user);
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _state = AuthState(
        status: AuthStatus.failure,
        errorMessage: error.message,
        fieldErrors: error.errors,
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } on ApiException {
      // Local session clearing remains authoritative for mobile sign-out UX.
    } finally {
      await _tokenStore.clear();
      _state = const AuthState(status: AuthStatus.unauthenticated);
      notifyListeners();
    }
  }
}
