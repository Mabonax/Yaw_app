class YawAircraftCataloguePage {
  const YawAircraftCataloguePage({
    required this.models,
    required this.pagination,
  });

  final List<YawAircraftCatalogueModel> models;
  final YawPagination pagination;

  factory YawAircraftCataloguePage.fromJson(Map<String, Object?> json) {
    return YawAircraftCataloguePage(
      models: _mapList(
        json['aircraft_models'],
        YawAircraftCatalogueModel.fromJson,
      ),
      pagination: YawPagination.fromJson(_asMap(json['pagination'])),
    );
  }
}

class YawPagination {
  const YawPagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  factory YawPagination.fromJson(Map<String, Object?> json) {
    return YawPagination(
      currentPage: _asInt(json['current_page']),
      perPage: _asInt(json['per_page']),
      total: _asInt(json['total']),
      lastPage: _asInt(json['last_page']),
    );
  }
}

class YawAircraft {
  const YawAircraft({
    required this.id,
    this.catalogueModel,
    this.registration,
    this.manufacturer,
    this.model,
    this.serialNumber,
    this.internalAssetNumber,
    this.aircraftCategory,
    this.owner,
    this.operator,
    this.supplier,
    this.firmwareVersion,
    this.flightControllerSerial,
    this.remoteIdSerial,
    this.acquisitionDate,
    this.operationalStatus,
    this.onboardingStatus,
    this.baseLocation,
    required this.operatorNames,
    this.readiness,
    required this.packageInstantiation,
  });

  final int id;
  final YawAircraftCatalogueModel? catalogueModel;
  final String? registration;
  final String? manufacturer;
  final String? model;
  final String? serialNumber;
  final String? internalAssetNumber;
  final String? aircraftCategory;
  final String? owner;
  final String? operator;
  final String? supplier;
  final String? firmwareVersion;
  final String? flightControllerSerial;
  final String? remoteIdSerial;
  final String? acquisitionDate;
  final String? operationalStatus;
  final String? onboardingStatus;
  final String? baseLocation;
  final List<String> operatorNames;
  final YawAircraftReadiness? readiness;
  final YawAircraftPackage packageInstantiation;

  String get displayName {
    final parts = [manufacturer, model]
        .where((part) => part != null && part.trim().isNotEmpty)
        .cast<String>()
        .toList();

    if (parts.isNotEmpty) {
      return parts.join(' ');
    }

    return registration ?? 'Aircraft #$id';
  }

  factory YawAircraft.fromJson(Map<String, Object?> json) {
    return YawAircraft(
      id: _asInt(json['id']),
      catalogueModel: _optionalMap(
        json['catalogue_model'],
        YawAircraftCatalogueModel.fromJson,
      ),
      registration: _asString(json['registration']),
      manufacturer: _asString(json['manufacturer']),
      model: _asString(json['model']),
      serialNumber: _asString(json['serial_number']),
      internalAssetNumber: _asString(json['internal_asset_number']),
      aircraftCategory: _asString(json['aircraft_category']),
      owner: _asString(json['owner']),
      operator: _asString(json['operator']),
      supplier: _asString(json['supplier']),
      firmwareVersion: _asString(json['firmware_version']),
      flightControllerSerial: _asString(json['flight_controller_serial']),
      remoteIdSerial: _asString(json['remote_id_serial']),
      acquisitionDate: _asString(json['acquisition_date']),
      operationalStatus: _asString(json['operational_status']),
      onboardingStatus: _asString(json['onboarding_status']),
      baseLocation: _asString(json['base_location']),
      operatorNames: _stringList(json['operator_names']),
      readiness: _optionalMap(json['readiness'], YawAircraftReadiness.fromJson),
      packageInstantiation: YawAircraftPackage.fromJson(
        _asMap(json['package_instantiation']),
      ),
    );
  }
}

class YawAircraftCatalogueModel {
  const YawAircraftCatalogueModel({
    required this.id,
    this.manufacturer,
    this.model,
    this.family,
    this.aircraftType,
    this.primaryUse,
    this.status,
    this.weightKg,
    this.mtowKg,
    this.maxPayloadKg,
    this.maxFlightTimeMin,
    this.maxSpeedMS,
    this.maxRangeKm,
    this.serviceCeilingM,
    this.maxWindMS,
    this.ipRating,
    this.operatingTempC,
    this.dimensions,
    this.wingspanMm,
    this.gnss,
    this.cameraPayloadSummary,
    this.remoteId,
    this.sourceUrl,
    this.imageSourceUrl,
    this.imageLicenseStatus,
    this.notes,
    this.verifiedAt,
    this.mediaStatus,
    required this.sourcePriority,
    this.catalogueStatus,
    this.packageStatus,
    required this.batteryPackage,
    required this.componentPackage,
    required this.maintenancePackage,
    required this.packageCounts,
  });

