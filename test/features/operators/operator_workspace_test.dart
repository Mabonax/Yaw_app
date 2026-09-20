import 'package:flutter_test/flutter_test.dart';
import 'package:yaw_app/core/storage/operator_store.dart';
import 'package:yaw_app/features/operators/data/operator_models.dart';
import 'package:yaw_app/features/operators/presentation/operator_workspace_controller.dart';

class FakeRepo {
  FakeRepo(this.items);
  List<OperatorMembership> items;
}

void main() {
  test('operator model identifies active and pending states', () {
    final active = OperatorMembership.fromJson({
      'id': 1,
      'operator': {'id': 10, 'name': 'Alpha'},
      'role': 'remote_pilot',
      'status': 'active',
      'source': 'admin',
    });
    final pending = OperatorMembership.fromJson({
      'id': 2,
      'operator': {'id': 11, 'name': 'Bravo'},
      'role': 'remote_pilot',
      'status': 'pending',
      'source': 'invitation',
    });

    expect(active.isActive, isTrue);
    expect(pending.isPending, isTrue);
  });

  test('memory operator store persists and clears selected tenant', () async {
    final store = MemoryOperatorStore();
    expect(await store.readOperatorId(), isNull);
    await store.saveOperatorId(42);
    expect(await store.readOperatorId(), 42);
    await store.clear();
    expect(await store.readOperatorId(), isNull);
  });
}
