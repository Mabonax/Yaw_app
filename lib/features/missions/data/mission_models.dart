enum YawMissionLifecycleStatus {
  draft('draft', 'Draft'),
  planning('planning', 'Planning'),
  complianceReview('compliance_review', 'Compliance Review'),
  awaitingApproval('awaiting_approval', 'Awaiting Approval'),
  approved('approved', 'Approved'),
  readyForFlight('ready_for_flight', 'Ready For Flight'),
  inProgress('in_progress', 'In Progress'),
  completed('completed', 'Completed'),
  postFlightReview('post_flight_review', 'Post Flight Review'),
  closed('closed', 'Closed'),
  cancelled('cancelled', 'Cancelled'),
  unknown('unknown', 'Unknown');

  const YawMissionLifecycleStatus(this.value, this.label);

  final String value;
  final String label;

  static YawMissionLifecycleStatus fromValue(String? value) {
    return YawMissionLifecycleStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => YawMissionLifecycleStatus.unknown,
    );
  }
}

class YawMission {
  const YawMission({
    required this.id,
    this.missionNumber,
    this.purpose,
    this.clientProject,
    this.location,
    this.latitude,
    this.longitude,
    required this.missionPolygon,
    this.operationCategory,
    this.operator,
    this.aircraft,
    this.pilot,
    required this.observersCrew,
    this.plannedStartAt,
    this.plannedEndAt,
    this.actualTakeoffAt,
    this.actualLandingAt,
    this.actualFlightDurationMinutes,
    this.completedAt,
    this.maximumAltitudeFt,
    this.plannedDistanceKm,
    this.operationVisibility,
    this.dayNight,
    this.weather,
    this.airspaceAssessment,
    required this.approvals,
    required this.riskAssessment,
    this.emergencyArrangements,
    required this.lifecycleStatus,
    this.releaseGateState,
    required this.releaseGateResults,
    required this.compliance,
    this.postFlightPropagation,
    this.regulatorySource,
    this.regulatorySourceVersion,
    this.regulatoryEffectiveDate,
    this.regulatoryApplicability,
    this.responsibleRole,
    this.createdAt,
  });

  final int id;
  final String? missionNumber;
  final String? purpose;
  final String? clientProject;
  final String? location;
  final num? latitude;
  final num? longitude;
  final List<Map<String, Object?>> missionPolygon;
  final String? operationCategory;
  final YawMissionOperator? operator;
  final YawMissionAircraft? aircraft;
  final YawMissionPilot? pilot;
  final List<Map<String, Object?>> observersCrew;
  final String? plannedStartAt;
  final String? plannedEndAt;
  final String? actualTakeoffAt;
  final String? actualLandingAt;
  final int? actualFlightDurationMinutes;
  final String? completedAt;
  final int? maximumAltitudeFt;
  final num? plannedDistanceKm;
  final String? operationVisibility;
  final String? dayNight;
  final String? weather;
  final String? airspaceAssessment;
  final List<Map<String, Object?>> approvals;
  final Map<String, Object?> riskAssessment;
  final String? emergencyArrangements;
  final YawMissionLifecycleStatus lifecycleStatus;
  final String? releaseGateState;
  final Map<String, Object?> releaseGateResults;
  final YawMissionCompliance compliance;
  final YawPostFlightPropagation? postFlightPropagation;
  final String? regulatorySource;
  final String? regulatorySourceVersion;
  final String? regulatoryEffectiveDate;
  final String? regulatoryApplicability;
  final String? responsibleRole;
  final String? createdAt;

  String get displayTitle => missionNumber ?? purpose ?? 'Mission #$id';

  String get displaySubtitle {
    final parts = [purpose, location]
        .where((part) => part != null && part.trim().isNotEmpty)
        .cast<String>()
        .toList();
    return parts.isEmpty ? lifecycleStatus.label : parts.join(' · ');
  }

