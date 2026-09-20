import 'package:flutter/foundation.dart';
import '../../../core/api/api_exception.dart';
import '../../missions/data/mission_repository.dart';
import '../data/briefing_models.dart';

class BriefingController extends ChangeNotifier {
  BriefingController({required this.repository, required this.missionId});
  final MissionRepository repository;
  final int missionId;
  YawBriefingView? view;
  String? error;
  bool loading = false;
  bool _disposed = false;
  int _generation = 0;

  Future<void> load({int? revision}) =>
      _run(() => repository.fetchBriefing(missionId, revision: revision));
  Future<void> generate() => _run(() => repository.generateBriefing(missionId));
  Future<void> acknowledge() async {
    final id = view?.id;
    if (id == null) return;
    await _run(() => repository.acknowledgeBriefing(missionId, id));
  }

  Future<void> _run(Future<YawBriefingView> Function() operation) async {
    if (_disposed || loading) return;
    final generation = ++_generation;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await operation();
      if (!_disposed && generation == _generation) view = result;
    } on ApiException catch (failure) {
      if (!_disposed) {
        view = null;
        error =
            failure.errors?.values.expand((v) => v).join(' ') ??
            failure.message;
      }
    } catch (_) {
      if (!_disposed) {
        view = null;
        error = 'The briefing could not be verified. Reconnect and retry.';
      }
    } finally {
      if (!_disposed && generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
