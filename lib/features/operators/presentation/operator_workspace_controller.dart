import 'package:flutter/foundation.dart';

import '../../../core/storage/operator_store.dart';
import '../data/operator_models.dart';
import '../data/operator_workspace_repository.dart';

enum OperatorWorkspaceStatus { idle, loading, ready, selectionRequired, noOperator, failure }

class OperatorWorkspaceState {
  const OperatorWorkspaceState({
    this.status = OperatorWorkspaceStatus.idle,
    this.memberships = const [],
    this.activeOperatorId,
    this.activeOperatorName,
    this.errorMessage,
  });

  final OperatorWorkspaceStatus status;
  final List<OperatorMembership> memberships;
  final int? activeOperatorId;
  final String? activeOperatorName;
  final String? errorMessage;

  OperatorWorkspaceState copyWith({
    OperatorWorkspaceStatus? status,
    List<OperatorMembership>? memberships,
    int? activeOperatorId,
    String? activeOperatorName,
    String? errorMessage,
    bool clearActive = false,
    bool clearError = false,
  }) => OperatorWorkspaceState(
    status: status ?? this.status,
    memberships: memberships ?? this.memberships,
    activeOperatorId: clearActive ? null : (activeOperatorId ?? this.activeOperatorId),
    activeOperatorName: clearActive ? null : (activeOperatorName ?? this.activeOperatorName),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}

class OperatorWorkspaceController extends ChangeNotifier {
  OperatorWorkspaceController({required OperatorWorkspaceRepository repository, required OperatorStore store})
      : _repository = repository, _store = store;

  final OperatorWorkspaceRepository _repository;
  final OperatorStore _store;
  OperatorWorkspaceState _state = const OperatorWorkspaceState();
  OperatorWorkspaceState get state => _state;

  Future<void> load() async {
    _state = _state.copyWith(status: OperatorWorkspaceStatus.loading, clearError: true);
    notifyListeners();
    try {
      final memberships = await _repository.memberships();
      final active = memberships.where((m) => m.isActive).toList(growable: false);
      final persisted = await _store.readOperatorId();
      OperatorMembership? selected;
      for (final membership in active) {
        if (membership.operatorId == persisted) selected = membership;
      }
      if (selected == null && active.length == 1) {
        selected = active.single;
        await _store.saveOperatorId(selected.operatorId);
      }
      if (selected == null && persisted != null) {
        await _store.clear();
      }
      final status = selected != null
          ? OperatorWorkspaceStatus.ready
          : active.isEmpty
              ? OperatorWorkspaceStatus.noOperator
              : OperatorWorkspaceStatus.selectionRequired;
      _state = OperatorWorkspaceState(
        status: status,
        memberships: memberships,
        activeOperatorId: selected?.operatorId,
        activeOperatorName: selected?.operatorName,
      );
    } catch (e) {
      _state = _state.copyWith(status: OperatorWorkspaceStatus.failure, errorMessage: e.toString());
    }
    notifyListeners();
  }

  Future<void> select(OperatorMembership membership) async {
    if (!membership.isActive) return;
    await _store.saveOperatorId(membership.operatorId);
    _state = _state.copyWith(
      status: OperatorWorkspaceStatus.ready,
      activeOperatorId: membership.operatorId,
      activeOperatorName: membership.operatorName,
      clearError: true,
    );
    notifyListeners();
  }

  Future<void> accept(OperatorMembership membership) async {
    await _repository.transition(membership.id, 'accept');
    await load();
  }

  Future<void> decline(OperatorMembership membership) async {
    await _repository.transition(membership.id, 'decline');
    await load();
  }

  Future<void> enterPersonalMode() async {
    await _store.clear();
    _state = _state.copyWith(status: OperatorWorkspaceStatus.noOperator, clearActive: true, clearError: true);
    notifyListeners();
  }

  Future<void> clear() async {
    await enterPersonalMode();
  }
}