  bool get apiReleaseSupported => false;

  factory YawMission.fromJson(Map<String, Object?> json) {
    return YawMission(
      id: _asInt(json['id']),
      missionNumber: _asString(json['mission_number']),
      purpose: _asString(json['purpose']),
      clientProject: _asString(json['client_project']),
      location: _asString(json['location']),
      latitude: _asNum(json['latitude']),
      longitude: _asNum(json['longitude']),
      missionPolygon: _mapOfMaps(json['mission_polygon']),
      operationCategory: _asString(json['operation_category']),
      operator: _optionalMap(json['operator'], YawMissionOperator.fromJson),
      aircraft: _optionalMap(json['aircraft'], YawMissionAircraft.fromJson),
      pilot: _optionalMap(json['pilot'], YawMissionPilot.fromJson),
      observersCrew: _mapOfMaps(json['observers_crew']),
      plannedStartAt: _asString(json['planned_start_at']),
      plannedEndAt: _asString(json['planned_end_at']),
      actualTakeoffAt: _asString(json['actual_takeoff_at']),
      actualLandingAt: _asString(json['actual_landing_at']),
      actualFlightDurationMinutes: _asNullableInt(
        json['actual_flight_duration_minutes'],
      ),
      completedAt: _asString(json['completed_at']),
      maximumAltitudeFt: _asNullableInt(json['maximum_altitude_ft']),
      plannedDistanceKm: _asNum(json['planned_distance_km']),
      operationVisibility: _asString(json['operation_visibility']),
      dayNight: _asString(json['day_night']),
      weather: _asString(json['weather']),
      airspaceAssessment: _asString(json['airspace_assessment']),
      approvals: _mapOfMaps(json['approvals']),
      riskAssessment: _asMap(json['risk_assessment']),
      emergencyArrangements: _asString(json['emergency_arrangements']),
      lifecycleStatus: YawMissionLifecycleStatus.fromValue(
        _asString(json['lifecycle_state']),
      ),
      releaseGateState: _asString(json['release_gate_state']),
      releaseGateResults: _asMap(json['release_gate_results']),
      compliance: YawMissionCompliance.fromJson(_asMap(json['compliance'])),
      postFlightPropagation: _optionalMap(
        json['post_flight_propagation'],
        YawPostFlightPropagation.fromJson,
      ),
      regulatorySource: _asString(json['regulatory_source']),
      regulatorySourceVersion: _asString(json['regulatory_source_version']),
      regulatoryEffectiveDate: _asString(json['regulatory_effective_date']),
      regulatoryApplicability: _asString(json['regulatory_applicability']),
      responsibleRole: _asString(json['responsible_role']),
      createdAt: _asString(json['created_at']),
    );
  }
}

class YawMissionOperator {
  const YawMissionOperator({required this.id, this.legalEntity});

  final int id;
  final String? legalEntity;

  factory YawMissionOperator.fromJson(Map<String, Object?> json) {
    return YawMissionOperator(
      id: _asInt(json['id']),
      legalEntity: _asString(json['legal_entity']),
    );
  }
}

class YawMissionAircraft {
  const YawMissionAircraft({required this.id, this.registration, this.model});

  final int id;
  final String? registration;
  final String? model;

  String get displayName {
    final parts = [registration, model]
        .where((part) => part != null && part.trim().isNotEmpty)
        .cast<String>()
        .toList();
    return parts.isEmpty ? 'Aircraft #$id' : parts.join(' · ');
  }

  factory YawMissionAircraft.fromJson(Map<String, Object?> json) {
    return YawMissionAircraft(
      id: _asInt(json['id']),
      registration: _asString(json['registration']),
      model: _asString(json['model']),
    );
  }
}

class YawMissionPilot {
  const YawMissionPilot({required this.id, this.displayName});

  final int id;
  final String? displayName;

