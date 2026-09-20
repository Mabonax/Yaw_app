import 'package:flutter/foundation.dart';

import '../../../core/api/api_exception.dart';
import '../data/mission_models.dart';
import '../data/mission_repository.dart';
import '../../aeronautical_information/presentation/briefing_controller.dart';

enum MissionLoadStatus { idle, loading, loaded, empty, failure }

class MissionState {
  const MissionState({
    this.status = MissionLoadStatus.idle,
    this.missions = const [],
    this.selectedMission,
    this.selectedCompliance,
    this.selectedPostFlightPropagation,
    this.errorMessage,
    this.complianceErrorMessage,
    this.releaseMessage,
    this.releaseErrorMessage,
    this.postFlightMessage,
    this.postFlightErrorMessage,
    this.isRefreshing = false,
    this.isLoadingDetail = false,
    this.isLoadingCompliance = false,
    this.isLoadingPostFlight = false,
    this.isReleasing = false,
    this.isSubmittingPostFlight = false,
  });

  final MissionLoadStatus status;
  final List<YawMission> missions;
  final YawMission? selectedMission;
  final YawMissionCompliance? selectedCompliance;
  final YawPostFlightPropagation? selectedPostFlightPropagation;
  final String? errorMessage;
  final String? complianceErrorMessage;
  final String? releaseMessage;
  final String? releaseErrorMessage;
  final String? postFlightMessage;
  final String? postFlightErrorMessage;
  final bool isRefreshing;
  final bool isLoadingDetail;
  final bool isLoadingCompliance;
  final bool isLoadingPostFlight;
  final bool isReleasing;
  final bool isSubmittingPostFlight;

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
    YawPostFlightPropagation? selectedPostFlightPropagation,
    String? errorMessage,
    String? complianceErrorMessage,
    String? releaseMessage,
    String? releaseErrorMessage,
    String? postFlightMessage,
    String? postFlightErrorMessage,
    bool? isRefreshing,
    bool? isLoadingDetail,
    bool? isLoadingCompliance,
    bool? isLoadingPostFlight,
    bool? isReleasing,
    bool? isSubmittingPostFlight,
    bool clearSelectedMission = false,
    bool clearSelectedCompliance = false,
    bool clearSelectedPostFlight = false,
    bool clearErrors = false,
    bool clearRelease = false,
    bool clearPostFlight = false,
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
      selectedPostFlightPropagation: clearSelectedPostFlight
          ? null
          : selectedPostFlightPropagation ?? this.selectedPostFlightPropagation,
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
      postFlightMessage: clearPostFlight
          ? null
          : postFlightMessage ?? this.postFlightMessage,
      postFlightErrorMessage: clearPostFlight
          ? null
          : postFlightErrorMessage ?? this.postFlightErrorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isLoadingCompliance: isLoadingCompliance ?? this.isLoadingCompliance,
      isLoadingPostFlight: isLoadingPostFlight ?? this.isLoadingPostFlight,
      isReleasing: isReleasing ?? this.isReleasing,
      isSubmittingPostFlight:
          isSubmittingPostFlight ?? this.isSubmittingPostFlight,
    );
  }
}

class MissionController extends ChangeNotifier {
  MissionController({required MissionRepository repository})
    : _repository = repository;

  final MissionRepository _repository;

  // A new authenticated session gets independent data and in-flight results.
  MissionController forSession() => MissionController(repository: _repository);
  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  BriefingController createBriefingController(int missionId) =>
      BriefingController(repository: _repository, missionId: missionId);

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
      clearPostFlight: true,
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
      isLoadingPostFlight: true,
      clearSelectedMission: true,
      clearSelectedCompliance: true,
      clearSelectedPostFlight: true,
      clearErrors: true,
      clearRelease: true,
      clearPostFlight: true,
    );
    notifyListeners();

    try {
      final mission = await _repository.fetchMissionDetail(id);
      _state = _state.copyWith(
        selectedMission: mission,
        selectedCompliance: mission.compliance,
        selectedPostFlightPropagation: mission.postFlightPropagation,
        isLoadingDetail: false,
        isLoadingCompliance: false,
        clearErrors: true,
      );
      await loadPostFlightPropagation(id, preserveMessages: true);
    } on ApiException catch (error) {
      _state = _state.copyWith(
        isLoadingDetail: false,
        isLoadingCompliance: false,
        isLoadingPostFlight: false,
        errorMessage: _messageForApiError(error),
      );
    } on FormatException {
      _state = _state.copyWith(
        isLoadingDetail: false,
        isLoadingCompliance: false,
        isLoadingPostFlight: false,
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

  Future<void> loadPostFlightPropagation(
    int id, {
    bool preserveMessages = false,
  }) async {
    _state = _state.copyWith(
      isLoadingPostFlight: true,
      clearErrors: !preserveMessages,
      clearPostFlight: !preserveMessages,
    );
    notifyListeners();

    try {
      final propagation = await _repository.fetchPostFlightPropagation(id);
      _state = _state.copyWith(
        selectedPostFlightPropagation: propagation,
        isLoadingPostFlight: false,
      );
    } on ApiException catch (error) {
      _state = _state.copyWith(
        isLoadingPostFlight: false,
        postFlightErrorMessage: _messageForApiError(error),
      );
    } on FormatException {
      _state = _state.copyWith(
        isLoadingPostFlight: false,
        postFlightErrorMessage:
            'The YAW post-flight response could not be read.',
      );
    }

    notifyListeners();
  }

  Future<bool> submitPostFlight(YawPostFlightSubmission submission) async {
    final mission = _state.selectedMission;
    if (mission == null || _state.isSubmittingPostFlight) {
      return false;
    }

    _state = _state.copyWith(
      isSubmittingPostFlight: true,
      clearErrors: true,
      clearPostFlight: true,
    );
    notifyListeners();

    try {
      final propagation = await _repository.propagatePostFlight(
        mission.id,
        submission,
      );
      _state = _state.copyWith(
        selectedPostFlightPropagation: propagation,
        isSubmittingPostFlight: false,
        postFlightMessage: 'Post-flight records propagated by the YAW API.',
      );
      await loadMissionDetail(mission.id);
      _state = _state.copyWith(
        selectedPostFlightPropagation: propagation,
        postFlightMessage: 'Post-flight records propagated by the YAW API.',
      );
      await loadMissions(refresh: true);
      _state = _state.copyWith(
        selectedPostFlightPropagation: propagation,
        postFlightMessage: 'Post-flight records propagated by the YAW API.',
      );
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      final message = _messageForApiError(error);
      _state = _state.copyWith(
        isSubmittingPostFlight: false,
        postFlightErrorMessage: _validationMessage(error) ?? message,
      );
      await loadPostFlightPropagation(mission.id, preserveMessages: true);
      _state = _state.copyWith(
        postFlightErrorMessage: _validationMessage(error) ?? message,
      );
      notifyListeners();
      return false;
    } on FormatException {
      const message = 'The post-flight propagation response could not be read.';
      _state = _state.copyWith(
        isSubmittingPostFlight: false,
        postFlightErrorMessage: message,
      );
      await loadPostFlightPropagation(mission.id, preserveMessages: true);
      _state = _state.copyWith(postFlightErrorMessage: message);
      notifyListeners();
      return false;
    }
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

  String? _validationMessage(ApiException error) {
    final errors = error.errors;
    if (errors == null || errors.isEmpty) {
      return null;
    }
    return errors.values.expand((messages) => messages).join(' ');
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
