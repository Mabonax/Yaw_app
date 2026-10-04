class YawUser {
  const YawUser({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  factory YawUser.fromJson(Map<String, Object?> json) {
    return YawUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? 'YAW user',
      email: json['email'] as String? ?? '',
      role: json['role'] as String?,
    );
  }

  final int id;
  final String name;
  final String email;
  final String? role;
}

class YawPilotProfile {
  const YawPilotProfile({
    required this.id,
    required this.displayName,
    this.userId,
    this.employeeNumber,
    this.firstName,
    this.lastName,
    this.preferredName,
    this.email,
    this.phone,
    this.nationality,
    this.dateOfBirth,
    this.sacaaCertificateNumber,
    this.rpcCategory,
    this.ratings = const [],
    this.medicalStatus,
    this.radiotelephonyQualification,
    this.languageProficiency,
    this.trainingHistory = const [],
    this.examinerRecords = const [],
    this.operatorAffiliations = const [],
    this.supportingDocumentReferences = const [],
    this.profileStatus,
    this.regulatorySource,
    this.regulatorySourceVersion,
    this.regulatoryEffectiveDate,
    this.regulatoryApplicability,
    this.responsibleRole,
    this.notes,
  });

  factory YawPilotProfile.fromJson(Map<String, Object?> json) {
    return YawPilotProfile(
      id: (json['id'] as num).toInt(),
      displayName: json['display_name'] as String? ?? 'Pilot profile',
      userId: (json['user_id'] as num?)?.toInt(),
      employeeNumber: json['employee_number'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      preferredName: json['preferred_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      nationality: json['nationality'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      sacaaCertificateNumber: json['sacaa_certificate_number'] as String?,
      rpcCategory: json['rpc_category'] as String?,
      ratings: _stringList(json['ratings']),
      medicalStatus: json['medical_status'] as String?,
      radiotelephonyQualification:
          json['radiotelephony_qualification'] as String?,
      languageProficiency: json['language_proficiency'] as String?,
      trainingHistory: _stringList(json['training_history']),
      examinerRecords: _stringList(json['examiner_records']),
      operatorAffiliations: _stringList(json['operator_affiliations']),
      supportingDocumentReferences: _stringList(
        json['supporting_document_references'],
      ),
      profileStatus: json['profile_status'] as String?,
      regulatorySource: json['regulatory_source'] as String?,
      regulatorySourceVersion: json['regulatory_source_version'] as String?,
      regulatoryEffectiveDate: json['regulatory_effective_date'] as String?,
      regulatoryApplicability: json['regulatory_applicability'] as String?,
      responsibleRole: json['responsible_role'] as String?,
      notes: json['notes'] as String?,
    );
  }

  final int id;
  final String displayName;
  final int? userId;
  final String? employeeNumber;
  final String? firstName;
  final String? lastName;
  final String? preferredName;
  final String? email;
  final String? phone;
  final String? nationality;
  final String? dateOfBirth;
  final String? sacaaCertificateNumber;
  final String? rpcCategory;
  final List<String> ratings;
  final String? medicalStatus;
  final String? radiotelephonyQualification;
  final String? languageProficiency;
  final List<String> trainingHistory;
  final List<String> examinerRecords;
  final List<String> operatorAffiliations;
  final List<String> supportingDocumentReferences;
  final String? profileStatus;
  final String? regulatorySource;
  final String? regulatorySourceVersion;
  final String? regulatoryEffectiveDate;
  final String? regulatoryApplicability;
  final String? responsibleRole;
  final String? notes;

  bool get isActive => profileStatus == 'active';

  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value.map((item) => item.toString()).toList(growable: false);
  }
}

class YawOperatorContext {
  const YawOperatorContext({
    required this.id,
    required this.legalEntity,
    this.tradingName,
    this.uasocNumber,
    this.membershipRole,
    required this.membershipStatus,
  });

  factory YawOperatorContext.fromJson(Map<String, Object?> json) {
    return YawOperatorContext(
      id: (json['id'] as num).toInt(),
      legalEntity: json['legal_entity'] as String? ?? 'YAW operator',
      tradingName: json['trading_name'] as String?,
      uasocNumber: json['uasoc_number'] as String?,
      membershipRole: json['membership_role'] as String?,
      membershipStatus: json['membership_status'] as String? ?? 'unknown',
    );
  }

  final int id;
  final String legalEntity;
  final String? tradingName;
  final String? uasocNumber;
  final String? membershipRole;
  final String membershipStatus;

  String get displayName =>
      tradingName?.isNotEmpty == true ? tradingName! : legalEntity;
  bool get isGlobal => membershipStatus == 'global';
}


class YawJourneyStep {
  const YawJourneyStep({
    required this.key,
    required this.label,
    required this.complete,
    required this.blocking,
    this.action,
  });

  factory YawJourneyStep.fromJson(Map<String, Object?> json) => YawJourneyStep(
    key: json['key'] as String? ?? '',
    label: json['label'] as String? ?? '',
    complete: json['complete'] as bool? ?? false,
    blocking: json['blocking'] as bool? ?? false,
    action: json['action'] as String?,
  );

  final String key;
  final String label;
  final bool complete;
  final bool blocking;
  final String? action;
}


class YawActionItem {
  const YawActionItem({
    required this.key,
    required this.priority,
    required this.title,
    required this.summary,
    required this.entityType,
    this.entityId,
    this.actionHref,
    this.dueAt,
  });

  factory YawActionItem.fromJson(Map<String, Object?> json) => YawActionItem(
    key: json['key'] as String? ?? '',
    priority: json['priority'] as String? ?? 'info',
    title: json['title'] as String? ?? '',
    summary: json['summary'] as String? ?? '',
    entityType: json['entity_type'] as String? ?? '',
    entityId: (json['entity_id'] as num?)?.toInt(),
    actionHref: json['action_href'] as String?,
    dueAt: json['due_at'] as String?,
  );

  final String key;
  final String priority;
  final String title;
  final String summary;
  final String entityType;
  final int? entityId;
  final String? actionHref;
  final String? dueAt;
}

class YawActionCentre {
  const YawActionCentre({
    required this.total,
    required this.critical,
    required this.warning,
    required this.info,
    required this.items,
    this.generatedAt,
  });

  factory YawActionCentre.fromJson(Map<String, Object?> json) {
    final summary = YawExperience._map(json['summary']);
    final rawItems = json['items'];

    return YawActionCentre(
      total: (summary['total'] as num?)?.toInt() ?? 0,
      critical: (summary['critical'] as num?)?.toInt() ?? 0,
      warning: (summary['warning'] as num?)?.toInt() ?? 0,
      info: (summary['info'] as num?)?.toInt() ?? 0,
      items: rawItems is List
          ? rawItems.whereType<Map>().map((item) => YawActionItem.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            )).toList(growable: false)
          : const [],
      generatedAt: json['generated_at'] as String?,
    );
  }

  final int total;
  final int critical;
  final int warning;
  final int info;
  final List<YawActionItem> items;
  final String? generatedAt;
}

class YawExperience {
  const YawExperience({
    required this.persona,
    required this.workspaceType,
    required this.onboardingComplete,
    required this.onboardingPercentage,
    required this.readinessState,
    required this.readinessPercentage,
    required this.steps,
    required this.capabilities,
    required this.actionCentre,
  });

  factory YawExperience.fromJson(Map<String, Object?> json) {
    final workspace = _map(json['workspace']);
    final onboarding = _map(json['onboarding']);
    final readiness = _map(json['readiness']);
    final rawSteps = onboarding['steps'];
    final rawCapabilities = _map(json['capabilities']);
    final actionCentre = _map(json['action_centre']);

    return YawExperience(
      persona: json['persona'] as String? ?? 'new_user',
      workspaceType: workspace['type'] as String? ?? 'personal',
      onboardingComplete: onboarding['complete'] as bool? ?? false,
      onboardingPercentage: (onboarding['percentage'] as num?)?.toInt() ?? 0,
      readinessState: readiness['state'] as String? ?? 'red',
      readinessPercentage: (readiness['percentage'] as num?)?.toInt() ?? 0,
      steps: rawSteps is List
          ? rawSteps
              .whereType<Map>()
              .map((item) => YawJourneyStep.fromJson(
                    item.map((key, value) => MapEntry(key.toString(), value)),
                  ))
              .toList(growable: false)
          : const [],
      capabilities: rawCapabilities.map(
        (key, value) => MapEntry(key, value == true),
      ),
      actionCentre: YawActionCentre.fromJson(actionCentre),
    );
  }

  final String persona;
  final String workspaceType;
  final bool onboardingComplete;
  final int onboardingPercentage;
  final String readinessState;
  final int readinessPercentage;
  final List<YawJourneyStep> steps;
  final Map<String, bool> capabilities;
  final YawActionCentre actionCentre;

  bool can(String capability) => capabilities[capability] == true;

  static Map<String, Object?> _map(Object? value) {
    if (value is Map<String, Object?>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const {};
  }
}

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final YawUser user;
}

class IdentityContext {
  const IdentityContext({
    required this.user,
    required this.pilot,
    required this.operators,
    required this.experience,
  });

  final YawUser user;
  final YawPilotProfile? pilot;
  final List<YawOperatorContext> operators;
  final YawExperience experience;
}
