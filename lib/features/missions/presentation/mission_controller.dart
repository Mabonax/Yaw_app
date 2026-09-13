import 'package:flutter/foundation.dart';

import '../../../core/api/api_exception.dart';
import '../data/mission_models.dart';
import '../data/mission_repository.dart';

enum MissionLoadStatus { idle, loading, loaded, empty, failure }

class MissionState {
  const MissionState({
    this.status = MissionLoadStatus.idle,
    this.missions = const [],
    this.selectedMission,
    this.selectedCompliance,
    this.errorMessage,
    this.complianceErrorMessage,
    this.releaseMessage,
    this.releaseErrorMessage,
    this.isRefreshing = false,
    this.isLoadingDetail = false,
    this.isLoadingCompliance = false,
    this.isReleasing = false,
  });

  final MissionLoadStatus status;
  final List<YawMission> missions;
  final YawMission? selectedMission;
  final YawMissionCompliance? selectedCompliance;
  final String? errorMessage;
  final String? complianceErrorMessage;
  final String? releaseMessage;
  final String? releaseErrorMessage;
  final bool isRefreshing;
  final bool isLoadingDetail;
  final bool isLoadingCompliance;
  final bool isReleasing;

  int get totalMissions => missions.length;
  int get blockedMissions =>
      missions.where((mission) => mission.compliance.status == 'red').length;
  int get warningMissions =>
      missions.where((mission) => mission.compliance.status == 'amber').length;
  int get readyMissions =>
      missions.where((mission) => mission.compliance.status == 'green').length;

  MissionState copyWith({
    MissionLoadStatus? status,
    List<YawMission>? missions,
    YawMission? selectedMission,
    YawMissionCompliance? selectedCompliance,
    String? errorMessage,
    String? complianceErrorMessage,
    String? releaseMessage,
    String? releaseErrorMessage,
    bool? isRefreshing,
    bool? isLoadingDetail,
    bool? isLoadingCompliance,
    bool? isReleasing,
    bool clearSelectedMission = false,
    bool clearSelectedCompliance = false,
    bool clearErrors = false,
    bool clearRelease = false,
  }) {
    return MissionState(
      status: status ?? this.status,
      missions: missions ?? this.missions,
      selectedMission: clearSelectedMission
          ? null
          : selectedMission ?? this.selectedMission,
      selectedCompliance: clearSelectedCompliance
          ? null
          : selectedCompliance ?? this.selectedCompliance,
      errorMessage: clearErrors ? null : errorMessage ?? this.errorMessage,
      complianceErrorMessage: clearErrors
          ? null
          : complianceErrorMessage ?? this.complianceErrorMessage,
      releaseMessage: clearRelease
          ? null
          : releaseMessage ?? this.releaseMessage,
      releaseErrorMessage: clearRelease
          ? null
          : releaseErrorMessage ?? this.releaseErrorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isLoadingCompliance: isLoadingCompliance ?? this.isLoadingCompliance,
      isReleasing: isReleasing ?? this.isReleasing,
    );
  }
}

class MissionController extends ChangeNotifier {
  MissionController({required MissionRepository repository})
    : _repository = repository;

  final MissionRepository _repository;

  MissionState _state = const MissionState();

  MissionState get state => _state;

  Future<void> loadMissions({bool refresh = false}) async {
    if (_state.status == MissionLoadStatus.loading && !refresh) {
      return;
    }

    _state = _state.copyWith(
      status: refresh ? _state.status : MissionLoadStatus.loading,
      isRefreshing: refresh,
      clearErrors: true,
      clearRelease: true,
    );
    notifyListeners();

    try {
      final missions = await _repository.fetchMissions();
      _state = _state.copyWith(
        status: missions.isEmpty
            ? MissionLoadStatus.empty
            : MissionLoadStatus.loaded,
        missions: missions,
        isRefreshing: false,
        clearErrors: true,
      );
    } on ApiException catch (error) {
      _state = _state.copyWith(
        status: MissionLoadStatus.failure,
        errorMessage: _messageForApiError(error),
        isRefreshing: false,
      );
    } on FormatException {
      _state = _state.copyWith(
        status: MissionLoadStatus.failure,
        errorMessage: 'The YAW mission response could not be read.',
        isRefreshing: false,
      );
    }

    notifyListeners();
  }

