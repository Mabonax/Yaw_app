import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yaw_app/core/api/api_client.dart';
import 'package:yaw_app/features/aircraft/data/aircraft_models.dart';
import 'package:yaw_app/features/aircraft/data/aircraft_repository.dart';
import 'package:yaw_app/features/aircraft/presentation/aircraft_controller.dart';
import 'package:yaw_app/features/aircraft/presentation/aircraft_screens.dart';

void main() {
  group('aircraft models', () {
    test('parse aircraft readiness and package payloads', () {
      final aircraft = YawAircraft.fromJson(aircraftJson());

      expect(aircraft.displayName, 'DJI Matrice 350 RTK');
      expect(aircraft.readiness?.status, 'amber');
      expect(aircraft.readiness?.checks, hasLength(2));
      expect(aircraft.packageInstantiation.batteries.first.batteryUid, 'BAT-1');
      expect(
        aircraft.packageInstantiation.components.first.name,
        'Propeller set',
      );
    });

    test('handles list payloads with shallow package summaries', () {
      final aircraft = YawAircraft.fromJson({
        'id': 7,
        'registration': 'ZU-YAW',
        'manufacturer': 'DJI',
        'model': 'Matrice 350 RTK',
        'operator_names': ['YAW Ops'],
        'package_instantiation': {
          'state': 'instantiated',
          'battery_count': 2,
          'component_count': 1,
        },
      });

      expect(aircraft.packageInstantiation.batteries, isEmpty);
      expect(aircraft.packageInstantiation.batteryCount, 2);
      expect(aircraft.readiness, isNull);
    });
  });

  group('aircraft repository', () {
    test('fetches aircraft list and detail from API V1 routes', () async {
      final repository = AircraftRepository(
        apiClient: _client((request) async {
          if (request.url.path.endsWith('/aircraft/7')) {
            return _ok({'aircraft': aircraftJson()});
          }
          if (request.url.path.endsWith('/aircraft')) {
            return _ok({
              'aircraft': [aircraftJson()],
            });
          }
          return _error(404);
        }),
      );

      final aircraft = await repository.fetchAircraft();
      final detail = await repository.fetchAircraftDetail(7);

      expect(aircraft.single.registration, 'ZU-YAW');
      expect(detail.packageInstantiation.components, hasLength(1));
    });

    test('fetches catalogue and applies supported query filters', () async {
      late Uri seenUri;
      final repository = AircraftRepository(
        apiClient: _client((request) async {
          seenUri = request.url;
          return _ok({
            'aircraft_models': [catalogueModelJson()],
            'pagination': {
              'current_page': 1,
              'per_page': 25,
              'total': 1,
              'last_page': 1,
            },
          });
        }),
      );

      final page = await repository.fetchCatalogue(search: 'matrice');

      expect(seenUri.queryParameters['search'], 'matrice');
      expect(page.models.single.displayName, 'DJI Matrice 350 RTK');
    });
  });

  group('aircraft controller', () {
    test('publishes loaded readiness counts', () async {
      final controller = AircraftController(
        repository: AircraftRepository(
          apiClient: _client((request) async {
            return _ok({
              'aircraft': [aircraftJson()],
            });
          }),
        ),
      );

      await controller.loadAircraft();

      expect(controller.state.status, AircraftLoadStatus.loaded);
      expect(controller.state.totalAircraft, 1);
      expect(controller.state.reviewAircraft, 1);
    });

    test('publishes failure state when API fails', () async {
      final controller = AircraftController(
        repository: AircraftRepository(
          apiClient: _client((request) async => _error(500)),
        ),
      );

      await controller.loadAircraft();

      expect(controller.state.status, AircraftLoadStatus.failure);
      expect(controller.state.errorMessage, contains('server error'));
    });
  });

  group('aircraft widgets', () {
    testWidgets('renders list card readiness and package state', (
      tester,
    ) async {
      await tester.pumpWidget(
        _TestApp(
          child: AircraftCard(aircraft: YawAircraft.fromJson(aircraftJson())),
        ),
      );

      expect(find.text('DJI Matrice 350 RTK'), findsOneWidget);
      expect(find.text('Review required'), findsOneWidget);
      expect(find.text('Package Instantiated'), findsOneWidget);
    });

    testWidgets('renders aircraft detail package children', (tester) async {
      await tester.pumpWidget(
        _TestApp(
          child: AircraftDetailScreen(
            aircraft: YawAircraft.fromJson(aircraftJson()),
          ),
        ),
      );

      expect(find.text('Release readiness'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Batteries'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.scrollUntilVisible(
        find.text('Propeller set'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Batteries'), findsOneWidget);
      expect(find.text('Propeller set'), findsOneWidget);
    });

    testWidgets('renders catalogue detail package counts', (tester) async {
      await tester.pumpWidget(
        _TestApp(
          child: CatalogueDetailScreen(
            model: YawAircraftCatalogueModel.fromJson(catalogueModelJson()),
          ),
        ),
      );

      await tester.scrollUntilVisible(
        find.text('Performance envelope'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Performance envelope'), findsOneWidget);
      expect(find.text('2 batteries'), findsWidgets);
      expect(find.text('1 components'), findsWidgets);
    });
  });
}

ApiClient _client(Future<http.Response> Function(http.Request) handler) {
  return ApiClient(
    baseUrl: Uri.parse('https://example.test/api/v1'),
    tokenProvider: () async => 'token',
    httpClient: MockClient(handler),
  );
}

http.Response _ok(Map<String, Object?> data) {
  return http.Response(
    jsonEncode({
      'success': true,
      'message': null,
      'data': data,
      'errors': null,
      'error': null,
      'meta': {'contract_version': 'v1.0'},
    }),
    200,
  );
}

http.Response _error(int statusCode) {
  return http.Response(
    jsonEncode({
      'success': false,
      'message': 'Server error.',
      'data': null,
      'errors': null,
      'error': 'server_error',
      'meta': {'contract_version': 'v1.0'},
    }),
    statusCode,
  );
}

Map<String, Object?> aircraftJson() {
  return {
    'id': 7,
    'catalogue_model': catalogueModelJson(),
    'registration': 'ZU-YAW',
    'manufacturer': 'DJI',
    'model': 'Matrice 350 RTK',
    'serial_number': 'SN-001',
    'internal_asset_number': 'YAW-AIR-001',
    'aircraft_category': 'uas',
    'owner': 'YAW',
    'operator': 'YAW Ops',
    'supplier': 'DJI',
    'firmware_version': '01.02',
    'flight_controller_serial': 'FC-001',
    'remote_id_serial': 'RID-001',
    'acquisition_date': '2026-09-01',
    'operational_status': 'serviceable',
    'onboarding_status': 'active',
    'base_location': 'Cape Town',
    'operator_names': ['YAW Ops'],
    'readiness': {
      'status': 'amber',
      'label': 'Review required',
      'as_of': '2026-09-13',
      'checks': [
        {
          'code': 'serviceability',
          'label': 'Aircraft serviceability',
          'status': 'green',
          'summary': 'Operational status serviceable permits release.',
          'evidence': {'operational_status': 'serviceable'},
        },
        {
          'code': 'batteries',
          'label': 'Compatible batteries',
          'status': 'amber',
          'summary': 'One battery requires review.',
          'evidence': {'total': 2},
        },
      ],
      'blocking_reasons': [],
      'review_reasons': ['One battery requires review.'],
    },
    'package_instantiation': {
      'state': 'instantiated',
      'instantiated_at': '2026-09-13T10:00:00Z',
      'results': {'state': 'instantiated'},
      'battery_count': 2,
      'component_count': 1,
      'maintenance_baseline_count': 1,
      'batteries': [
        {
          'id': 20,
          'battery_uid': 'BAT-1',
          'package_item_key': 'tb65-1',
          'model': 'TB65',
          'health_status': 'serviceable',
          'retirement_status': 'active',
        },
      ],
      'components': [
        {
          'id': 30,
          'component_uid': 'CMP-1',
          'package_item_key': 'propeller-set-1',
          'component_type': 'propeller',
          'name': 'Propeller set',
          'status': 'active',
          'life_limit_hours': 120,
          'life_limit_cycles': 400,
        },
      ],
    },
  };
}

Map<String, Object?> catalogueModelJson() {
  return {
    'id': 3,
    'manufacturer': {'id': 1, 'name': 'DJI', 'slug': 'dji'},
    'model': 'Matrice 350 RTK',
    'family': 'Matrice',
    'aircraft_type': 'multi_rotor',
    'primary_use': 'inspection',
    'status': 'active',
    'weight_kg': 3.7,
    'mtow_kg': 9.2,
    'max_payload_kg': 2.7,
    'max_flight_time_min': 55,
    'max_speed_m_s': 23,
    'max_range_km': 8,
    'service_ceiling_m': 7000,
    'max_wind_m_s': 12,
    'ip_rating': 'IP55',
    'operating_temp_c': '-20 to 50',
    'dimensions': '810 x 670 x 430',
    'wingspan_mm': null,
    'gnss': 'GPS, GLONASS, Galileo, BeiDou',
    'camera_payload_summary': 'Zenmuse compatible',
    'remote_id': 'supported',
    'source_url': 'https://example.test/matrice',
    'image_source_url': null,
    'image_license_status': 'pending_review',
    'notes': 'Catalogue test model.',
    'verified_at': '2026-09-13',
    'media_status': 'metadata_only',
    'source_priority': 1,
    'catalogue_status': 'verified',
    'package_status': 'complete',
    'battery_package': [
      {'key': 'tb65', 'quantity': 2},
    ],
    'component_package': [
      {'key': 'propeller-set', 'quantity': 1},
    ],
    'maintenance_package': [
      {'name': 'Initial inspection'},
    ],
    'package_counts': {
      'batteries': 2,
      'components': 1,
      'maintenance_baselines': 1,
    },
  };
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: child));
  }
}
