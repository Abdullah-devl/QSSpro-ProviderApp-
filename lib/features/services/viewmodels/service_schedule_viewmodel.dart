import 'package:flutter/material.dart';
import 'package:service_provider_app/core/network/error/failure.dart';
import 'package:service_provider_app/core/utils/dialog_helper.dart';
import '../repositories/manage_services_repository.dart';
import '../models/service_schedule_model.dart';

class ServiceScheduleViewModel extends ChangeNotifier {
  final ManageServicesRepository _repository;
  final int serviceId;
  final ServiceScheduleModel? initialSchedule;

  ServiceScheduleViewModel(
    this._repository,
    this.serviceId, {
    this.initialSchedule,
  }) {
    _initSchedule();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  late ServiceScheduleModel _schedule;
  ServiceScheduleModel get schedule => _schedule;

  // 📝 ترتيب أيام الأسبوع لضمان عرض جذاب
  final List<String> _weekOrder = [
    'saturday',
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
  ];

  void _initSchedule() {
    if (initialSchedule != null) {
      final lowerDays = initialSchedule!.days.map((d) => d.toLowerCase()).toList();
      lowerDays.sort((a, b) => _weekOrder.indexOf(a).compareTo(_weekOrder.indexOf(b)));
      _schedule = initialSchedule!.copyWith(days: lowerDays);
    } else {
      // الحالة الافتراضية للفترة الجديدة
      _schedule = ServiceScheduleModel(
        days: [],
        startTime: "08:00",
        endTime: "22:00",
        isActive: true,
      );
    }
  }

  // 🔄 تبديل حالة اليوم (مع الترتيب التلقائي)
  void toggleDay(String dayName) {
    final day = dayName.toLowerCase();
    List<String> currentDays = List.from(_schedule.days);

    if (currentDays.contains(day)) {
      currentDays.remove(day);
    } else {
      currentDays.add(day);
      // الترتيب لضمان شكل جذاب في الواجهة
      currentDays.sort((a, b) => _weekOrder.indexOf(a).compareTo(_weekOrder.indexOf(b)));
    }

    _schedule = _schedule.copyWith(days: currentDays);
    notifyListeners();
  }

  void toggleActive(bool value) {
    _schedule = _schedule.copyWith(isActive: value);
    notifyListeners();
  }

  // ⏱️ تحديث الأوقات
  Future<void> updateStartTime(BuildContext context) async {
    final TimeOfDay? picked = await _pickTime(context, _schedule.startTime);
    if (picked != null) {
      _schedule = _schedule.copyWith(startTime: _formatTime(picked));
      notifyListeners();
    }
  }

  Future<void> updateEndTime(BuildContext context) async {
    final TimeOfDay? picked = await _pickTime(context, _schedule.endTime);
    if (picked != null) {
      _schedule = _schedule.copyWith(endTime: _formatTime(picked));
      notifyListeners();
    }
  }

  // 🛠️ دوال مساعدة للأوقات
  Future<TimeOfDay?> _pickTime(BuildContext context, String currentTime) async {
    final parts = currentTime.split(':');
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts[1]) ?? 0,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  // 🚀 حفظ البيانات (إضافة أو تعديل)
  Future<bool> saveSchedule(BuildContext context) async {
    if (_schedule.days.isEmpty) {
      DialogHelper.showErrorDialog(context, 'يرجى اختيار يوم واحد على الأقل للموعد');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (initialSchedule != null && initialSchedule!.id != null) {
        // تعديل موعد موجود
        await _repository.updateServiceSchedule(
          scheduleId: initialSchedule!.id!,
          startTime: _schedule.startTime,
          endTime: _schedule.endTime,
          days: _schedule.days,
        );
      } else {
        // إضافة موعد جديد
        await _repository.addServiceSchedule(
          serviceId: serviceId,
          startTime: _schedule.startTime,
          endTime: _schedule.endTime,
          days: _schedule.days,
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on Failure catch (failure) {
      _isLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, failure.message);
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, 'حدث خطأ غير متوقع');
      return false;
    }
  }
}
