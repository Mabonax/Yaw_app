import '../../../core/api/api_client.dart';
import 'operator_models.dart';

class OperatorWorkspaceRepository {
  OperatorWorkspaceRepository({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<List<OperatorMembership>> memberships() async {
    final response = await _apiClient.get('me/operator-memberships');
    final data = response.data['data'] ?? response.data;
    final list = data is List ? data : response.data['operator_memberships'];
    if (list is! List) return const [];
    return list.whereType<Map>().map((e) => OperatorMembership.fromJson(e.map((k,v)=>MapEntry(k.toString(),v)))).toList(growable:false);
  }

  Future<OperatorWorkspaceContext> context() async {
    final response = await _apiClient.get('me/operator-context');
    return OperatorWorkspaceContext.fromJson(response.data);
  }

  Future<void> transition(int membershipId, String action) async {
    await _apiClient.post('operator-memberships/$membershipId/transition', body: {'action': action});
  }

  Future<void> requestJoin(int operatorId, {String role = 'remote_pilot', String? message}) async {
    await _apiClient.post('operators/$operatorId/join-requests', body: {
      'membership_role': role,
      if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
    });
  }
}
