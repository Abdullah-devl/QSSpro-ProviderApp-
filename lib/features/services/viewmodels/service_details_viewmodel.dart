// // مسار الملف: lib/features/services/viewmodels/service_details_viewmodel.dart

// import 'package:flutter/material.dart';
// import 'package:service_provider_app/core/utils/dialog_helper.dart';
// import '../../../core/network/error/failure.dart';
// import '../models/service_details_model.dart';
// import '../repositories/manage_services_repository.dart';

// class ServiceDetailsViewModel extends ChangeNotifier {
//   final ManageServicesRepository _repository;
//   final int serviceId;
// // متحكمات حقول إضافة خدمة فرعية
//   final TextEditingController subNameController = TextEditingController();
//   final TextEditingController subPriceController = TextEditingController();

//   ServiceDetailsViewModel({required this.serviceId, required ManageServicesRepository repository})
//       : _repository = repository {
//     fetchServiceDetails();
//   }

//   bool _isLoading = true;
//   bool get isLoading => _isLoading;

//   String? _errorMessage;
//   String? get errorMessage => _errorMessage;

//   ServiceDetailsModel? _serviceDetails;
//   ServiceDetailsModel? get serviceDetails => _serviceDetails;

//   Future<void> fetchServiceDetails() async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       _serviceDetails = await _repository.getServiceDetails(serviceId);
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

//   // 🚀 دالة إضافة خدمة فرعية
//   Future<bool> addSubService(BuildContext context) async {
//     if (subNameController.text.trim().isEmpty || subPriceController.text.trim().isEmpty) {
//       DialogHelper.showErrorDialog(context, 'يرجى إدخال اسم وسعر الخدمة الفرعية.');
//       return false;
//     }

//     _isAddingSubService = true;
//     notifyListeners();

//     try {
//       await _repository.createSubService(
//         parentId: serviceId,
//         name: subNameController.text.trim(),
//         price: double.parse(subPriceController.text.trim()),
//       );

//       _isAddingSubService = false;

//       // تفريغ الحقول بعد النجاح
//       subNameController.clear();
//       subPriceController.clear();

//       // إعادة جلب التفاصيل لتحديث القائمة
//       await fetchServiceDetails();
//       return true; // نجاح

//     } on Failure catch (failure) {
//       _isAddingSubService = false;
//       notifyListeners();
//       DialogHelper.showErrorDialog(context, failure.message);
//       return false;
//     } catch (e) {
//       _isAddingSubService = false;
//       notifyListeners();
//       DialogHelper.showErrorDialog(context, 'حدث خطأ غير متوقع أثناء الإضافة');
//       return false;
//     }
//   }

// @override
//   void dispose() {
//     subNameController.dispose();
//     subPriceController.dispose();
//     super.dispose();
//   }

//   // دالة وهمية لحذف الخدمة مستقبلاً
//   Future<void> deleteService(BuildContext context) async {
//     // سيتم برمجتها لاحقاً لترسل طلب DELETE للسيرفر
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سيتم ربط الحذف قريباً')));
//   }
// }

// مسار الملف: lib/features/services/viewmodels/service_details_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../core/network/error/failure.dart';
import '../../../core/utils/dialog_helper.dart'; // تأكد من مسار ملف التنبيهات
import '../models/service_details_model.dart';
import '../repositories/manage_services_repository.dart';

class ServiceDetailsViewModel extends ChangeNotifier {
  final ManageServicesRepository _repository;
  final int serviceId;

  // متحكمات حقول إضافة/تعديل خدمة فرعية
  final TextEditingController subNameController = TextEditingController();
  final TextEditingController subPriceController = TextEditingController();
  final TextEditingController subDescriptionController = TextEditingController();

