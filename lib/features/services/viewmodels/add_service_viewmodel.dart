// // مسار الملف: lib/features/services/viewmodels/add_service_viewmodel.dart

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:service_provider_app/core/network/error/failure.dart';
// import 'package:service_provider_app/core/utils/dialog_helper.dart';
// import 'package:service_provider_app/features/services/models/service_details_model.dart';

// // الاستدعاءات الخاصة بالـ Repository والـ Model
// import '../repositories/manage_services_repository.dart';
// import '../models/category_model.dart'; // ✅ تم إضافة استدعاء المودل هنا

// class AddServiceViewModel extends ChangeNotifier {
//   final ManageServicesRepository _repository;
//   final ServiceDetailsModel? serviceToEdit;

//   // ✅ دالة البناء الصحيحة والمدمجة (واحدة فقط)
//   AddServiceViewModel(this._repository, {this.serviceToEdit}) {
//     fetchCategories(); // جلب الفئات تلقائياً عند فتح الشاشة
//   }

//   // =====================================
//   // 1. المتحكمات (Controllers)
//   // =====================================
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController priceController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();

//   // =====================================
//   // 2. إدارة الفئات (Categories)
//   // =====================================
//   int? _selectedCategoryId;
//   int? get selectedCategoryId => _selectedCategoryId;

//   List<CategoryModel> _categories = [];
//   List<CategoryModel> get categories => _categories;

//   bool _isLoadingCategories = false;
//   bool get isLoadingCategories => _isLoadingCategories;

//   void setCategory(int? id) {
//     _selectedCategoryId = id;
//     notifyListeners();
//   }

//   // Future<void> fetchCategories() async {
//   //   _isLoadingCategories = true;
//   //   notifyListeners();

//   //   try {
//   //     _categories = await _repository.getMainCategories();
//   //   } catch (e) {
//   //     // في حال حدوث خطأ، ستظل القائمة فارغة
//   //     debugPrint('Error fetching categories: $e');
//   //   } finally {
//   //     _isLoadingCategories = false;
//   //     notifyListeners();
//   //   }
//   // }






  
//   // دالة جلب الفئات
//   Future<void> fetchCategories() async {
//     _isLoadingCategories = true;
//     notifyListeners();

//     try {
//       _categories = await _repository.getMainCategories();
//       debugPrint('✅ تم جلب الفئات بنجاح: عددها ${_categories.length}');
//     } catch (e) {
//       // 🚨 الآن سنطبع الخطأ لكي نعرف المشكلة من السيرفر!
//       debugPrint('❌ حدث خطأ أثناء جلب الفئات: $e');
//     } finally {
//       _isLoadingCategories = false;
//       notifyListeners();
//     }
//   }

//   // =====================================
//   // 3. إدارة الصورة (Image)
//   // =====================================
//   File? _imageFile;
//   File? get imageFile => _imageFile;

//   Future<void> pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       _imageFile = File(pickedFile.path);
//       notifyListeners();
//     }
//   }

