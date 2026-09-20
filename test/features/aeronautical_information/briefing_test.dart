import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yaw_app/core/api/api_client.dart';
import 'package:yaw_app/features/aeronautical_information/data/briefing_models.dart';
import 'package:yaw_app/features/aeronautical_information/presentation/briefing_controller.dart';
import 'package:yaw_app/features/aeronautical_information/presentation/briefing_screen.dart';
import 'package:yaw_app/features/missions/data/mission_repository.dart';

Map<String, Object?> briefingPayload({
  String status = 'amber',
  bool canAcknowledge = true,
  bool acknowledged = false,
}) => {
  'mission': {'id': 9, 'mission_number': 'TEST-MISSION'},
  'briefing': {
    'id': 41,
    'revision': 1,
    'status': status,
    'generated_at': '2026-09-15T08:00:00Z',
    'valid_until': '2026-09-15T09:00:00Z',
    'acknowledgement_required': true,
    'acknowledged': acknowledged,
    'items': [
      {
        'id': 7,
        'source_identifier': 'TEST-ONLY',
        'title': 'Synthetic warning',
        'type': 'NOTAM',
        'severity': 'warning',
        'release_effect': 'acknowledge',
        'reason': 'Server-supplied assessment',
        'source_classification': 'test_fixture',
        'usable_for_release': false,
        'source': {
          'raw_message': 'TEST SOURCE',
          'raw_payload': {'original': 'TEST SOURCE'},
        },
        'interpretation': {'hazard': 'warning'},
      },
    ],
  },
  'compliance': {
    'status': status,
    'freshness': 'fresh',
    'reasons': ['Server-supplied reason'],
  },
  'permissions': {'generate': true, 'acknowledge': canAcknowledge},
  'revisions': [
    {'id': 41, 'revision': 1},
  ],
};

MissionRepository repository(
  Future<http.Response> Function(http.Request) respond,
) => MissionRepository(
  apiClient: ApiClient(
    baseUrl: Uri.parse('https://example.test/api/v1'),
    tokenProvider: () async => 'test-token',
    httpClient: MockClient(respond),
  ),
);

http.Response ok(Map<String, Object?> data) => http.Response(
  jsonEncode({
    'success': true,
    'data': data,
    'message': null,
    'error': null,
    'errors': null,
    'meta': {'contract_version': 'v1.0'},
  }),
  200,
);

void main() {
  test(
    'retains server statuses and separates raw source from interpretation',
    () {
      final result = YawBriefingView.fromJson(
        briefingPayload(status: 'red', canAcknowledge: false),
      );
      expect(result.status, 'red');
      expect(result.canAcknowledge, isFalse);
      expect(result.items.single.rawMessage, 'TEST SOURCE');
      expect(result.items.single.interpretation['hazard'], 'warning');
      expect(result.items.single.usableForRelease, isFalse);
    },
  );

  test('rejects malformed responses instead of showing clearance', () {
    expect(() => YawBriefingView.fromJson({}), throwsFormatException);
  });

  test(
    'uses API V1 paths and submits only acknowledgement confirmation',
    () async {
      final seen = <http.Request>[];
      final repo = repository((request) async {
        seen.add(request);
        return ok(briefingPayload());
      });
      await repo.fetchBriefing(9, revision: 2);
      await repo.generateBriefing(9);
      await repo.acknowledgeBriefing(9, 41);
      expect(seen[0].url.path, '/api/v1/missions/9/briefing');
      expect(seen[0].url.queryParameters, {'revision': '2'});
      expect(seen[1].method, 'POST');
      expect(jsonDecode(seen[1].body), <String, Object?>{});
      expect(seen[2].url.path, '/api/v1/missions/9/briefing/41/acknowledge');
      expect(jsonDecode(seen[2].body), {'reviewed': true});
      expect(seen[2].headers['authorization'], 'Bearer test-token');
    },
  );

  test(
    'clears cached status on failed refresh and surfaces server errors',
    () async {
      var calls = 0;
      final controller = BriefingController(
        missionId: 9,
        repository: repository((_) async {
          if (calls++ != 1) {
            return ok(briefingPayload(status: 'red', canAcknowledge: false));
          }
          return http.Response(
            jsonEncode({
              'success': false,
              'data': null,
              'message': 'Source unavailable',
              'error': 'unavailable',
              'errors': null,
              'meta': {'contract_version': 'v1.0'},
            }),
            503,
          );
        }),
      );
      await controller.load();
      expect(controller.view, isNotNull);
      await controller.load();
      expect(controller.view, isNull);
      expect(controller.error, 'Source unavailable');
      await controller.acknowledge();
      expect(
        calls,
        2,
      ); // Failed cached state cannot initiate an acknowledgement.
      await controller.load();
      expect(controller.error, isNull);
      expect(controller.view!.status, 'red');
      expect(controller.view!.canAcknowledge, isFalse);
      controller.dispose();
    },
  );

  test('refreshes acknowledged state from the server response', () async {
    final controller = BriefingController(
      missionId: 9,
      repository: repository(
        (request) async =>
            ok(briefingPayload(acknowledged: request.method == 'POST')),
      ),
    );
    await controller.load();
    await controller.acknowledge();
    expect(controller.view!.acknowledged, isTrue);
    controller.dispose();
  });

  testWidgets('shows unavailable state without an acknowledgement action', (
    tester,
  ) async {
    final payload = briefingPayload(status: 'red', canAcknowledge: false);
    payload['compliance'] = {
      'status': 'red',
      'freshness': 'unavailable',
      'reasons': ['Operational feed unavailable'],
      'providers': [
        {
          'provider': 'atns_aim',
          'status': 'unavailable',
          'health_status': 'unconfigured',
          'reason': 'Official operational provider is not configured.',
        },
      ],
    };
    final controller = BriefingController(
      missionId: 9,
      repository: repository((_) async => ok(payload)),
    );
    await tester.pumpWidget(
      MaterialApp(home: MissionBriefingScreen(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Operational feed unavailable'), findsOneWidget);
    expect(find.text('State: unconfigured'), findsOneWidget);
    expect(
      find.text('Official operational provider is not configured.'),
      findsOneWidget,
    );
    expect(find.text('Acknowledge briefing'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('acknowledges reviewed briefing and shows server confirmation', (
    tester,
  ) async {
    final controller = BriefingController(
      missionId: 9,
      repository: repository(
        (request) async =>
            ok(briefingPayload(acknowledged: request.method == 'POST')),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: MissionBriefingScreen(controller: controller)),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Acknowledge briefing'));
    await tester.tap(find.text('Acknowledge briefing'));
    await tester.pumpAndSettle();
    expect(find.text('Acknowledgement recorded'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'detail displays source and interpretation in separate sections',
    (tester) async {
      final item = YawBriefingView.fromJson(briefingPayload()).items.single;
      await tester.pumpWidget(
        MaterialApp(home: BriefingItemScreen(item: item)),
      );
      expect(find.text('Source content'), findsOneWidget);
      expect(find.text('TEST SOURCE'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('YAW normalized interpretation'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('YAW normalized interpretation'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
