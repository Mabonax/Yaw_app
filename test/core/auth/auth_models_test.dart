import 'package:flutter_test/flutter_test.dart';
import 'package:yaw_app/core/auth/auth_models.dart';

void main() {
  test('parses current user payload', () {
    final user = YawUser.fromJson({
      'id': 7,
      'name': 'YAW User',
      'email': 'user@yaw.test',
      'role': 'remote_pilot',
    });

    expect(user.id, 7);
    expect(user.name, 'YAW User');
    expect(user.role, 'remote_pilot');
  });

  test('parses pilot payload with nullable and list fields', () {
    final pilot = YawPilotProfile.fromJson({
      'id': 42,
      'display_name': 'Linked Pilot',
      'rpc_category': 'multi_rotor',
      'ratings': ['vlos', 'evlos'],
      'medical_status': 'valid',
      'radiotelephony_qualification': 'restricted',
      'profile_status': 'active',
    });

    expect(pilot.displayName, 'Linked Pilot');
    expect(pilot.ratings, ['vlos', 'evlos']);
    expect(pilot.isActive, isTrue);
    expect(pilot.email, isNull);
  });

  test('parses operator payload and display name fallback', () {
    final operator = YawOperatorContext.fromJson({
      'id': 3,
      'legal_entity': 'Legal Entity Pty',
      'trading_name': 'Trading Name',
      'uasoc_number': 'UASOC-001',
      'membership_role': 'operations_manager',
      'membership_status': 'active',
    });

    expect(operator.displayName, 'Trading Name');
    expect(operator.isGlobal, isFalse);
  });

  test('parses global operator access', () {
    final operator = YawOperatorContext.fromJson({
      'id': 4,
      'legal_entity': 'Global Operator',
      'trading_name': null,
      'uasoc_number': null,
      'membership_role': null,
      'membership_status': 'global',
    });

    expect(operator.displayName, 'Global Operator');
    expect(operator.isGlobal, isTrue);
  });
}
