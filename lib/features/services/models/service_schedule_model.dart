// // مسار الملف: lib/features/services/models/service_schedule_model.dart

// class ServiceScheduleModel {
//   final int? id;
//   final List<String> days; // ['Monday', 'Tuesday', etc.]
//   final String startTime; // '00:00'
//   final String endTime; // '23:59'
//   final bool isActive;
//   final String? label;

//   ServiceScheduleModel({
//     this.id,
//     this.days = const [],
//     this.startTime = "08:00",
//     this.endTime = "22:00",
//     this.isActive = true,
//     this.label,
//   });

//   factory ServiceScheduleModel.fromJson(Map<String, dynamic> json) {
//     var rawDays = json['days'] as List? ?? [];
//     List<String> parsedDays = rawDays.map<String>((d) {
//       if (d is Map) return (d['day'] ?? '').toString();
//       return d.toString();
//     }).toList();

//     bool active = false;
//     if (json['is_active'] != null) {
//       final val = json['is_active'];
//       if (val == 1 || val == '1' || val == true || val == 'true') {
//         active = true;
//       }
//     }

//     return ServiceScheduleModel(
//       id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
//       days: parsedDays,
//       startTime: json['start_time'] ?? '08:00',
//       endTime: json['end_time'] ?? '22:00',
//       isActive: active,
//       label: json['label']?.toString(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       if (id != null) 'id': id,
//       'days': days,
//       'start_time': startTime,
//       'end_time': endTime,
//       'is_active': isActive ? 1 : 0,
//       if (label != null) 'label': label,
//     };
//   }

//   ServiceScheduleModel copyWith({
//     int? id,
//     List<String>? days,
//     String? startTime,
//     String? endTime,
//     bool? isActive,
//     String? label,
//   }) {
//     return ServiceScheduleModel(
//       id: id ?? this.id,
//       days: days ?? this.days,
//       startTime: startTime ?? this.startTime,
//       endTime: endTime ?? this.endTime,
//       isActive: isActive ?? this.isActive,
//       label: label ?? this.label,
//     );
//   }
// }

// lib/features/services/models/service_schedule_model.dart

class ServiceScheduleModel {
  final int? id;
  final List<String> days;
  final String startTime;
  final String endTime;
  final bool isActive;
  final String? label;

  ServiceScheduleModel({
    this.id,
    this.days = const [],
    this.startTime = "08:00",
    this.endTime = "22:00",
    this.isActive = true,
    this.label,
  });

  factory ServiceScheduleModel.fromJson(Map<String, dynamic> json) {
    // 🛡️ إصلاح استخراج الأيام من الـ Nested Objects
    var rawDays = json['days'] as List? ?? [];
    List<String> parsedDays = rawDays.map<String>((d) {
      if (d is Map) {
        return (d['day'] ?? '').toString().toLowerCase(); // تحويل لـ lowercase
      }
      return d.toString().toLowerCase();
    }).toList();

    // 🛡️ معالجة الوقت لاقتطاع الثواني (00:00:00 -> 00:00)
    String cleanTime(String? time) {
      if (time == null || !time.contains(':')) return '00:00';
      final parts = time.split(':');
      return "${parts[0]}:${parts[1]}";
    }

    return ServiceScheduleModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      days: parsedDays,
      startTime: cleanTime(json['start_time']),
      endTime: cleanTime(json['end_time']),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      label: json['label']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'days': days,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': isActive ? 1 : 0,
      if (label != null) 'label': label,
    };
  }

  ServiceScheduleModel copyWith({
    int? id,
    List<String>? days,
    String? startTime,
    String? endTime,
    bool? isActive,
    String? label,
  }) {
    return ServiceScheduleModel(
      id: id ?? this.id,
      days: days ?? this.days,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      label: label ?? this.label,
    );
  }
}
