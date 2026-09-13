import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yaw_app/core/api/api_client.dart';
import 'package:yaw_app/core/api/api_exception.dart';
import 'package:yaw_app/features/aircraft/data/aircraft_repository.dart';
import 'package:yaw_app/features/aircraft/presentation/aircraft_controller.dart';
import 'package:yaw_app/features/missions/data/mission_models.dart';
import 'package:yaw_app/features/missions/data/mission_repository.dart';
import 'package:yaw_app/features/missions/presentation/mission_controller.dart';
import 'package:yaw_app/features/missions/presentation/mission_screens.dart';

void main() {
  group('mission models', () {
    test(
      'parse mission detail, lifecycle, compliance, blockers, and warnings',
      () {
        final mission = YawMission.fromJson(missionJson());

        expect(mission.displayTitle, 'MIS-001');
        expect(mission.lifecycleStatus, YawMissionLifecycleStatus.approved);
        expect(mission.aircraft?.registration, 'ZU-YAW');
        expect(mission.pilot?.displayName, 'Mission Pilot');
        expect(mission.compliance.status, 'amber');
        expect(mission.compliance.warningCount, 1);
        expect(mission.compliance.controls, hasLength(3));
        expect(
          mission.compliance.controls.last.reasons.single,
          'Risk pending.',
        );
      },
    );

    test('maps unknown lifecycle status safely', () {
      final mission = YawMission.fromJson({
        ...missionJson(),
        'lifecycle_state': 'future_state',
      });

      expect(mission.lifecycleStatus, YawMissionLifecycleStatus.unknown);
    });

    test(
      'parses post-flight propagation and serializes close-out payloads',
      () {
        final propagation = YawPostFlightPropagation.fromJson(
          postFlightJson(propagated: true),
        );
        final submission = const YawPostFlightSubmission(
          actualTakeoffAt: '2026-09-14T08:05:00Z',
          actualLandingAt: '2026-09-14T08:42:00Z',
          pilotConfirmed: true,
          aircraftConfirmed: true,
          defectsDeclared: false,
          occurrenceDeclared: false,
          closureNotes: ' Flight completed. ',
        );

        expect(propagation.isPropagated, isTrue);
        expect(propagation.pilotLogEntryId, 101);
        expect(propagation.aircraftFlightFolioId, 202);
        expect(propagation.batteryUsageCount, 2);
        expect(propagation.blockingReasons, isEmpty);
        expect(submission.toJson(), {
          'actual_takeoff_at': '2026-09-14T08:05:00Z',
          'actual_landing_at': '2026-09-14T08:42:00Z',
          'pilot_confirmed': true,
          'aircraft_confirmed': true,
          'defects_declared': false,
          'occurrence_declared': false,
          'closure_notes': 'Flight completed.',
        });
      },
    );
  });

  group('mission repository', () {
    test(
      'fetches mission list, detail, and compliance from API V1 routes',
      () async {
        final seen = <String>[];
        final repository = MissionRepository(
          apiClient: _client((request) async {
            seen.add(request.url.path);
            if (request.url.path.endsWith('/missions/9/compliance')) {
              return _ok({'compliance': complianceJson(status: 'green')});
            }
            if (request.url.path.endsWith('/missions/9')) {
              return _ok({'mission': missionJson(status: 'green')});
            }
            if (request.url.path.endsWith('/missions')) {
              return _ok({
                'missions': [missionJson()],
              });
            }
            return _error(404, 'Not found.');
          }),
        );

        final missions = await repository.fetchMissions();
        final detail = await repository.fetchMissionDetail(9);
        final compliance = await repository.fetchMissionCompliance(9);

        expect(missions.single.missionNumber, 'MIS-001');
        expect(detail.compliance.status, 'green');
        expect(compliance.status, 'green');
        expect(seen, contains('/api/v1/missions/9/compliance'));
      },
    );

    test('surfaces forbidden, not found, and network failures', () async {
      final forbidden = MissionRepository(
        apiClient: _client((request) async => _error(403, 'Forbidden.')),
      );
      final notFound = MissionRepository(
        apiClient: _client((request) async => _error(404, 'Missing mission.')),
      );
      final network = MissionRepository(
        apiClient: _client(
          (request) async => throw const SocketException('offline'),
        ),
      );

      await expectLater(
        forbidden.fetchMissions(),
        throwsA(isA<ApiException>()),
      );
      await expectLater(
        notFound.fetchMissionDetail(99),
        throwsA(isA<ApiException>()),
      );
      await expectLater(
        network.fetchMissionCompliance(9),
        throwsA(isA<ApiException>()),
      );
    });

    test(
      'fetches and submits post-flight propagation through API V1',
      () async {
        final seen = <String>[];
        Map<String, Object?>? submitted;
        final repository = MissionRepository(
          apiClient: _client((request) async {
            seen.add('${request.method} ${request.url.path}');
            if (request.method == 'POST') {
              submitted = jsonDecode(request.body) as Map<String, Object?>;
              return _ok({
                'post_flight_propagation': postFlightJson(propagated: true),
              });
            }
            return _ok({'post_flight_propagation': postFlightJson()});
          }),
        );

        final summary = await repository.fetchPostFlightPropagation(9);
        final propagated = await repository.propagatePostFlight(
          9,
          const YawPostFlightSubmission(
            actualTakeoffAt: '2026-09-14T08:05:00Z',
            actualLandingAt: '2026-09-14T08:42:00Z',
            pilotConfirmed: true,
            aircraftConfirmed: true,
            defectsDeclared: false,
            occurrenceDeclared: true,
            closureNotes: 'Occurrence logged in ops register.',
          ),
        );

        expect(summary.canPropagate, isTrue);
        expect(propagated.isPropagated, isTrue);
        expect(seen, [
          'GET /api/v1/missions/9/post-flight-propagation',
          'POST /api/v1/missions/9/post-flight-propagation',
        ]);
        expect(submitted?['occurrence_declared'], isTrue);
        expect(submitted, isNot(contains('actual_flight_duration_minutes')));
      },
    );

    test('release action is not implemented until API V1 exposes it', () async {
      final repository = MissionRepository(
        apiClient: _client((request) async => _ok({'mission': missionJson()})),
      );

      await expectLater(
        repository.releaseMission(9),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            contains('not exposed by API V1'),
          ),
        ),
      );
    });
  });

  group('mission controller', () {
    test('loads mission list counts and selected detail', () async {
      final controller = MissionController(
        repository: MissionRepository(
          apiClient: _client((request) async {
            if (request.url.path.endsWith('/missions/9')) {
              return _ok({'mission': missionJson(status: 'green')});
            }
            return _ok({
              'missions': [missionJson()],
            });
          }),
        ),
      );

      await controller.loadMissions();
      await controller.loadMissionDetail(9);

      expect(controller.state.status, MissionLoadStatus.loaded);
      expect(controller.state.totalMissions, 1);
      expect(controller.state.warningMissions, 1);
      expect(controller.state.selectedMission?.compliance.status, 'green');
    });

    test('supports empty and failure states', () async {
      final empty = MissionController(
        repository: MissionRepository(
          apiClient: _client((request) async => _ok({'missions': []})),
        ),
      );
      final failure = MissionController(
        repository: MissionRepository(
          apiClient: _client((request) async => _error(500, 'Server error.')),
        ),
      );

      await empty.loadMissions();
      await failure.loadMissions();

      expect(empty.state.status, MissionLoadStatus.empty);
      expect(failure.state.status, MissionLoadStatus.failure);
      expect(failure.state.errorMessage, contains('server error'));
    });

    test(
      'submits post-flight close-out and refreshes selected mission state',
      () async {
        final controller = MissionController(
          repository: MissionRepository(
            apiClient: _client((request) async {
              if (request.url.path.endsWith('/post-flight-propagation') &&
                  request.method == 'POST') {
                return _ok({
                  'post_flight_propagation': postFlightJson(propagated: true),
                });
              }
              if (request.url.path.endsWith('/post-flight-propagation')) {
                return _ok({'post_flight_propagation': postFlightJson()});
              }
              if (request.url.path.endsWith('/missions/9')) {
                return _ok({'mission': missionJson(lifecycle: 'completed')});
              }
              return _ok({
                'missions': [missionJson(lifecycle: 'completed')],
              });
            }),
          ),
        );

        await controller.loadMissionDetail(9);
        final submitted = await controller.submitPostFlight(
          const YawPostFlightSubmission(
            actualTakeoffAt: '2026-09-14T08:05:00Z',
            actualLandingAt: '2026-09-14T08:42:00Z',
            pilotConfirmed: true,
            aircraftConfirmed: true,
            defectsDeclared: false,
            occurrenceDeclared: false,
          ),
        );

        expect(submitted, isTrue);
        expect(controller.state.postFlightMessage, contains('propagated'));
        expect(
          controller.state.selectedPostFlightPropagation?.isPropagated,
          isTrue,
        );
      },
    );

    test('reports post-flight validation errors from the API', () async {
      final controller = MissionController(
        repository: MissionRepository(
          apiClient: _client((request) async {
            if (request.url.path.endsWith('/post-flight-propagation') &&
                request.method == 'POST') {
              return _validationError({
                'post_flight_checklist': [
                  'A post-flight checklist must be completed before propagation.',
                ],
              });
            }
            if (request.url.path.endsWith('/post-flight-propagation')) {
              return _ok({'post_flight_propagation': postFlightJson()});
            }
            return _ok({'mission': missionJson(lifecycle: 'completed')});
          }),
        ),
      );

      await controller.loadMissionDetail(9);
      final submitted = await controller.submitPostFlight(
        const YawPostFlightSubmission(
          actualTakeoffAt: '2026-09-14T08:05:00Z',
          actualLandingAt: '2026-09-14T08:42:00Z',
          pilotConfirmed: true,
          aircraftConfirmed: true,
          defectsDeclared: false,
          occurrenceDeclared: false,
        ),
      );

      expect(submitted, isFalse);
      expect(controller.state.postFlightErrorMessage, contains('checklist'));
    });

    test('prevents duplicate release attempts and reports API gap', () async {
      final controller = MissionController(
        repository: MissionRepository(
          apiClient: _client((request) async {
            if (request.url.path.endsWith('/missions/9')) {
              return _ok({'mission': missionJson()});
            }
            return _ok({
              'missions': [missionJson()],
            });
          }),
        ),
      );

      await controller.loadMissionDetail(9);
      final released = await controller.releaseSelectedMission();

      expect(released, isFalse);
      expect(controller.state.releaseErrorMessage, contains('not exposed'));
    });
  });

  group('mission widgets', () {
    testWidgets('renders mission card status and assignments', (tester) async {
      await tester.pumpWidget(
        _TestApp(
          child: MissionCard(mission: YawMission.fromJson(missionJson())),
        ),
      );

      expect(find.text('MIS-001'), findsOneWidget);
      expect(find.text('Review before release'), findsOneWidget);
      expect(find.text('ZU-YAW · Matrice 350 RTK'), findsOneWidget);
    });

    testWidgets('renders mission detail compliance and release API gap', (
      tester,
    ) async {
      final mission = YawMission.fromJson(missionJson());
      final missionController = MissionController(
        repository: MissionRepository(
          apiClient: _client(
            (request) async => _ok({'mission': missionJson()}),
          ),
        ),
      );
      final aircraftController = AircraftController(
        repository: AircraftRepository(
          apiClient: _client((request) async => _ok({'aircraft': []})),
        ),
      );

      await missionController.loadMissionDetail(9);
      await tester.pumpWidget(
        _TestApp(
          child: MissionDetailScreen(
            mission: mission,
            controller: missionController,
            aircraftController: aircraftController,
          ),
        ),
      );

      expect(find.text('Release readiness'), findsOneWidget);
      expect(find.text('Release API required'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Mission compliance'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Aircraft'), findsWidgets);
      expect(find.text('Risk assessment'), findsOneWidget);
    });

    testWidgets('renders post-flight close-out form and submits payload', (
      tester,
    ) async {
      final mission = YawMission.fromJson(missionJson(lifecycle: 'completed'));
      final controller = MissionController(
        repository: MissionRepository(
          apiClient: _client((request) async {
            if (request.url.path.endsWith('/post-flight-propagation') &&
                request.method == 'POST') {
              final body = jsonDecode(request.body) as Map<String, Object?>;
              expect(body['pilot_confirmed'], isTrue);
              expect(body['aircraft_confirmed'], isTrue);
              return _ok({
                'post_flight_propagation': postFlightJson(propagated: true),
              });
            }
            if (request.url.path.endsWith('/post-flight-propagation')) {
              return _ok({'post_flight_propagation': postFlightJson()});
            }
            if (request.url.path.endsWith('/missions/9')) {
              return _ok({'mission': missionJson(lifecycle: 'completed')});
            }
            return _ok({
              'missions': [missionJson(lifecycle: 'completed')],
            });
          }),
        ),
      );

      await controller.loadMissionDetail(9);
      await tester.pumpWidget(
        _TestApp(
          child: MissionPostFlightFormScreen(
            mission: mission,
            controller: controller,
          ),
        ),
      );

      expect(find.text('Post-flight close-out'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Actual takeoff ISO time'),
        '2026-09-14T08:05:00Z',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Actual landing ISO time'),
        '2026-09-14T08:42:00Z',
      );
      await tester.tap(find.text('Pilot confirms the logbook actuals'));
      await tester.tap(find.text('Aircraft record is confirmed'));
      await tester.scrollUntilVisible(
        find.text('Propagate records'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Propagate records'));
      await tester.pumpAndSettle();

      expect(
        controller.state.selectedPostFlightPropagation?.isPropagated,
        isTrue,
      );
    });

    testWidgets('renders compliance overview attention queue', (tester) async {
      final missionController = MissionController(
        repository: MissionRepository(
          apiClient: _client((request) async {
            return _ok({
              'missions': [missionJson()],
            });
          }),
        ),
      );
      final aircraftController = AircraftController(
        repository: AircraftRepository(
          apiClient: _client((request) async => _ok({'aircraft': []})),
        ),
      );

      await tester.pumpWidget(
        _TestApp(
          child: MissionComplianceOverviewScreen(
            missionController: missionController,
            aircraftController: aircraftController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mission attention queue'), findsOneWidget);
      expect(find.text('MIS-001'), findsOneWidget);
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

http.Response _validationError(Map<String, List<String>> errors) {
  return http.Response(
    jsonEncode({
      'success': false,
      'message': 'The given data was invalid.',
      'data': null,
      'errors': errors,
      'error': 'validation_failed',
      'meta': {'contract_version': 'v1.0'},
    }),
    422,
  );
}

http.Response _error(int statusCode, String message) {
  return http.Response(
    jsonEncode({
      'success': false,
      'message': message,
      'data': null,
      'errors': null,
      'error': 'request_failed',
      'meta': {'contract_version': 'v1.0'},
    }),
    statusCode,
  );
}

Map<String, Object?> missionJson({
  String status = 'amber',
  String lifecycle = 'approved',
}) {
  return {
    'id': 9,
    'mission_number': 'MIS-001',
    'purpose': 'Infrastructure inspection',
    'client_project': 'Bridge Survey',
    'location': 'Clear test range',
    'latitude': -24.0,
    'longitude': 27.0,
    'mission_polygon': [],
    'operation_category': 'inspection',
    'operator': {'id': 5, 'legal_entity': 'YAW Ops'},
    'aircraft': {'id': 7, 'registration': 'ZU-YAW', 'model': 'Matrice 350 RTK'},
    'pilot': {'id': 11, 'display_name': 'Mission Pilot'},
    'observers_crew': [],
    'planned_start_at': '2026-09-14T08:00:00Z',
    'planned_end_at': '2026-09-14T10:00:00Z',
    'actual_takeoff_at': null,
    'actual_landing_at': null,
    'actual_flight_duration_minutes': null,
    'completed_at': null,
    'maximum_altitude_ft': 400,
    'planned_distance_km': 2.5,
    'operation_visibility': 'vlos',
    'day_night': 'day',
    'weather': 'Clear',
    'airspace_assessment': 'Uncontrolled',
    'approvals': [],
    'risk_assessment': {'overall': status == 'green' ? 'low' : 'pending'},
    'emergency_arrangements': 'Landing area briefed.',
    'lifecycle_state': lifecycle,
    'release_gate_state': status,
    'release_gate_results': {'state': status, 'checks': []},
    'compliance': complianceJson(status: status),
    'post_flight_propagation': postFlightJson(
      canPropagate: lifecycle == 'completed',
    ),
    'regulatory_source': 'FR-MIS-001',
    'regulatory_source_version': 'v1.0',
    'regulatory_effective_date': '2026-09-09',
    'regulatory_applicability': 'Mission compliance test.',
    'responsible_role': 'Operations Manager',
    'created_at': '2026-09-13T10:00:00Z',
  };
}

Map<String, Object?> postFlightJson({
  bool canPropagate = true,
  bool propagated = false,
}) {
  return {
    'state': propagated ? 'propagated_with_follow_up' : 'pending',
    'label': propagated ? 'Propagated with follow-up' : 'Pending propagation',
    'can_propagate': canPropagate && !propagated,
    'propagated_at': propagated ? '2026-09-14T08:45:00Z' : null,
    'actual_takeoff_at': propagated ? '2026-09-14T08:05:00Z' : null,
    'actual_landing_at': propagated ? '2026-09-14T08:42:00Z' : null,
    'actual_flight_duration_minutes': propagated ? 37 : null,
    'completed_at': propagated ? '2026-09-14T08:45:00Z' : null,
    'pilot_log_entry_id': propagated ? 101 : null,
    'aircraft_flight_folio_id': propagated ? 202 : null,
    'latest_checklist_state': 'completed_with_exceptions',
    'post_flight_declaration': {
      'pilot_confirmed': propagated,
      'aircraft_confirmed': propagated,
      'defects_declared': false,
      'occurrence_declared': false,
      'closure_notes': propagated ? 'Flight completed.' : null,
    },
    'results': {
      'battery_cycles_summarised': 2,
      'battery_usage_count': 2,
      'flight_track_count': 1,
      'defect_count': 1,
      'open_defect_count': propagated ? 1 : 0,
    },
    'blocking_reasons': canPropagate || propagated
        ? []
        : ['Post-flight checklist has not been recorded.'],
  };
}

Map<String, Object?> complianceJson({String status = 'amber'}) {
  final warningCount = status == 'amber' ? 1 : 0;
  final blockingCount = status == 'red' ? 1 : 0;
  return {
    'status': status,
    'label': switch (status) {
      'green' => 'Release ready',
      'red' => 'Release blocked',
      _ => 'Review before release',
    },
    'blocking_count': blockingCount,
    'warning_count': warningCount,
    'evaluated_at': '2026-09-13T10:00:00Z',
    'controls': [
      {
        'key': 'aircraft_readiness',
        'label': 'Aircraft',
        'status': 'green',
        'basis': 'regulatory',
        'summary': 'Ready',
        'blocking': false,
        'details': {
          'aircraft_id': 7,
          'registration': 'ZU-YAW',
          'aircraft_readiness': {'status': 'green', 'label': 'Ready'},
        },
        'reasons': [],
        'action_href': '/aircraft/7',
      },
      {
        'key': 'pilot_readiness',
        'label': 'Pilot',
        'status': 'green',
        'basis': 'regulatory',
        'summary': 'Pilot current.',
        'blocking': false,
        'details': {},
        'reasons': [],
        'action_href': null,
      },
      {
        'key': 'risk_assessment',
        'label': 'Risk assessment',
        'status': status == 'green' ? 'green' : status,
        'basis': 'internal_policy',
        'summary': status == 'green'
            ? 'Risk assessment evidence is captured.'
            : 'Risk assessment is not yet captured.',
        'blocking': status == 'red',
        'details': {},
        'reasons': status == 'green' ? [] : ['Risk pending.'],
        'action_href': null,
      },
    ],
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
