import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_envelope.dart';
import 'api_exception.dart';

typedef TokenProvider = Future<String?> Function();
typedef UnauthorizedHandler = Future<void> Function();
typedef OperatorProvider = Future<int?> Function();

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.tokenProvider,
    this.onUnauthorized,
    this.operatorProvider,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 20),
  }) : _httpClient = httpClient ?? http.Client();

  final Uri baseUrl;
  final TokenProvider tokenProvider;
  final UnauthorizedHandler? onUnauthorized;
  final OperatorProvider? operatorProvider;
  final http.Client _httpClient;
  final Duration timeout;

  Future<ApiEnvelope<Map<String, Object?>>> get(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    return _send(
      'GET',
      path,
      queryParameters: queryParameters,
      parseData: _asDataMap,
    );
  }

  Future<ApiEnvelope<Map<String, Object?>>> post(
    String path, {
    Map<String, Object?>? body,
  }) {
    return _send('POST', path, body: body, parseData: _asDataMap);
  }

  Future<ApiEnvelope<T>> _send<T>(
    String method,
    String path, {
    Map<String, String>? queryParameters,
    Map<String, Object?>? body,
    required T Function(Object? value) parseData,
  }) async {
    final uri = _resolve(path, queryParameters);
    final token = await tokenProvider();
    final operatorId = operatorProvider == null ? null : await operatorProvider!.call();
    final headers = <String, String>{
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null && token.isNotEmpty)
        HttpHeaders.authorizationHeader: 'Bearer $token',
      if (operatorId != null) 'X-YAW-Operator': '$operatorId',
    };

    try {
      final request = switch (method) {
        'POST' => _httpClient.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? const <String, Object?>{}),
        ),
        _ => _httpClient.get(uri, headers: headers),
      };

      final response = await request.timeout(timeout);
      return _handleResponse(response, parseData);
    } on TimeoutException {
      throw const ApiException(
        type: ApiExceptionType.timeout,
        message: 'The request timed out. Check your connection and try again.',
      );
    } on SocketException {
      throw const ApiException(
        type: ApiExceptionType.connectivity,
        message: 'The YAW service could not be reached.',
      );
    } on http.ClientException catch (error) {
      throw ApiException(
        type: ApiExceptionType.connectivity,
        message: error.message,
      );
    }
  }

  Uri _resolve(String path, Map<String, String>? queryParameters) {
    final normalizedBase = baseUrl.toString().endsWith('/')
        ? baseUrl.toString()
        : '${baseUrl.toString()}/';
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    return Uri.parse(
      normalizedBase,
    ).resolve(normalizedPath).replace(queryParameters: queryParameters);
  }

  Future<ApiEnvelope<T>> _handleResponse<T>(
    http.Response response,
    T Function(Object? value) parseData,
  ) async {
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, Object?>) {
      throw const ApiException(
        type: ApiExceptionType.unknown,
        message: 'The YAW service returned an unexpected response.',
      );
    }

    final envelope = ApiEnvelope<T>.fromJson(decoded, parseData);
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        envelope.success) {
      return envelope;
    }

    if (response.statusCode == 401) {
      await onUnauthorized?.call();
    }

    throw ApiException(
      type: _typeForStatus(response.statusCode),
      statusCode: response.statusCode,
      message: envelope.message ?? envelope.error ?? 'The request failed.',
      errors: envelope.errors,
    );
  }

  static ApiExceptionType _typeForStatus(int statusCode) {
    return switch (statusCode) {
      401 => ApiExceptionType.unauthorized,
      403 => ApiExceptionType.forbidden,
      404 => ApiExceptionType.notFound,
      422 => ApiExceptionType.validation,
      >= 500 => ApiExceptionType.server,
      _ => ApiExceptionType.unknown,
    };
  }

  static Map<String, Object?> _asDataMap(Object? value) {
    if (value is Map<String, Object?>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
    }

    return const <String, Object?>{};
  }
}
