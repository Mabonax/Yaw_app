import 'dart:convert';

Map<String, Object?> briefingMap(Object? value) => value is Map
    ? value.map((key, value) => MapEntry(key.toString(), value))
    : const {};

List<Map<String, Object?>> briefingMaps(Object? value) => value is List
    ? value.whereType<Map>().map(briefingMap).toList(growable: false)
    : const [];

class YawBriefingItem {
  YawBriefingItem(this.raw);
  final Map<String, Object?> raw;
  int get id => (raw['id'] as num).toInt();
  String get title => raw['title']?.toString() ?? '';
  String get identifier => raw['source_identifier']?.toString() ?? '';
  String get type => raw['type']?.toString() ?? '';
  String get severity => raw['severity']?.toString() ?? 'unknown';
  String get releaseEffect => raw['release_effect']?.toString() ?? 'unknown';
  String get reason => raw['reason']?.toString() ?? '';
  String get classification =>
      raw['source_classification']?.toString() ?? 'unknown';
  bool get usableForRelease => raw['usable_for_release'] == true;
  Map<String, Object?> get source => briefingMap(raw['source']);
  Map<String, Object?> get interpretation => briefingMap(raw['interpretation']);
  String get rawMessage =>
      source['raw_message']?.toString() ?? 'No raw message supplied.';
  String get sourceUrl => source['source_url']?.toString() ?? '';
  String pretty(Object? value) =>
      const JsonEncoder.withIndent('  ').convert(value);
}

class YawBriefingView {
  YawBriefingView._(this.raw);

  factory YawBriefingView.fromJson(Map<String, Object?> raw) {
    final compliance = briefingMap(raw['compliance']);
    if (compliance['status'] is! String ||
        raw['mission'] is! Map ||
        (raw['briefing'] != null && raw['briefing'] is! Map)) {
      throw const FormatException('Incomplete briefing response.');
    }
    return YawBriefingView._(raw);
  }

  final Map<String, Object?> raw;
  Map<String, Object?> get mission => briefingMap(raw['mission']);
  Map<String, Object?> get briefing => briefingMap(raw['briefing']);
  Map<String, Object?> get compliance => briefingMap(raw['compliance']);
  Map<String, Object?> get permissions => briefingMap(raw['permissions']);
  int? get id => (briefing['id'] as num?)?.toInt();
  int? get revision => (briefing['revision'] as num?)?.toInt();
  String get status => compliance['status'] as String;
  String get freshness => compliance['freshness']?.toString() ?? 'unavailable';
  bool get canGenerate => permissions['generate'] == true;
  bool get canAcknowledge => permissions['acknowledge'] == true;
  bool get acknowledged => briefing['acknowledged'] == true;
  bool get acknowledgementRequired =>
      briefing['acknowledgement_required'] == true;
  List<String> get reasons =>
      (compliance['reasons'] as List? ?? []).map((v) => v.toString()).toList();
  List<Map<String, Object?>> get providers =>
      briefingMaps(compliance['providers']);
  List<Map<String, Object?>> get revisions => briefingMaps(raw['revisions']);
  List<YawBriefingItem> get items =>
      briefingMaps(briefing['items']).map(YawBriefingItem.new).toList();
}
