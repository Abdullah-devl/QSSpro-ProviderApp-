import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../repositories/profile_repository.dart';

class ServicesViewModel extends ChangeNotifier {
  final ProfileRepository repository;

  ServicesViewModel(this.repository) {
    fetchServices();
  }

  bool isLoading = false;
  String? errorMessage;
  List<ServiceModel> services = [];

  Future<void> fetchServices() async {
    // 1. 📥 تحميل الخدمات من الكاش المحلي فوراً
    final cached = repository.getCachedServices();
    if (cached.isNotEmpty) {
      services = cached;
      debugPrint('⚡ ServicesViewModel: Loaded ${services.length} services instantly from local Hive cache.');
      notifyListeners();
    }

    // 2. 🌐 التحديث في الخلفية
    isLoading = services.isEmpty;
    errorMessage = null;
    notifyListeners();

    try {
      services = await repository.getServices();
      errorMessage = null;
    } catch (e) {
      debugPrint('❌ ServicesViewModel fetchServices error: $e');
      if (services.isEmpty) {
        errorMessage = e.toString();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🚀 الدالة الخاصة بتفعيل/إلغاء التفعيل للخدمة
  Future<void> toggleServiceStatus(int id, bool isActive) async {
    // 1. تحديث الحالة محلياً فوراً لتجربة مستخدم سريعة (Optimistic Update)
    final index = services.indexWhere((s) => s.id == id);
    if (index != -1) {
      final oldStatus = services[index].isActive;
      services[index].isActive = isActive;
      notifyListeners();

      try {
        // 2. إرسال الطلب للباك إند
        await repository.toggleServiceStatus(id, isActive);
      } catch (e) {
        // 3. في حال الفشل، نعيد الحالة السابقة وننبه المستخدم
        services[index].isActive = oldStatus;
        notifyListeners();
        debugPrint('❌ Failed to toggle service status: $e');
      }
    }
  }
}
