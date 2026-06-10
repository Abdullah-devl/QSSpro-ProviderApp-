import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import 'package:service_provider_app/core/network/error/failure.dart';
import 'package:service_provider_app/core/network/fcm_notification_service.dart';
import 'package:service_provider_app/core/utils/dialog_helper.dart';
import '../../services/models/category_model.dart';
import '../repositories/auth_repository.dart';
import '../views/email_verification_view.dart';
import '../views/login_view.dart';
import 'package:provider/provider.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ImagePicker _imagePicker = ImagePicker();

  RegisterViewModel(this._authRepository) {
    loadCategories();
  }

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController requestContentController = TextEditingController();

  // State variables
  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  bool _isCategoriesLoading = false;
  bool get isCategoriesLoading => _isCategoriesLoading;

  String? _categoriesError;
  String? get categoriesError => _categoriesError;

  CategoryModel? _selectedCategory;
  CategoryModel? get selectedCategory => _selectedCategory;

  File? _idCardImage;
  File? get idCardImage => _idCardImage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isObscurePassword = true;
  bool get isObscurePassword => _isObscurePassword;

  bool _isObscureConfirmPassword = true;
  bool get isObscureConfirmPassword => _isObscureConfirmPassword;

  void togglePasswordVisibility() {
    _isObscurePassword = !_isObscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isObscureConfirmPassword = !_isObscureConfirmPassword;
    notifyListeners();
  }

  void setSelectedCategory(CategoryModel? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Pick ID Card Image
  Future<void> pickIdCardImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        _idCardImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // Remove picked image
  void removeIdCardImage() {
    _idCardImage = null;
    notifyListeners();
  }

  // Load categories from API
  Future<void> loadCategories() async {
    _isCategoriesLoading = true;
    _categoriesError = null;
    notifyListeners();

    try {
      _categories = await _authRepository.getCategories();
      _isCategoriesLoading = false;
    } catch (e) {
      _isCategoriesLoading = false;
      _categoriesError = e.toString();
      debugPrint('Error loading categories in RegisterViewModel: $e');
    }
    notifyListeners();
  }

  // Submit registration
  Future<void> register(BuildContext context) async {
    // 1. Validation checks
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final passwordConfirm = passwordConfirmController.text.trim();
    final location = locationController.text.trim();
    final requestContent = requestContentController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        passwordConfirm.isEmpty ||
        location.isEmpty ||
        requestContent.isEmpty) {
      DialogHelper.showErrorDialog(context, context.tr('error_fill_all_fields'));
      return;
    }

    if (password != passwordConfirm) {
      DialogHelper.showErrorDialog(context, context.tr('error_password_match'));
      return;
    }

    if (_selectedCategory == null) {
      DialogHelper.showErrorDialog(context, context.tr('error_category_required'));
      return;
    }

    if (_idCardImage == null) {
      DialogHelper.showErrorDialog(context, context.tr('error_id_card_required'));
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Get FCM token if available
      String? fcmToken;
      try {
        fcmToken = await FCMNotificationService().getToken();
      } catch (e) {
        debugPrint('FCM Token get error: $e');
      }

      final user = await _authRepository.registerProvider(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirm,
        categoryId: _selectedCategory!.id,
        location: location,
        requestContent: requestContent,
        idCard: _idCardImage!,
        fcmToken: fcmToken,
        deviceToken: fcmToken,
      );

      if (user.isVerified) {
        _isLoading = false;
        notifyListeners();

        if (!context.mounted) return;
        DialogHelper.showSuccessDialog(
          context,
          context.tr('verification_success_msg'),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginView()),
              (route) => false,
            );
          },
        );
      } else {
        try {
          await _authRepository.resendVerificationCode(email);
        } catch (e) {
          debugPrint('Failed to send verification code automatically on registration: $e');
        }

        _isLoading = false;
        notifyListeners();

        if (!context.mounted) return;
        DialogHelper.showSuccessDialog(
          context,
          context.tr('email_verification_subtitle'),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (ctx) => ChangeNotifierProvider(
                  create: (_) => RegisterViewModel(_authRepository),
                  child: EmailVerificationView(email: email),
                ),
              ),
              (route) => false,
            );
          },
        );
      }
    } on Failure catch (failure) {
      _isLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, failure.message);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, context.tr('error_unexpected'));
    }
  }

  // Verify Email OTP
  Future<bool> verifyOtp(BuildContext context, String email, String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.verifyEmail(email, code);
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
      DialogHelper.showErrorDialog(context, context.tr('error_unexpected'));
      return false;
    }
  }

  // Resend Email OTP
  Future<bool> resendOtp(BuildContext context, String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.resendVerificationCode(email);
      _isLoading = false;
      notifyListeners();
      DialogHelper.showSuccessDialog(context, context.tr('auto_tr_36'));
      return true;
    } on Failure catch (failure) {
      _isLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, failure.message);
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, context.tr('error_unexpected'));
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    locationController.dispose();
    requestContentController.dispose();
    super.dispose();
  }
}