//   // =====================================
//   // 4. إرسال البيانات (Submit)
//   // =====================================
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   Future<bool> submitService(BuildContext context) async {
//     if (nameController.text.trim().isEmpty ||
//         priceController.text.trim().isEmpty ||
//         _selectedCategoryId == null) {
//       // _showError(context, 'يرجى تعبئة الحقول الأساسية (الاسم، الفئة، السعر)');
//       DialogHelper.showErrorDialog(
//         context,
//         'يرجى تعبئة الحقول الأساسية (الاسم، الفئة، السعر)',
//       );
//       return false;
//     }

//     _isLoading = true;
//     notifyListeners();

//     try {
//       await _repository.createService(
//         name: nameController.text.trim(),
//         description: descriptionController.text.trim(),
//         price: double.parse(priceController.text.trim()),
//         categoryId: _selectedCategoryId!,
//         imageFile: _imageFile,
//       );

//       _isLoading = false;
//       notifyListeners();
//       return true; // نجاح الرفع
//     } on Failure catch (failure) {
//       _isLoading = false;
//       notifyListeners();
//       // _showError(context, failure.message);
//       DialogHelper.showErrorDialog(context, failure.message);
//       return false;
//     } catch (e) {
//       _isLoading = false;
//       notifyListeners();
//       // _showError(context, 'حدث خطأ غير متوقع');
//       DialogHelper.showErrorDialog(context, 'حدث خطأ غير متوقع');
//       return false;
//     }
//   }

//   // =====================================
//   // 5. دوال مساعدة (Helpers)
//   // =====================================
//   // void _showError(BuildContext context, String msg) {
//   //   ScaffoldMessenger.of(context).showSnackBar(
//   //     SnackBar(
//   //       content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
//   //       backgroundColor: context.qsColors.error,
//   //       behavior: SnackBarBehavior.floating,
//   //     )
//   //   );
//   // }

//   @override
//   void dispose() {
//     nameController.dispose();
//     priceController.dispose();
//     descriptionController.dispose();
//     super.dispose();
//   }


  
// }


// مسار الملف: lib/features/services/viewmodels/add_service_viewmodel.dart

import 'dart:io';
// import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_provider_app/core/network/error/failure.dart';
import 'package:service_provider_app/core/utils/dialog_helper.dart';
import 'package:service_provider_app/features/services/models/service_details_model.dart';

// الاستدعاءات الخاصة بالـ Repository والـ Model
import '../repositories/manage_services_repository.dart';
import '../models/category_model.dart';
import '../models/service_schedule_model.dart';

class AddServiceViewModel extends ChangeNotifier {
  final ManageServicesRepository _repository;
  final ServiceDetailsModel? serviceToEdit;

  // ✅ دالة البناء الصحيحة والمدمجة (واحدة فقط)
  AddServiceViewModel(this._repository, {this.serviceToEdit}) {
    _initSchedules();
    fetchCategories().then((_) {
      _initEditData();
    });
  }

  // =====================================
  // 1. المتحكمات (Controllers)
  // =====================================
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController partialPercentController = TextEditingController();
  final TextEditingController pricePerKmController = TextEditingController();

  // =====================================
  // 1.1. إعدادات السعر والمسافة
  // =====================================
  bool _distanceBasedPrice = false;
  bool get distanceBasedPrice => _distanceBasedPrice;

  void setDistanceBasedPrice(bool value) {
    _distanceBasedPrice = value;
    notifyListeners();
  }

  // =====================================
  // 1.2. الجدولة الزمنية (Schedules)
  // =====================================
  List<ServiceScheduleModel> _schedules = [];
  List<ServiceScheduleModel> get schedules => _schedules;

  void _initSchedules() {
    final days = [
      'Saturday',
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday'
    ];
    _schedules = days.map((day) => ServiceScheduleModel(days: [day])).toList();
  }

  void toggleDay(int index) {
    _schedules[index] = _schedules[index].copyWith(isActive: !_schedules[index].isActive);
    notifyListeners();
  }

  void updateStartTime(int index, String time) {
    _schedules[index] = _schedules[index].copyWith(startTime: time);
    notifyListeners();
  }

  void updateEndTime(int index, String time) {
    _schedules[index] = _schedules[index].copyWith(endTime: time);
    notifyListeners();
  }

  // =====================================
  // 2. إدارة الفئات (Categories)
  // =====================================
  int? _selectedCategoryId;
  int? get selectedCategoryId => _selectedCategoryId;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  bool _isLoadingCategories = false;
  bool get isLoadingCategories => _isLoadingCategories;

  void setCategory(int? id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  void _initEditData() {
    if (serviceToEdit != null) {
      nameController.text = serviceToEdit!.title;
      descriptionController.text = serviceToEdit!.description;
      priceController.text = serviceToEdit!.priceText.replaceAll(RegExp(r'[^0-9.]'), '');
      // If serviceToEdit has a property for partialPercent, we'd use it here.
      // But we'll leave it empty or default it if not available.
      partialPercentController.text = serviceToEdit!.requiredPartialPercentage.toString();
      _distanceBasedPrice = serviceToEdit!.distanceBasedPrice;
      pricePerKmController.text = serviceToEdit!.pricePerKm.toString();
      
      if (serviceToEdit!.schedules.isNotEmpty) {
        // نحدث الجداول الموجودة بالمخزنة في السيرفر
        for (var remoteSchedule in serviceToEdit!.schedules) {
          if (remoteSchedule.days.isNotEmpty) {
            for (var remoteDay in remoteSchedule.days) {
              int index = _schedules.indexWhere((s) => s.days.isNotEmpty && s.days.first == remoteDay);
              if (index != -1) {
                _schedules[index] = remoteSchedule.copyWith(days: [remoteDay]);
              }
            }
          }
        }
      }
      
      setCategory(serviceToEdit!.categoryId);
    }
  }

  // دالة جلب الفئات
  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      _categories = await _repository.getMainCategories();
      debugPrint('✅ تم جلب الفئات بنجاح: عددها ${_categories.length}');
    } catch (e) {
      // 🚨 الآن سنطبع الخطأ لكي نعرف المشكلة من السيرفر!
      debugPrint('❌ حدث خطأ أثناء جلب الفئات: $e');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // =====================================
  // 3. إدارة الصورة (Image)
  // =====================================
  File? _imageFile;
  File? get imageFile => _imageFile;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      notifyListeners();
    }
  }

  // =====================================
  // 4. إرسال البيانات (Submit)
  // =====================================
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<int?> submitService(BuildContext context) async {
    if (nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        partialPercentController.text.trim().isEmpty ||
        _selectedCategoryId == null) {
      DialogHelper.showErrorDialog(
        context,
        'يرجى تعبئة الحقول الأساسية (الاسم، الفئة، السعر، نسبة الدفع المسبق)',
      );
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      int? createdId;
      if (serviceToEdit == null) {
        final newService = await _repository.createService(
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          price: double.parse(priceController.text.trim()),
          categoryId: _selectedCategoryId!,
          requiredPartialPercent: int.parse(partialPercentController.text.trim()),
          distanceBasedPrice: _distanceBasedPrice,
          pricePerKm: _distanceBasedPrice ? double.tryParse(pricePerKmController.text.trim()) ?? 0.0 : 0.0,
          schedules: _schedules,
          imageFile: _imageFile,
        );
        createdId = newService.id;
      } else {
        await _repository.updateService(
          serviceId: serviceToEdit!.id,
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          price: double.parse(priceController.text.trim()),
          categoryId: _selectedCategoryId!,
          requiredPartialPercent: int.parse(partialPercentController.text.trim()),
          distanceBasedPrice: _distanceBasedPrice,
          pricePerKm: _distanceBasedPrice ? double.tryParse(pricePerKmController.text.trim()) ?? 0.0 : 0.0,
          schedules: _schedules,
          imageFile: _imageFile,
        );
        createdId = serviceToEdit!.id;
      }

      _isLoading = false;
      notifyListeners();
      return createdId; // نجاح الرفع
    } on Failure catch (failure) {
      _isLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, failure.message);
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, 'حدث خطأ غير متوقع');
      return null;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    partialPercentController.dispose();
    super.dispose();
  }
}