  factory YawMissionPilot.fromJson(Map<String, Object?> json) {
    return YawMissionPilot(
      id: _asInt(json['id']),
      displayName: _asString(json['display_name']),
    );
  }
}

class YawMissionCompliance {
  const YawMissionCompliance({
    this.status,
    this.label,
    required this.blockingCount,
    required this.warningCount,
    required this.controls,
    this.evaluatedAt,
  });

  final String? status;
  final String? label;
  final int blockingCount;
  final int warningCount;
  final List<YawMissionComplianceControl> controls;
  final String? evaluatedAt;

  bool get isBlocked => status == 'red' || blockingCount > 0;
  bool get hasWarnings => status == 'amber' || warningCount > 0;

  double get completionRatio {
    if (controls.isEmpty) {
      return 0;
    }
    final green = controls.where((control) => control.status == 'green').length;
    return green / controls.length;
  }

  factory YawMissionCompliance.fromJson(Map<String, Object?> json) {
    return YawMissionCompliance(
      status: _asString(json['status']),
      label: _asString(json['label']),
      blockingCount: _asInt(json['blocking_count']),
      warningCount: _asInt(json['warning_count']),
      controls: _mapList(
        json['controls'],
        YawMissionComplianceControl.fromJson,
      ),
      evaluatedAt: _asString(json['evaluated_at']),
    );
  }
}

class YawMissionComplianceControl {
  const YawMissionComplianceControl({
    this.key,
    this.label,
    this.status,
    this.basis,
    this.summary,
    required this.blocking,
    required this.details,
    required this.reasons,
    this.actionHref,
  });

  final String? key;
  final String? label;
  final String? status;
  final String? basis;
  final String? summary;
  final bool blocking;
  final Map<String, Object?> details;
  final List<String> reasons;
  final String? actionHref;

  Map<String, Object?> get aircraftReadiness =>
      _asMap(details['aircraft_readiness']);

  factory YawMissionComplianceControl.fromJson(Map<String, Object?> json) {
    return YawMissionComplianceControl(
      key: _asString(json['key']),
      label: _asString(json['label']),
      status: _asString(json['status']),
      basis: _asString(json['basis']),
      summary: _asString(json['summary']),
      blocking: json['blocking'] == true,
      details: _asMap(json['details']),
      reasons: _stringList(json['reasons']),
      actionHref: _asString(json['action_href']),
    );
  }
}

class YawPostFlightPropagation {
  const YawPostFlightPropagation({
    this.state,
    this.label,
    required this.canPropagate,
    this.propagatedAt,
    this.actualTakeoffAt,
    this.actualLandingAt,
    this.actualFlightDurationMinutes,
    this.completedAt,
    this.pilotLogEntryId,
    this.aircraftFlightFolioId,
    this.latestChecklistState,
    required this.postFlightDeclaration,
    required this.results,
    required this.blockingReasons,
    this.batteryCyclesSummarised,
    this.batteryUsageCount,
    this.flightTrackCount,
    this.defectCount,
    this.openDefectCount,
  });

  final String? state;
  final String? label;
  final bool canPropagate;
  final String? propagatedAt;
  final String? actualTakeoffAt;
  final String? actualLandingAt;
  final int? actualFlightDurationMinutes;
  final String? completedAt;
  final int? pilotLogEntryId;
  final int? aircraftFlightFolioId;
  final String? latestChecklistState;
  final Map<String, Object?> postFlightDeclaration;
  final Map<String, Object?> results;
  final List<String> blockingReasons;
  final int? batteryCyclesSummarised;
  final int? batteryUsageCount;
  final int? flightTrackCount;
  final int? defectCount;
  final int? openDefectCount;

  bool get isPropagated =>
      state == 'propagated' || state == 'propagated_with_follow_up';

  String get displayLabel => label ?? _formatState(state ?? 'pending');