  ServiceDetailsViewModel({
    required this.serviceId,
    required ManageServicesRepository repository,
  }) : _repository = repository {
    fetchServiceDetails();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isAddingSubService = false;
  bool get isAddingSubService => _isAddingSubService;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ServiceDetailsModel? _serviceDetails;
  ServiceDetailsModel? get serviceDetails => _serviceDetails;

  Future<void> fetchServiceDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _serviceDetails = await _repository.getServiceDetails(serviceId);
      _isLoading = false;
      notifyListeners();
    } on Failure catch (failure) {
      _isLoading = false;
      _errorMessage = failure.message;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'حدث خطأ غير متوقع';
      notifyListeners();
    }
  }

  // 🚀 دالة إضافة خدمة فرعية
  Future<bool> addSubService(BuildContext context) async {
    if (subNameController.text.trim().isEmpty ||
        subPriceController.text.trim().isEmpty) {
      DialogHelper.showErrorDialog(
        context,
        'يرجى إدخال اسم وسعر الخدمة الفرعية.',
      );
      return false;
    }

    _isAddingSubService = true;
    notifyListeners();

    try {
      await _repository.createSubService(
        parentId: serviceId,
        name: subNameController.text.trim(),
        price: double.parse(subPriceController.text.trim()),
        description: subDescriptionController.text.trim(),
      );

      _isAddingSubService = false;

      // تفريغ الحقول بعد النجاح
      subNameController.clear();
      subPriceController.clear();
      subDescriptionController.clear();

      // إعادة جلب التفاصيل لتحديث القائمة
      await fetchServiceDetails();
      return true; // نجاح
    } on Failure catch (failure) {
      _isAddingSubService = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, failure.message);
      return false;
    } catch (e) {
      _isAddingSubService = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, 'حدث خطأ غير متوقع أثناء الإضافة');
      return false;
    }
  }

  // 🚀 دالة تعديل خدمة فرعية
  Future<bool> updateSubService(BuildContext context, int childId) async {
    if (subNameController.text.trim().isEmpty ||
        subPriceController.text.trim().isEmpty) {
      DialogHelper.showErrorDialog(
        context,
        'يرجى إدخال اسم وسعر الخدمة الفرعية.',
      );
      return false;
    }

    _isAddingSubService = true;
    notifyListeners();

    try {
      await _repository.updateSubService(
        childId: childId,
        name: subNameController.text.trim(),
        price: double.parse(subPriceController.text.trim()),
        description: subDescriptionController.text.trim(),
      );

      _isAddingSubService = false;

      // تفريغ الحقول بعد النجاح
      subNameController.clear();
      subPriceController.clear();
      subDescriptionController.clear();

      // إعادة جلب التفاصيل لتحديث القائمة
      await fetchServiceDetails();
      return true; // نجاح
    } on Failure catch (failure) {
      _isAddingSubService = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, failure.message);
      return false;
    } catch (e) {
      _isAddingSubService = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, 'حدث خطأ غير متوقع أثناء التعديل');
      return false;
    }
  }

  @override
  void dispose() {
    subNameController.dispose();
    subPriceController.dispose();
    subDescriptionController.dispose();
    super.dispose();
  }


  // 🚀 دالة حذف الخدمة الفعلية
  Future<bool> deleteService(BuildContext context) async {
    _isLoading = true; // نستخدم نفس متغير التحميل لإظهار الدائرة في الشاشة
    notifyListeners();

    try {
      await _repository.deleteService(serviceId);
      
      _isLoading = false;
      notifyListeners();
      return true; // نجاح الحذف

    } on Failure catch (failure) {
      _isLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, failure.message);
      return false; // فشل الحذف
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, 'حدث خطأ غير متوقع أثناء الحذف');
      return false;
    }
  }


  // 🚀 دالة حذف الخدمة الفرعية
  Future<void> deleteSubService(BuildContext context, int subServiceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // نستخدم نفس دالة الحذف الموجودة في الـ Repository لأن الرابط واحد (DELETE /services/{id})
      await _repository.deleteService(subServiceId);
      
      // بمجرد نجاح الحذف، نقوم بتحديث تفاصيل الخدمة الأساسية لكي تختفي الخدمة الفرعية من الشاشة
      await fetchServiceDetails(); 
      
      if (context.mounted) {
        DialogHelper.showSuccessDialog(context, 'تم حذف الخدمة الفرعية بنجاح');
      }

    } on Failure catch (failure) {
      _isLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, failure.message);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, 'حدث خطأ أثناء الحذف');
    }
  }

  // 🚀 دالة حذف الموعد (الجدولة)
  Future<void> deleteServiceSchedule(BuildContext context, int scheduleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteServiceSchedule(scheduleId);
      
      // إعادة تحميل تفاصيل الخدمة بعد الحذف لتحديث قائمة المواعيد
      await fetchServiceDetails();
      
      if (context.mounted) {
        DialogHelper.showSuccessDialog(context, 'تم حذف الفترة بنجاح');
      }

    } on Failure catch (failure) {
      _isLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, failure.message);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, 'حدث خطأ أثناء الحذف');
    }
  }
}
 