  final int id;
  final YawAircraftManufacturer? manufacturer;
  final String? model;
  final String? family;
  final String? aircraftType;
  final String? primaryUse;
  final String? status;
  final num? weightKg;
  final num? mtowKg;
  final num? maxPayloadKg;
  final num? maxFlightTimeMin;
  final num? maxSpeedMS;
  final num? maxRangeKm;
  final num? serviceCeilingM;
  final num? maxWindMS;
  final String? ipRating;
  final String? operatingTempC;
  final String? dimensions;
  final num? wingspanMm;
  final String? gnss;
  final String? cameraPayloadSummary;
  final String? remoteId;
  final String? sourceUrl;
  final String? imageSourceUrl;
  final String? imageLicenseStatus;
  final String? notes;
  final String? verifiedAt;
  final String? mediaStatus;
  final int sourcePriority;
  final String? catalogueStatus;
  final String? packageStatus;
  final List<Map<String, Object?>> batteryPackage;
  final List<Map<String, Object?>> componentPackage;
  final List<Map<String, Object?>> maintenancePackage;
  final YawPackageCounts packageCounts;

  String get displayName {
    final make = manufacturer?.name;
    final parts = [make, model]
        .where((part) => part != null && part.trim().isNotEmpty)
        .cast<String>()
        .toList();
    return parts.isEmpty ? 'Catalogue model #$id' : parts.join(' ');
  }

  factory YawAircraftCatalogueModel.fromJson(Map<String, Object?> json) {
    return YawAircraftCatalogueModel(
      id: _asInt(json['id']),
      manufacturer: _optionalMap(
        json['manufacturer'],
        YawAircraftManufacturer.fromJson,
      ),
      model: _asString(json['model']),
      family: _asString(json['family']),
      aircraftType: _asString(json['aircraft_type']),
      primaryUse: _asString(json['primary_use']),
      status: _asString(json['status']),
      weightKg: _asNum(json['weight_kg']),
      mtowKg: _asNum(json['mtow_kg']),
      maxPayloadKg: _asNum(json['max_payload_kg']),
      maxFlightTimeMin: _asNum(json['max_flight_time_min']),
      maxSpeedMS: _asNum(json['max_speed_m_s']),
      maxRangeKm: _asNum(json['max_range_km']),
      serviceCeilingM: _asNum(json['service_ceiling_m']),
      maxWindMS: _asNum(json['max_wind_m_s']),
      ipRating: _asString(json['ip_rating']),
      operatingTempC: _asString(json['operating_temp_c']),
      dimensions: _asString(json['dimensions']),
      wingspanMm: _asNum(json['wingspan_mm']),
      gnss: _asString(json['gnss']),
      cameraPayloadSummary: _asString(json['camera_payload_summary']),
      remoteId: _asString(json['remote_id']),
      sourceUrl: _asString(json['source_url']),
      imageSourceUrl: _asString(json['image_source_url']),
      imageLicenseStatus: _asString(json['image_license_status']),
      notes: _asString(json['notes']),
      verifiedAt: _asString(json['verified_at']),
      mediaStatus: _asString(json['media_status']),
      sourcePriority: _asInt(json['source_priority']),
      catalogueStatus: _asString(json['catalogue_status']),
      packageStatus: _asString(json['package_status']),
      batteryPackage: _mapOfMaps(json['battery_package']),
      componentPackage: _mapOfMaps(json['component_package']),
      maintenancePackage: _mapOfMaps(json['maintenance_package']),
      packageCounts: YawPackageCounts.fromJson(_asMap(json['package_counts'])),
    );
  }
}

class YawAircraftManufacturer {
  const YawAircraftManufacturer({required this.id, this.name, this.slug});

  final int id;
  final String? name;
  final String? slug;

  factory YawAircraftManufacturer.fromJson(Map<String, Object?> json) {
    return YawAircraftManufacturer(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
    );
  }
}

class YawPackageCounts {
  const YawPackageCounts({
    required this.batteries,
    required this.components,
    required this.maintenanceBaselines,
  });

  final int batteries;
  final int components;
  final int maintenanceBaselines;

  factory YawPackageCounts.fromJson(Map<String, Object?> json) {
    return YawPackageCounts(
      batteries: _asInt(json['batteries']),
      components: _asInt(json['components']),
      maintenanceBaselines: _asInt(json['maintenance_baselines']),
    );
  }
}

