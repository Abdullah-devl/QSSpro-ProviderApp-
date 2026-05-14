// // مسار الملف: lib/features/services/viewmodels/manage_services_viewmodel.dart

// import 'package:flutter/material.dart';
// import 'package:service_provider_app/core/network/error/failure.dart';
// import '../models/manage_services_model.dart';
// import '../repositories/manage_services_repository.dart';

// class ManageServicesViewModel extends ChangeNotifier {
//   final ManageServicesRepository _repository;

//   ManageServicesViewModel(this._repository) {
//     fetchServices();
//   }

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String? _errorMessage;
//   String? get errorMessage => _errorMessage;

//   List<ServiceModel> _allServices = [];

//   // 0=الكل, 1=نشط, 2=مسودة, 3=موقوف
//   int _selectedFilterIndex = 0;
//   int get selectedFilterIndex => _selectedFilterIndex;

//   // إرجاع القائمة المفلترة بناءً على التبويب المختار
//   List<ServiceModel> get filteredServices {
//     if (_selectedFilterIndex == 0) return _allServices;

//     //     String statusFilter = '';
//     //     // if (_selectedFilterIndex == 1) statusFilter = 'نشط';
//     //     // if (_selectedFilterIndex == 2) statusFilter = 'مسودة';
//     //     // if (_selectedFilterIndex == 3) statusFilter = 'موقوف';
//     // if (_selectedFilterIndex == 1) return _allServices.where((s) => s.status == 'نشط').toList();
//     //     if (_selectedFilterIndex == 2) return _allServices.where((s) => s.status == 'غير نشط').toList();

//     if (_selectedFilterIndex == 0) return _allServices;

//     // تحديد حالة البحث بناءً على رقم الفلتر
//     String statusFilter = '';
//     if (_selectedFilterIndex == 1) {
//       statusFilter = 'نشط';
//     } else if (_selectedFilterIndex == 2) {
//       statusFilter = 'غير نشط';
//     }
//     return _allServices.where((s) => s.status == statusFilter).toList();
//   }

//   void changeFilter(int index) {
//     _selectedFilterIndex = index;
//     notifyListeners();
//   }

//   Future<void> fetchServices() async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       _allServices = await _repository.getServices();
//       _isLoading = false;
//       notifyListeners();
//     } on Failure catch (failure) {
//       _isLoading = false;
//       _errorMessage = failure.message;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = 'حدث خطأ غير متوقع';
//       notifyListeners();
//     }
//   }
// }

// مسار الملف: lib/features/services/viewmodels/manage_services_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../core/network/error/failure.dart';
import '../models/manage_services_model.dart';
import '../repositories/manage_services_repository.dart';

class ManageServicesViewModel extends ChangeNotifier {
  final ManageServicesRepository _repository;

  ManageServicesViewModel(this._repository) {
    // 👈 تأكد من وجود هذا الاستدعاء هنا
    fetchServices();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ServiceModel> _allServices = [];

  // 0=الكل, 1=نشط, 2=غير نشط
  int _selectedFilterIndex = 0;
  int get selectedFilterIndex => _selectedFilterIndex;

  // إرجاع القائمة المفلترة بناءً على التبويب المختار
  List<ServiceModel> get filteredServices {
    if (_selectedFilterIndex == 0) return _allServices;

    String statusFilter = '';
    if (_selectedFilterIndex == 1) {
      statusFilter = 'نشط';
    } else if (_selectedFilterIndex == 2) {
      statusFilter = 'غير نشط';
    }
    return _allServices.where((s) => s.status == statusFilter).toList();
  }

  void changeFilter(int index) {
    _selectedFilterIndex = index;
    notifyListeners();
  }

  bool _hasFetchedOnce = false;

  Future<void> fetchServices() async {
    // 1. 📥 تحميل الخدمات من الكاش المحلي فوراً وعرضها للمستخدم بدون تأخير
    final cachedServices = _repository.getCachedServices();
    if (cachedServices.isNotEmpty) {
      _allServices = cachedServices;
      debugPrint('⚡ ManageServicesViewModel: Loaded ${_allServices.length} services instantly from local Hive cache.');
      notifyListeners();
    }

    // 2. ⚡ تفعيل الشيمر في المرة الأولى فقط خلال جلسة التطبيق الحالية
    if (!_hasFetchedOnce) {
      _isLoading = true;
      _hasFetchedOnce = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _allServices = await _repository.getServices();
      debugPrint('✅ تم جلب الخدمات بنجاح. عددها: ${_allServices.length}');
      _isLoading = false;
      notifyListeners();
    } on Failure catch (failure) {
      _isLoading = false;
      if (_allServices.isEmpty) {
        _errorMessage = failure.message;
      }
      debugPrint('❌ فشل جلب الخدمات: ${failure.message}');
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (_allServices.isEmpty) {
        _errorMessage = 'حدث خطأ غير متوقع';
      }
      debugPrint('❌ حدث خطأ غير متوقع: $e');
      notifyListeners();
    }
  }

  Future<void> toggleServiceStatus(ServiceModel service) async {
    try {
      // تحديث متفائل للواجهة (Optimistic Update)
      int index = _allServices.indexWhere((s) => s.id == service.id);
      if (index != -1) {
        bool newStatus = !service.isActive;
        _allServices[index] = ServiceModel(
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
        notifyListeners();

        // إرسال الطلب للسيرفر
        await _repository.updateService(
          serviceId: service.id,
          isActive: newStatus,
        );
        
        debugPrint('✅ تم تحديث حالة الخدمة بنجاح');
      }
    } catch (e) {
      debugPrint('❌ فشل تحديث حالة الخدمة: $e');
      // إعادة جلب البيانات في حال الفشل للتأكد من المزامنة
      await fetchServices();
    }
  }
}
