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
  });

  factory YawExperience.fromJson(Map<String, Object?> json) {
    final workspace = _map(json['workspace']);
    final onboarding = _map(json['onboarding']);
    final readiness = _map(json['readiness']);
    final rawSteps = onboarding['steps'];
    final rawCapabilities = _map(json['capabilities']);

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
