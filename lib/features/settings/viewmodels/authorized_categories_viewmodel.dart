import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import 'package:service_provider_app/core/network/error/failure.dart';
import 'package:service_provider_app/core/utils/dialog_helper.dart';
import '../../services/models/category_model.dart';
import '../repositories/settings_repository.dart';

class AuthorizedCategoriesViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepository;
  final ImagePicker _imagePicker = ImagePicker();

  AuthorizedCategoriesViewModel(this._settingsRepository) {
    fetchAuthorizedCategories();
    fetchAllCategories();
  }

  // Controllers
  final TextEditingController descriptionController = TextEditingController();

  // State Variables
  List<CategoryModel> _authorizedCategories = [];
  List<CategoryModel> get authorizedCategories => _authorizedCategories;

  List<CategoryModel> _allCategories = [];
  List<CategoryModel> get allCategories => _allCategories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitLoading = false;
  bool get isSubmitLoading => _isSubmitLoading;

  CategoryModel? _selectedCategory;
  CategoryModel? get selectedCategory => _selectedCategory;

  File? _documentFile;
  File? get documentFile => _documentFile;

  void setSelectedCategory(CategoryModel? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Pick Document image
  Future<void> pickDocument() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        _documentFile = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking document: $e');
    }
  }

  void removeDocument() {
    _documentFile = null;
    notifyListeners();
  }

  // Fetch authorized categories
  Future<void> fetchAuthorizedCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _authorizedCategories = await _settingsRepository.getMyAuthorizedCategories();
    } catch (e) {
      debugPrint('Error fetching authorized categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all categories for request dropdown
  Future<void> fetchAllCategories() async {
    try {
      _allCategories = await _settingsRepository.getAllCategories();
    } catch (e) {
      debugPrint('Error fetching all categories: $e');
    }
    notifyListeners();
  }

  // Submit request for new category
  Future<void> submitRequest(BuildContext context) async {
    final description = descriptionController.text.trim();

    if (_selectedCategory == null) {
      DialogHelper.showErrorDialog(context, context.tr('error_category_required'));
      return;
    }

    if (description.isEmpty) {
      DialogHelper.showErrorDialog(context, context.tr('validation_empty_fields'));
      return;
    }

    if (_documentFile == null) {
      DialogHelper.showErrorDialog(context, context.tr('error_id_card_required')); // using id_card required for document
      return;
    }

    _isSubmitLoading = true;
    notifyListeners();

    try {
      await _settingsRepository.submitCategoryRequest(
        categoryId: _selectedCategory!.id,
        description: description,
        document: _documentFile!,
      );

      _isSubmitLoading = false;
      descriptionController.clear();
      _selectedCategory = null;
      _documentFile = null;
      notifyListeners();

      // Show success dialog
      DialogHelper.showSuccessDialog(
        context,
        context.tr('complaint_sent_success'), // success message
        onPressed: () {
          Navigator.pop(context); // close bottom sheet/form
        },
      );
    } on Failure catch (failure) {
      _isSubmitLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, failure.message);
    } catch (e) {
      _isSubmitLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, context.tr('error_unexpected'));
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}