class YawAircraftReadiness {
  const YawAircraftReadiness({
    this.status,
    this.label,
    this.asOf,
    required this.checks,
    required this.blockingReasons,
    required this.reviewReasons,
  });

  final String? status;
  final String? label;
  final String? asOf;
  final List<YawReadinessCheck> checks;
  final List<String> blockingReasons;
  final List<String> reviewReasons;

  double get completionRatio {
    if (checks.isEmpty) {
      return 0;
    }

    final green = checks.where((check) => check.status == 'green').length;
    return green / checks.length;
  }

  factory YawAircraftReadiness.fromJson(Map<String, Object?> json) {
    return YawAircraftReadiness(
      status: _asString(json['status']),
      label: _asString(json['label']),
      asOf: _asString(json['as_of']),
      checks: _mapList(json['checks'], YawReadinessCheck.fromJson),
      blockingReasons: _stringList(json['blocking_reasons']),
      reviewReasons: _stringList(json['review_reasons']),
    );
  }
}

class YawReadinessCheck {
  const YawReadinessCheck({
    this.code,
    this.label,
    this.status,
    this.summary,
    required this.evidence,
  });

  final String? code;
  final String? label;
  final String? status;
  final String? summary;
  final Map<String, Object?> evidence;

  factory YawReadinessCheck.fromJson(Map<String, Object?> json) {
    return YawReadinessCheck(
      code: _asString(json['code']),
      label: _asString(json['label']),
      status: _asString(json['status']),
      summary: _asString(json['summary']),
      evidence: _asMap(json['evidence']),
    );
  }
}

class YawAircraftPackage {
  const YawAircraftPackage({
    this.state,
    this.instantiatedAt,
    required this.results,
    required this.batteryCount,
    required this.componentCount,
    required this.maintenanceBaselineCount,
    required this.batteries,
    required this.components,
  });

  final String? state;
  final String? instantiatedAt;
  final Map<String, Object?> results;
  final int batteryCount;
  final int componentCount;
  final int maintenanceBaselineCount;
  final List<YawAircraftBattery> batteries;
  final List<YawAircraftComponent> components;

  factory YawAircraftPackage.fromJson(Map<String, Object?> json) {
    return YawAircraftPackage(
      state: _asString(json['state']),
      instantiatedAt: _asString(json['instantiated_at']),
      results: _asMap(json['results']),
      batteryCount: _asInt(json['battery_count']),
      componentCount: _asInt(json['component_count']),
      maintenanceBaselineCount: _asInt(json['maintenance_baseline_count']),
      batteries: _mapList(json['batteries'], YawAircraftBattery.fromJson),
      components: _mapList(json['components'], YawAircraftComponent.fromJson),
    );
  }
}

class YawAircraftBattery {
  const YawAircraftBattery({
    required this.id,
    this.batteryUid,
    this.packageItemKey,
    this.model,
    this.healthStatus,
    this.retirementStatus,
  });

  final int id;
  final String? batteryUid;
  final String? packageItemKey;
  final String? model;
  final String? healthStatus;
  final String? retirementStatus;

  factory YawAircraftBattery.fromJson(Map<String, Object?> json) {
    return YawAircraftBattery(
      id: _asInt(json['id']),
      batteryUid: _asString(json['battery_uid']),
      packageItemKey: _asString(json['package_item_key']),
      model: _asString(json['model']),
      healthStatus: _asString(json['health_status']),
      retirementStatus: _asString(json['retirement_status']),
    );
  }
}

class YawAircraftComponent {
  const YawAircraftComponent({
    required this.id,
    this.componentUid,
    this.packageItemKey,
    this.componentType,
    this.name,
    this.status,
    this.lifeLimitHours,
    this.lifeLimitCycles,
  });

  final int id;
  final String? componentUid;
  final String? packageItemKey;
  final String? componentType;
  final String? name;
  final String? status;
  final num? lifeLimitHours;
  final int? lifeLimitCycles;

  factory YawAircraftComponent.fromJson(Map<String, Object?> json) {
    return YawAircraftComponent(
      id: _asInt(json['id']),
      componentUid: _asString(json['component_uid']),
      packageItemKey: _asString(json['package_item_key']),
      componentType: _asString(json['component_type']),
      name: _asString(json['name']),
      status: _asString(json['status']),
      lifeLimitHours: _asNum(json['life_limit_hours']),
      lifeLimitCycles: _asNullableInt(json['life_limit_cycles']),
    );
  }
}

String? _asString(Object? value) {
  if (value == null) {
    return null;
  }
  final string = value.toString();
  return string.isEmpty ? null : string;
}

int _asInt(Object? value) {
  return _asNullableInt(value) ?? 0;
}

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
