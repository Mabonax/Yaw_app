import 'package:flutter/foundation.dart';

import '../../../core/api/api_exception.dart';
import '../data/aircraft_models.dart';
import '../data/aircraft_repository.dart';

enum AircraftLoadStatus { idle, loading, loaded, empty, failure }

class AircraftState {
  const AircraftState({
    this.status = AircraftLoadStatus.idle,
    this.catalogueStatus = AircraftLoadStatus.idle,
    this.aircraft = const [],
    this.catalogue = const [],
    this.selectedAircraft,
    this.selectedCatalogueModel,
    this.errorMessage,
    this.catalogueErrorMessage,
    this.isRefreshing = false,
    this.isLoadingDetail = false,
  });

  final AircraftLoadStatus status;
  final AircraftLoadStatus catalogueStatus;
  final List<YawAircraft> aircraft;
  final List<YawAircraftCatalogueModel> catalogue;
  final YawAircraft? selectedAircraft;
  final YawAircraftCatalogueModel? selectedCatalogueModel;
  final String? errorMessage;
  final String? catalogueErrorMessage;
  final bool isRefreshing;
  final bool isLoadingDetail;

  int get totalAircraft => aircraft.length;
  int get readyAircraft =>
      aircraft.where((item) => item.readiness?.status == 'green').length;
  int get reviewAircraft =>
      aircraft.where((item) => item.readiness?.status == 'amber').length;
  int get blockedAircraft =>
      aircraft.where((item) => item.readiness?.status == 'red').length;

  AircraftState copyWith({
    AircraftLoadStatus? status,
    AircraftLoadStatus? catalogueStatus,
    List<YawAircraft>? aircraft,
    List<YawAircraftCatalogueModel>? catalogue,
    YawAircraft? selectedAircraft,
    YawAircraftCatalogueModel? selectedCatalogueModel,
    String? errorMessage,
    String? catalogueErrorMessage,
    bool? isRefreshing,
    bool? isLoadingDetail,
    bool clearSelectedAircraft = false,
    bool clearSelectedCatalogueModel = false,
    bool clearErrors = false,
  }) {
    return AircraftState(
      status: status ?? this.status,
      catalogueStatus: catalogueStatus ?? this.catalogueStatus,
      aircraft: aircraft ?? this.aircraft,
      catalogue: catalogue ?? this.catalogue,
      selectedAircraft: clearSelectedAircraft
          ? null
          : selectedAircraft ?? this.selectedAircraft,
      selectedCatalogueModel: clearSelectedCatalogueModel
          ? null
          : selectedCatalogueModel ?? this.selectedCatalogueModel,
      errorMessage: clearErrors ? null : errorMessage ?? this.errorMessage,
      catalogueErrorMessage: clearErrors
          ? null
          : catalogueErrorMessage ?? this.catalogueErrorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
    );
  }
}

class AircraftController extends ChangeNotifier {
  AircraftController({required AircraftRepository repository})
    : _repository = repository;

  final AircraftRepository _repository;

  // A new authenticated session gets independent data and in-flight results.
  AircraftController forSession() =>
      AircraftController(repository: _repository);
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

  AircraftState _state = const AircraftState();

  AircraftState get state => _state;

  Future<void> loadAircraft({bool refresh = false}) async {
    if (_state.status == AircraftLoadStatus.loading && !refresh) {
      return;
    }

    _state = _state.copyWith(
      status: refresh ? _state.status : AircraftLoadStatus.loading,
      isRefreshing: refresh,
      clearErrors: true,
    );
    notifyListeners();

    try {
      final aircraft = await _repository.fetchAircraft();
      _state = _state.copyWith(
        status: aircraft.isEmpty
            ? AircraftLoadStatus.empty
            : AircraftLoadStatus.loaded,
        aircraft: aircraft,
        isRefreshing: false,
        clearErrors: true,
      );
    } on ApiException catch (error) {
      _state = _state.copyWith(
        status: AircraftLoadStatus.failure,
        errorMessage: _messageForApiError(error),
        isRefreshing: false,
      );
    } on FormatException {
      _state = _state.copyWith(
        status: AircraftLoadStatus.failure,
        errorMessage: 'The YAW aircraft response could not be read.',
        isRefreshing: false,
      );
    }

    notifyListeners();
  }

  Future<void> loadAircraftDetail(int id) async {
    _state = _state.copyWith(isLoadingDetail: true, clearErrors: true);
    notifyListeners();

    try {
      final aircraft = await _repository.fetchAircraftDetail(id);
      _state = _state.copyWith(
        selectedAircraft: aircraft,
        isLoadingDetail: false,
        clearErrors: true,
      );
    } on ApiException catch (error) {
      _state = _state.copyWith(
        isLoadingDetail: false,
        errorMessage: _messageForApiError(error),
      );
    } on FormatException {
      _state = _state.copyWith(
        isLoadingDetail: false,
        errorMessage: 'The YAW aircraft detail response could not be read.',
      );
    }

    notifyListeners();
  }

  Future<void> loadCatalogue({bool refresh = false, String? search}) async {
    if (_state.catalogueStatus == AircraftLoadStatus.loading && !refresh) {
      return;
    }

    _state = _state.copyWith(
      catalogueStatus: refresh
          ? _state.catalogueStatus
          : AircraftLoadStatus.loading,
      clearErrors: true,
    );
    notifyListeners();

    try {
      final page = await _repository.fetchCatalogue(search: search);
      _state = _state.copyWith(
        catalogueStatus: page.models.isEmpty
            ? AircraftLoadStatus.empty
            : AircraftLoadStatus.loaded,
        catalogue: page.models,
        clearErrors: true,
      );
    } on ApiException catch (error) {
      _state = _state.copyWith(
        catalogueStatus: AircraftLoadStatus.failure,
        catalogueErrorMessage: _messageForApiError(error),
      );
    } on FormatException {
      _state = _state.copyWith(
        catalogueStatus: AircraftLoadStatus.failure,
        catalogueErrorMessage:
            'The aircraft catalogue response could not be read.',
      );
    }

    notifyListeners();
  }

  Future<void> loadCatalogueDetail(int id) async {
    _state = _state.copyWith(
      isLoadingDetail: true,
      clearSelectedCatalogueModel: true,
      clearErrors: true,
    );
    notifyListeners();

    try {
      final model = await _repository.fetchCatalogueDetail(id);
      _state = _state.copyWith(
        selectedCatalogueModel: model,
        isLoadingDetail: false,
        clearErrors: true,
      );
    } on ApiException catch (error) {
      _state = _state.copyWith(
        isLoadingDetail: false,
        catalogueErrorMessage: _messageForApiError(error),
      );
    } on FormatException {
      _state = _state.copyWith(
        isLoadingDetail: false,
        catalogueErrorMessage:
            'The catalogue detail response could not be read.',
      );
    }

    notifyListeners();
  }

  String _messageForApiError(ApiException error) {
    return switch (error.type) {
      ApiExceptionType.unauthorized =>
        'Your session has expired. Please sign in again.',
      ApiExceptionType.forbidden =>
        'Your account cannot access aircraft records.',
      ApiExceptionType.notFound =>
        'The requested aircraft record was not found.',
      ApiExceptionType.timeout => 'The YAW aircraft service timed out.',
      ApiExceptionType.connectivity =>
        'The YAW aircraft service is unavailable.',
      ApiExceptionType.validation => error.message,
      ApiExceptionType.server =>
        'The YAW aircraft service encountered a server error.',
      ApiExceptionType.unknown =>
        'The YAW aircraft service returned an unexpected response.',
    };
  }
}
