import '../../../core/api/api_client.dart';
import 'aircraft_models.dart';

class AircraftRepository {
  AircraftRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<YawAircraft>> fetchAircraft() async {
    final response = await _apiClient.get('aircraft');
    final aircraft = response.data['aircraft'];

    if (aircraft is! List) {
      return const [];
    }

    return aircraft
        .whereType<Map>()
        .map((item) => YawAircraft.fromJson(_asMap(item)))
        .toList(growable: false);
  }

  Future<YawAircraft> fetchAircraftDetail(int id) async {
    final response = await _apiClient.get('aircraft/$id');
    return YawAircraft.fromJson(_asMap(response.data['aircraft']));
  }

  Future<YawAircraftCataloguePage> fetchCatalogue({
    String? search,
    String? manufacturer,
    String? aircraftType,
    String? status,
    String? catalogueStatus,
    int? page,
  }) async {
    final query = <String, String>{
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (manufacturer != null && manufacturer.trim().isNotEmpty)
        'manufacturer': manufacturer.trim(),
      if (aircraftType != null && aircraftType.trim().isNotEmpty)
        'aircraft_type': aircraftType.trim(),
      if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      if (catalogueStatus != null && catalogueStatus.trim().isNotEmpty)
        'catalogue_status': catalogueStatus.trim(),
      if (page != null && page > 0) 'page': '$page',
    };

    final response = await _apiClient.get(
      'aircraft-catalogue',
      queryParameters: query.isEmpty ? null : query,
    );

    return YawAircraftCataloguePage.fromJson(response.data);
  }

  Future<YawAircraftCatalogueModel> fetchCatalogueDetail(int id) async {
    final response = await _apiClient.get('aircraft-catalogue/$id');
    return YawAircraftCatalogueModel.fromJson(
      _asMap(response.data['aircraft_model']),
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