  factory YawPostFlightPropagation.fromJson(Map<String, Object?> json) {
    final results = _asMap(json['results']);
    return YawPostFlightPropagation(
      state: _asString(json['state']),
      label: _asString(json['label']),
      canPropagate: json['can_propagate'] == true,
      propagatedAt: _asString(json['propagated_at']),
      actualTakeoffAt: _asString(json['actual_takeoff_at']),
      actualLandingAt: _asString(json['actual_landing_at']),
      actualFlightDurationMinutes: _asNullableInt(
        json['actual_flight_duration_minutes'],
      ),
      completedAt: _asString(json['completed_at']),
      pilotLogEntryId: _asNullableInt(json['pilot_log_entry_id']),
      aircraftFlightFolioId: _asNullableInt(json['aircraft_flight_folio_id']),
      latestChecklistState: _asString(json['latest_checklist_state']),
      postFlightDeclaration: _asMap(json['post_flight_declaration']),
      results: results,
      blockingReasons: _stringList(json['blocking_reasons']),
      batteryCyclesSummarised: _asNullableInt(
        json['battery_cycles_summarised'] ??
            results['battery_cycles_summarised'],
      ),
      batteryUsageCount: _asNullableInt(
        json['battery_usage_count'] ?? results['battery_usage_count'],
      ),
      flightTrackCount: _asNullableInt(
        json['flight_track_count'] ?? results['flight_track_count'],
      ),
      defectCount: _asNullableInt(
        json['defect_count'] ?? results['defect_count'],
      ),
      openDefectCount: _asNullableInt(
        json['open_defect_count'] ?? results['open_defect_count'],
      ),
    );
  }
}

class YawPostFlightSubmission {
  const YawPostFlightSubmission({
    required this.actualTakeoffAt,
    required this.actualLandingAt,
    required this.pilotConfirmed,
    required this.aircraftConfirmed,
    required this.defectsDeclared,
    required this.occurrenceDeclared,
    this.closureNotes,
  });

  final String actualTakeoffAt;
  final String actualLandingAt;
  final bool pilotConfirmed;
  final bool aircraftConfirmed;
  final bool defectsDeclared;
  final bool occurrenceDeclared;
  final String? closureNotes;

  Map<String, Object?> toJson() {
    return {
      'actual_takeoff_at': actualTakeoffAt,
      'actual_landing_at': actualLandingAt,
      'pilot_confirmed': pilotConfirmed,
      'aircraft_confirmed': aircraftConfirmed,
      'defects_declared': defectsDeclared,
      'occurrence_declared': occurrenceDeclared,
      if (closureNotes != null && closureNotes!.trim().isNotEmpty)
        'closure_notes': closureNotes!.trim(),
    };
  }
}

String _formatState(String value) {
  if (value.isEmpty) {
    return 'Not supplied';
  }
  return value
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String? _asString(Object? value) {
  if (value == null) {
    return null;
  }
  final string = value.toString();
  return string.isEmpty ? null : string;
}

int _asInt(Object? value) => _asNullableInt(value) ?? 0;

int? _asNullableInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

num? _asNum(Object? value) {
  if (value is num) {
    return value;
  }
  return num.tryParse(value?.toString() ?? '');
}

Map<String, Object?> _asMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return const <String, Object?>{};
}

T? _optionalMap<T>(Object? value, T Function(Map<String, Object?> json) parse) {
  if (value == null) {
    return null;
  }
  final map = _asMap(value);
  if (map.isEmpty) {
    return null;
  }
  return parse(map);
}

List<T> _mapList<T>(
  Object? value,
  T Function(Map<String, Object?> json) parse,
) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<Map>()
      .map((item) => parse(_asMap(item)))
      .toList(growable: false);
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .map((item) => item?.toString())
      .where((item) => item != null && item.isNotEmpty)
      .cast<String>()
      .toList(growable: false);
}

List<Map<String, Object?>> _mapOfMaps(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.whereType<Map>().map(_asMap).toList(growable: false);
}
