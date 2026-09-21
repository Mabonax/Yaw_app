import 'package:flutter_test/flutter_test.dart';
import 'package:yaw_app/features/operators/data/operator_models.dart';

void main() {
  test('personal mode membership counts keep invitations and join requests distinct', () {
    const memberships = [
      OperatorMembership(id: 1, operatorId: 10, operatorName: 'Alpha', role: 'remote_pilot', status: 'pending', source: 'invitation'),
      OperatorMembership(id: 2, operatorId: 20, operatorName: 'Bravo', role: 'remote_pilot', status: 'pending', source: 'join_request'),
      OperatorMembership(id: 3, operatorId: 30, operatorName: 'Charlie', role: 'remote_pilot', status: 'active', source: 'admin'),
    ];
    expect(memberships.where((m) => m.isInvitation).length, 1);
    expect(memberships.where((m) => m.isJoinRequest).length, 1);
    expect(memberships.where((m) => m.isActive).length, 1);
  });
}
