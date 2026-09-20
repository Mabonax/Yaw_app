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
    this.pilot,
    this.operators = const [],
    this.errorMessage,
    this.fieldErrors,
    this.isSubmitting = false,
    this.isContextLoading = false,
    this.contextErrorMessage,
  });

  const AuthState.bootstrapping() : this(status: AuthStatus.bootstrapping);

  final AuthStatus status;
  final YawUser? user;
  final YawPilotProfile? pilot;
  final List<YawOperatorContext> operators;
  final String? errorMessage;
  final Map<String, List<String>>? fieldErrors;
  final bool isSubmitting;
  final bool isContextLoading;
  final String? contextErrorMessage;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get hasPilotProfile => pilot != null;
  bool get hasOperators => operators.isNotEmpty;

  AuthState copyWith({
    AuthStatus? status,
    YawUser? user,
    YawPilotProfile? pilot,
    List<YawOperatorContext>? operators,
    String? errorMessage,
    Map<String, List<String>>? fieldErrors,
    bool? isSubmitting,
    bool? isContextLoading,
    String? contextErrorMessage,
    bool clearPilot = false,
    bool clearErrors = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      pilot: clearPilot ? null : pilot ?? this.pilot,
      operators: operators ?? this.operators,
      errorMessage: clearErrors ? null : errorMessage ?? this.errorMessage,
      fieldErrors: clearErrors ? null : fieldErrors ?? this.fieldErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isContextLoading: isContextLoading ?? this.isContextLoading,
      contextErrorMessage: clearErrors
          ? null
          : contextErrorMessage ?? this.contextErrorMessage,
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
    _state = const AuthState.bootstrapping();
    notifyListeners();

    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      _state = const AuthState(status: AuthStatus.unauthenticated);
      notifyListeners();
      return;
    }

    await _restoreStoredSession();
  }

  Future<bool> login({required String email, required String password}) async {
    if (_state.isSubmitting) {
      return false;
    }

    _state = _state.copyWith(
      status: AuthStatus.unauthenticated,
      isSubmitting: true,
      clearErrors: true,
    );
    notifyListeners();

    try {
      await _repository
          .login(email: email, password: password)
          .then((session) => _tokenStore.saveToken(session.token));
      final context = await _repository.loadIdentityContext();
      _state = _authenticatedState(context);
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _state = AuthState(
        status: AuthStatus.failure,
        errorMessage: _messageForApiError(error),
        fieldErrors: error.errors,
      );
      notifyListeners();
      return false;
    } on FormatException {
      _state = const AuthState(
        status: AuthStatus.failure,
        errorMessage: 'The YAW service returned an unexpected response.',
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithWorkos({bool signUp = false}) async {
    if (_state.isSubmitting) return false;
    _state = const AuthState(
      status: AuthStatus.unauthenticated,
      isSubmitting: true,
    );
    notifyListeners();
    var stored = false;
    try {
      final session = await _repository.loginWithWorkos(signUp: signUp);
      await _tokenStore.saveToken(session.token);
      stored = true;
      final context = await _repository.loadIdentityContext();
      _state = _authenticatedState(context);
      notifyListeners();
      return true;
    } catch (error) {
      if (stored) {
        try {
          await _repository.logout();
        } catch (_) {
          /* Local cleanup still runs. */
        }
      }
      await _tokenStore.clear();
      _state = AuthState(
        status: AuthStatus.failure,
        errorMessage: error is ApiException
            ? _messageForApiError(error)
            : 'Secure sign-in could not be completed. Please try again.',
        fieldErrors: error is ApiException ? error.errors : null,
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshIdentityContext() async {
    if (!_state.isAuthenticated) {
      return;
    }

    _state = _state.copyWith(isContextLoading: true, clearErrors: true);
    notifyListeners();

    try {
      final context = await _repository.loadIdentityContext();
      _state = _authenticatedState(context);
    } on ApiException catch (error) {
      if (error.type == ApiExceptionType.unauthorized) {
        await _clearSessionWithMessage(
          'Your session has expired. Please sign in again.',
        );
        return;
      }

      _state = _state.copyWith(
        isContextLoading: false,
        contextErrorMessage: _messageForApiError(error),
      );
    } on FormatException {
      _state = _state.copyWith(
        isContextLoading: false,
        contextErrorMessage: 'The YAW service returned an unexpected response.',
      );
    }

    notifyListeners();
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

  Future<void> _restoreStoredSession() async {
    try {
      final context = await _repository.loadIdentityContext();
      _state = _authenticatedState(context);
    } on ApiException catch (error) {
      if (error.type == ApiExceptionType.unauthorized) {
        await _clearSessionWithMessage(
          'Your session has expired. Please sign in again.',
        );
        return;
      }

      _state = AuthState(
        status: AuthStatus.failure,
        errorMessage: _messageForApiError(error),
      );
    } on FormatException {
      _state = const AuthState(
        status: AuthStatus.failure,
        errorMessage: 'The YAW service returned an unexpected response.',
      );
    }

    notifyListeners();
  }

  AuthState _authenticatedState(IdentityContext context) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: context.user,
      pilot: context.pilot,
      operators: context.operators,
    );
  }

  Future<void> _clearSessionWithMessage(String message) async {
    await _tokenStore.clear();
    _state = AuthState(status: AuthStatus.failure, errorMessage: message);
    notifyListeners();
  }

  String _messageForApiError(ApiException error) {
    return switch (error.type) {
      ApiExceptionType.validation => error.message,
      ApiExceptionType.unauthorized =>
        'Your session has expired. Please sign in again.',
      ApiExceptionType.forbidden =>
        'Your account cannot access this YAW resource.',
      ApiExceptionType.notFound =>
        'The requested YAW resource could not be found.',
      ApiExceptionType.timeout => 'The YAW service took too long to respond.',
      ApiExceptionType.connectivity =>
        'The YAW service is unavailable. Check your connection or API URL.',
      ApiExceptionType.server => 'The YAW service encountered a server error.',
      ApiExceptionType.unknown =>
        'The YAW service returned an unexpected response.',
    };
  }
}
