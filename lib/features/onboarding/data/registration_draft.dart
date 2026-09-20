import 'package:file_selector/file_selector.dart';

/// Form state only. Never an authenticated session or a server record.
class RegistrationDraft {
  String name = '';
  String email = '';
  String phone = '';
  String callingCode = '+27';
  String country = 'South Africa';
  DateTime? dateOfBirth;
  String role = 'Pilot';
  String aircraftType = 'Multirotor';
  String manufacturer = '';
  String model = '';
  String serial = '';
  String registration = '';
  final List<CertificationDraft> licences = [CertificationDraft()];
  final List<CertificationDraft> medicals = [CertificationDraft(medical: true)];
  bool confirmed = false;
}

class CertificationDraft {
  CertificationDraft({this.medical = false});
  final bool medical;
  String number = '';
  String category = 'Multirotor';
  DateTime? issuedAt;
  DateTime? expiresAt;
  XFile? document;
  bool get hasDetails =>
      number.trim().isNotEmpty ||
      issuedAt != null ||
      expiresAt != null ||
      document != null;
}

String formatSetupDate(DateTime? date) {
  if (date == null) return 'Not provided';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