  Future<void> loadMissionDetail(int id) async {
    _state = _state.copyWith(
      isLoadingDetail: true,
      isLoadingCompliance: true,
      clearSelectedMission: true,
      clearSelectedCompliance: true,
      clearErrors: true,
      clearRelease: true,
    );
    notifyListeners();

    try {
      final mission = await _repository.fetchMissionDetail(id);
      _state = _state.copyWith(
        selectedMission: mission,
        selectedCompliance: mission.compliance,
        isLoadingDetail: false,
        isLoadingCompliance: false,
        clearErrors: true,
      );
    } on ApiException catch (error) {
      _state = _state.copyWith(
        isLoadingDetail: false,
        isLoadingCompliance: false,
        errorMessage: _messageForApiError(error),
      );
    } on FormatException {
      _state = _state.copyWith(
        isLoadingDetail: false,
        isLoadingCompliance: false,
        errorMessage: 'The YAW mission detail response could not be read.',
      );
    }

    notifyListeners();
  }

  Future<void> loadMissionCompliance(int id) async {
    _state = _state.copyWith(isLoadingCompliance: true, clearErrors: true);
    notifyListeners();

    try {
      final compliance = await _repository.fetchMissionCompliance(id);
      _state = _state.copyWith(
        selectedCompliance: compliance,
        isLoadingCompliance: false,
        clearErrors: true,
      );
    } on ApiException catch (error) {
      _state = _state.copyWith(
        isLoadingCompliance: false,
        complianceErrorMessage: _messageForApiError(error),
      );
    } on FormatException {
      _state = _state.copyWith(
        isLoadingCompliance: false,
        complianceErrorMessage:
            'The YAW mission compliance response could not be read.',
      );
    }

    notifyListeners();
  }

  Future<bool> releaseSelectedMission() async {
    final mission = _state.selectedMission;
    if (mission == null || _state.isReleasing) {
      return false;
    }

    _state = _state.copyWith(
      isReleasing: true,
      clearErrors: true,
      clearRelease: true,
    );
    notifyListeners();

    try {
      final released = await _repository.releaseMission(mission.id);
      _state = _state.copyWith(
        selectedMission: released,
        selectedCompliance: released.compliance,
        isReleasing: false,
        releaseMessage: 'Mission released by the YAW API.',
      );
      await loadMissions(refresh: true);
      return true;
    } on ApiException catch (error) {
      final message = _messageForApiError(error);
      _state = _state.copyWith(
        isReleasing: false,
        releaseErrorMessage: message,
      );
      await loadMissionDetail(mission.id);
      _state = _state.copyWith(releaseErrorMessage: message);
      notifyListeners();
      return false;
    } on FormatException {
      const message = 'The release response could not be read.';
      _state = _state.copyWith(
        isReleasing: false,
        releaseErrorMessage: message,
      );
      await loadMissionDetail(mission.id);
      _state = _state.copyWith(releaseErrorMessage: message);
      notifyListeners();
      return false;
    }
  }

  String _messageForApiError(ApiException error) {
    return switch (error.type) {
      ApiExceptionType.unauthorized =>
        'Your session has expired. Please sign in again.',
      ApiExceptionType.forbidden =>
        'Your account cannot access this mission resource.',
      ApiExceptionType.notFound => error.message,
      ApiExceptionType.validation => error.message,
      ApiExceptionType.timeout => 'The YAW mission service timed out.',
      ApiExceptionType.connectivity =>
        'The YAW mission service is unavailable.',
      ApiExceptionType.server =>
        'The YAW mission service encountered a server error.',
      ApiExceptionType.unknown =>
        'The YAW mission service returned an unexpected response.',
    };
  }
}
