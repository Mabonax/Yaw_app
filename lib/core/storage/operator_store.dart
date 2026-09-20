import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class OperatorStore {
  Future<int?> readOperatorId();
  Future<void> saveOperatorId(int id);
  Future<void> clear();
}

class SecureOperatorStore implements OperatorStore {
  SecureOperatorStore({FlutterSecureStorage storage = const FlutterSecureStorage()}) : _storage = storage;
  static const _key = 'yaw.active_operator_id';
  final FlutterSecureStorage _storage;

  @override
  Future<int?> readOperatorId() async {
    final value = await _storage.read(key: _key);
    return value == null ? null : int.tryParse(value);
  }

  @override
  Future<void> saveOperatorId(int id) => _storage.write(key: _key, value: '$id');

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

class MemoryOperatorStore implements OperatorStore {
  int? _id;
  @override Future<int?> readOperatorId() async => _id;
  @override Future<void> saveOperatorId(int id) async { _id = id; }
  @override Future<void> clear() async { _id = null; }
}
