enum ApiExceptionType {
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  timeout,
  connectivity,
  unknown,
}

class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.errors,
  });

  final ApiExceptionType type;
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? errors;

  @override
  String toString() => 'ApiException($type, $statusCode, $message)';
}
