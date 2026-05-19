// مسار الملف: lib/features/services/viewmodels/edit_service_viewmodel.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_provider_app/core/network/error/failure.dart';
import 'package:service_provider_app/core/utils/dialog_helper.dart';
import 'package:service_provider_app/features/services/models/service_details_model.dart';
import '../repositories/manage_services_repository.dart';
import '../models/category_model.dart';
import '../models/service_schedule_model.dart';

class EditServiceViewModel extends ChangeNotifier {
  final ManageServicesRepository _repository;
  final ServiceDetailsModel service;

  EditServiceViewModel(this._repository, this.service) {
    _initSchedules();
    _initData();
    fetchCategories();
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController partialPercentController = TextEditingController();
  final TextEditingController pricePerKmController = TextEditingController();

  int? _selectedCategoryId;
  int? get selectedCategoryId => _selectedCategoryId;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  // قائمة مسطحة لعرض الفئات الرئيسية والفرعية معاً في القائمة المنسدلة
  List<CategoryModel> _flattenedCategories = [];
  List<CategoryModel> get flattenedCategories => _flattenedCategories;

  bool _isLoadingCategories = false;
  bool get isLoadingCategories => _isLoadingCategories;

  File? _imageFile;
  File? get imageFile => _imageFile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _distanceBasedPrice = false;
  bool get distanceBasedPrice => _distanceBasedPrice;

  bool _isActive = true;
  bool get isActive => _isActive;

  List<ServiceScheduleModel> _schedules = [];
  List<ServiceScheduleModel> get schedules => _schedules;

  void _initSchedules() {
    _schedules = [
      ServiceScheduleModel(
        days: [
          'Saturday',
          'Sunday',
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday'
        ],
        startTime: "08:00",
        endTime: "22:00",
        isActive: true,
      )
    ];
  }

  // 🚀 تعبئة الحقول ببيانات الخدمة الحالية
  void _initData() {
    nameController.text = service.title;
    descriptionController.text = service.description;
    priceController.text = service.priceText.split(' ').first;
    partialPercentController.text = service.requiredPartialPercentage.toString();
    _distanceBasedPrice = service.distanceBasedPrice;
    pricePerKmController.text = service.pricePerKm.toString();
    _selectedCategoryId = service.categoryId;
    _isActive = service.isActive;

    if (service.schedules.isNotEmpty) {
      _schedules = List.from(service.schedules);
    }
  }

  void setDistanceBasedPrice(bool value) {
    _distanceBasedPrice = value;
    notifyListeners();
  }

  void setIsActive(bool value) {
    _isActive = value;
    notifyListeners();
  }


  void setCategory(int? id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    notifyListeners();
    try {
      _categories = await _repository.getMainCategories();
      _flattenedCategories.clear();
      
      for (var cat in _categories) {
        _flattenedCategories.add(cat);
        for (var sub in cat.children) {
          _flattenedCategories.add(CategoryModel(
            id: sub.id,
            name: '   — ${sub.name}',
          ));
        }
      }
      
      // تحقق: في حالة تعديل خدمة ليس لها تصنيف ضمن القائمة (مثلاً 0 للخدمات المخصصة)
      if (_selectedCategoryId != null && 
          !_flattenedCategories.any((c) => c.id == _selectedCategoryId)) {
        _selectedCategoryId = null;
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<bool> updateService(BuildContext context) async {
    if (nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        partialPercentController.text.trim().isEmpty ||
        _selectedCategoryId == null) {
      DialogHelper.showErrorDialog(context, 'يرجى تعبئة الحقول الأساسية');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateService(
        serviceId: service.id,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.parse(priceController.text.trim()),
        categoryId: _selectedCategoryId!,
        requiredPartialPercent: int.parse(partialPercentController.text.trim()),
        isActive: _isActive,
        distanceBasedPrice: _distanceBasedPrice,
        pricePerKm: _distanceBasedPrice ? double.tryParse(pricePerKmController.text.trim()) ?? 0.0 : 0.0,
        imageFile: _imageFile,
      );

      _isLoading = false;
      notifyListeners();
      return true; // نجاح التعديل
    } on Failure catch (failure) {
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ خطأ من السيرفر: ${failure.message}');
      DialogHelper.showErrorDialog(
        context,
        'البيانات المرسلة غير صحيحة ${failure.message}',
      );
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ خطأ برمجي في فلاتر: $e');
      DialogHelper.showErrorDialog(context, 'حدث خطأ أثناء التعديل');
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    partialPercentController.dispose();
    pricePerKmController.dispose();
    super.dispose();
  }
}
