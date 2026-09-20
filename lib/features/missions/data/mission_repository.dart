import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import 'mission_models.dart';
import '../../aeronautical_information/data/briefing_models.dart';

class MissionRepository {
  MissionRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<YawMission>> fetchMissions() async {
    final response = await _apiClient.get('missions');
    final missions = response.data['missions'];

    if (missions is! List) {
      return const [];
    }

    return missions
        .whereType<Map>()
        .map((item) => YawMission.fromJson(_asMap(item)))
        .toList(growable: false);
  }

  Future<YawMission> fetchMissionDetail(int id) async {
    final response = await _apiClient.get('missions/$id');
    return YawMission.fromJson(_asMap(response.data['mission']));
  }

  Future<YawMissionCompliance> fetchMissionCompliance(int id) async {
    final response = await _apiClient.get('missions/$id/compliance');
    return YawMissionCompliance.fromJson(_asMap(response.data['compliance']));
  }

  Future<YawPostFlightPropagation> fetchPostFlightPropagation(int id) async {
    final response = await _apiClient.get(
      'missions/$id/post-flight-propagation',
    );
    return YawPostFlightPropagation.fromJson(
      _asMap(response.data['post_flight_propagation']),
    );
  }

  Future<YawPostFlightPropagation> propagatePostFlight(
    int id,
    YawPostFlightSubmission submission,
  ) async {
    final response = await _apiClient.post(
      'missions/$id/post-flight-propagation',
      body: submission.toJson(),
    );
    return YawPostFlightPropagation.fromJson(
      _asMap(response.data['post_flight_propagation']),
    );
  }

  Future<YawBriefingView> fetchBriefing(int id, {int? revision}) async {
    final response = await _apiClient.get(
      'missions/$id/briefing',
      queryParameters: revision == null
          ? null
          : {'revision': revision.toString()},
    );
    return YawBriefingView.fromJson(response.data);
  }

  Future<YawBriefingView> generateBriefing(int id) async {
    final response = await _apiClient.post('missions/$id/briefing');
    return YawBriefingView.fromJson(response.data);
  }

  Future<YawBriefingView> acknowledgeBriefing(int id, int briefingId) async {
    final response = await _apiClient.post(
      'missions/$id/briefing/$briefingId/acknowledge',
      body: {'reviewed': true},
    );
    return YawBriefingView.fromJson(response.data);
  }

  Future<YawMission> releaseMission(int id) async {
    throw const ApiException(
      type: ApiExceptionType.notFound,
      message:
          'Mission release is not exposed by API V1. The Laravel web route cannot be used by mobile.',
    );
  }
}

Map<String, Object?> _asMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return const <String, Object?>{};
}
