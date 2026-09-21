class OperatorMembership {
  const OperatorMembership({
    required this.id,
    required this.operatorId,
    required this.operatorName,
    required this.role,
    required this.status,
    required this.source,
    this.message,
  });

  final int id;
  final int operatorId;
  final String operatorName;
  final String role;
  final String status;
  final String source;
  final String? message;

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isInvitation => isPending && source == 'invitation';
  bool get isJoinRequest => isPending && source == 'join_request';

  factory OperatorMembership.fromJson(Map<String, Object?> json) {
    final operator = _map(json['operator']);
    return OperatorMembership(
      id: json['id'] as int,
      operatorId: operator['id'] as int,
      operatorName: (operator['name'] ?? 'Operator').toString(),
      role: (json['role'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
      message: json['message']?.toString(),
    );
  }
}

class OperatorWorkspaceContext {
  const OperatorWorkspaceContext({
    required this.operatorId,
    required this.operatorName,
    required this.selectionRequired,
  });

  final int? operatorId;
  final String? operatorName;
  final bool selectionRequired;

  factory OperatorWorkspaceContext.fromJson(Map<String, Object?> json) {
    final context = _map(json['operator_context']);
    final operator = _map(context['operator']);
    return OperatorWorkspaceContext(
      operatorId: operator['id'] as int?,
      operatorName: operator['trading_name']?.toString() ?? operator['legal_entity']?.toString(),
      selectionRequired: context['selection_required'] == true,
    );
  }
}

Map<String, Object?> _map(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
  return const <String, Object?>{};
}
