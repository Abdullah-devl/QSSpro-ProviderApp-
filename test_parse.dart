import 'dart:convert';

void main() {
  final jsonStr = '''
  {
    "id": 32,
    "days": [
      {"id": 224, "schedule_service_id": 32, "day": "friday"},
      {"id": 220, "schedule_service_id": 32, "day": "monday"}
    ],
    "start_time": "00:00:00",
    "end_time": "23:59:59",
    "is_active": 1,
    "label": "متاح دائماً (24/7)"
  }
  ''';
  
  final json = jsonDecode(jsonStr);
  
  var rawDays = json['days'] as List? ?? [];
  List<String> parsedDays = rawDays.map((d) {
    if (d is Map) return (d['day'] ?? '').toString();
    return d.toString();
  }).toList();
  
  bool active = false;
  if (json['is_active'] != null) {
    final val = json['is_active'];
    if (val == 1 || val == '1' || val == true || val == 'true') {
      active = true;
    }
  }

  print('Label: ${json['label']}');
  print('Parsed Days: $parsedDays');
  print('Active: $active');
}
