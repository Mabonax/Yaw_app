class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.success,
    required this.data,
    required this.message,
    required this.error,
    required this.errors,
    required this.contractVersion,
  });

  factory ApiEnvelope.fromJson(
    Map<String, Object?> json,
    T Function(Object? value) parseData,
  ) {
    final meta = json['meta'];
    final metaMap = meta is Map<String, Object?>
        ? meta
        : const <String, Object?>{};

    return ApiEnvelope<T>(
      success: json['success'] == true,
      message: json['message'] as String?,
      data: parseData(json['data']),
      error: json['error'] as String?,
      errors: _parseErrors(json['errors']),
      contractVersion: metaMap['contract_version'] as String?,
    );
  }

  final bool success;
  final T data;
  final String? message;
  final String? error;
  final Map<String, List<String>>? errors;
  final String? contractVersion;

  static Map<String, List<String>>? _parseErrors(Object? value) {
    if (value is! Map) {
      return null;
    }

    return value.map((key, errorValue) {
      final messages = errorValue is List
          ? errorValue.map((message) => message.toString()).toList()
          : <String>[errorValue.toString()];
      return MapEntry(key.toString(), messages);
    });
  }
}
