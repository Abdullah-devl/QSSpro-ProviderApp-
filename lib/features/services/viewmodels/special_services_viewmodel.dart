import 'package:flutter/material.dart';
import '../../profile/repositories/profile_repository.dart';
import '../models/manage_services_model.dart';
import '../repositories/manage_services_repository.dart';

class SpecialServicesViewModel extends ChangeNotifier {
  final ManageServicesRepository repository;
  final ProfileRepository profileRepository;

  List<ServiceModel> customServices = [];
  List<ServiceModel> meetingServices = [];

  bool isCustomLoading = true;
  bool isMeetingLoading = true;
  
  String? customError;
  String? meetingError;

  int? _userId;

  SpecialServicesViewModel(this.repository, this.profileRepository) {
    loadAllServices();
  }

  Future<void> _ensureUserId() async {
    if (_userId != null) return;
    try {
      final profile = await profileRepository.getMyProfile();
      _userId = profile.id;
    } catch (e) {
      debugPrint('❌ SpecialServicesViewModel: Error getting userId: $e');
    }
  }

  Future<void> loadAllServices() async {
    await _ensureUserId();
    loadCustomServices();
    loadMeetingServices();
  }

  Future<void> loadCustomServices() async {
    if (_userId == null) await _ensureUserId();
    if (_userId == null) {
      customError = 'Unable to identify user';
      isCustomLoading = false;
      notifyListeners();
      return;
    }

    isCustomLoading = true;
    customError = null;
    notifyListeners();

    try {
      customServices = await repository.getCustomServices(_userId);
    } catch (e) {
      customError = e.toString();
    } finally {
      isCustomLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMeetingServices() async {
    if (_userId == null) await _ensureUserId();
    if (_userId == null) {
      meetingError = 'Unable to identify user';
      isMeetingLoading = false;
      notifyListeners();
      return;
    }

    isMeetingLoading = true;
    meetingError = null;
    notifyListeners();

    try {
      meetingServices = await repository.getMeetingServices(_userId);
    } catch (e) {
      meetingError = e.toString();
    } finally {
      isMeetingLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleServiceStatus(ServiceModel service) async {
    try {
      // البحث عما إذا كانت الخدمة مخصصة أم حضور
      bool isCustom = customServices.any((s) => s.id == service.id);
      bool isMeeting = meetingServices.any((s) => s.id == service.id);

      // تحديث متفائل (Optimistic Update)
      int customIndex = customServices.indexWhere((s) => s.id == service.id);
      if (customIndex != -1) {
        bool newStatus = !service.isActive;
        customServices[customIndex] = _updateServiceStatus(service, newStatus);
        notifyListeners();
      }

      int meetingIndex = meetingServices.indexWhere((s) => s.id == service.id);
      if (meetingIndex != -1) {
        bool newStatus = !service.isActive;
        meetingServices[meetingIndex] = _updateServiceStatus(service, newStatus);
        notifyListeners();
      }

      // إرسال الطلب باستخدام دالة التحديث الخاصة بالخدمات التلقائية (PUT)
      await repository.updateSpecialService(
        isCustom: isCustom,
        isActive: !service.isActive,
      );
    } catch (e) {
      // إعادة التحديث من السيرفر في حال الفشل
      await loadAllServices();
    }
  }

  ServiceModel _updateServiceStatus(ServiceModel service, bool newStatus) {
    return ServiceModel(
      id: service.id,
      title: service.title,
      priceText: service.priceText,
      status: newStatus ? 'نشط' : 'غير نشط',
      isActive: newStatus,
      imageUrl: service.imageUrl,
      subServicesCount: service.subServicesCount,
      isExpanded: service.isExpanded,
      quickServices: service.quickServices,
    );
  }
}
