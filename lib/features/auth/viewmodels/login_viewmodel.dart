import 'package:flutter/material.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:service_provider_app/core/network/error/failure.dart';
import 'package:service_provider_app/features/home/views/main_view.dart';
import 'package:provider/provider.dart';
import '../repositories/auth_repository.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isObscure = true;
  bool get isObscure => _isObscure;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void togglePasswordVisibility() {
    _isObscure = !_isObscure;
    notifyListeners();
  }

  // الدالة الفعليّة لتسجيل الدخول
  // الدالة الفعليّة لتسجيل الدخول
  Future<void> login(BuildContext context) async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showAlert(
        context,
        'يرجى إدخال البريد الإلكتروني وكلمة المرور.',
        isError: true,
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1. استدعاء الـ Repository واستلام كائن المستخدم
      final user = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      _isLoading = false;
      notifyListeners();

      // 2. 🛡️ تطبيق شرط التحقق (Middleware / Guard)
      if (user.isVerified) {
        // ✅ تحديث توكن الإشعارات فور تسجيل الدخول لضمان وصولها
        _syncFCMToken(context);

        // إذا كان حسابه موثقاً / موافقاً على الشروط -> يدخل التطبيق
        _showAlert(context, 'تم تسجيل الدخول بنجاح!', isError: false);

        // الانتقال للشاشة الرئيسية
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainView()));
      } else {
        // إذا لم يكن موثقاً -> نمنعه من الدخول للرئيسية وننقله لشاشة التوثيق أو الشروط
        _showAlert(
          context,
          'يرجى توثيق حسابك أو الموافقة على الشروط أولاً.',
          isError: true,
        );

        // الانتقال لشاشة التوثيق (سنبنيها لاحقاً)
        // Navigator.push(context, MaterialPageRoute(builder: (_) => const VerificationView()));
      }
    } on Failure catch (failure) {
      _isLoading = false;
      notifyListeners();
      _showAlert(context, failure.message, isError: true);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      _showAlert(context, 'حدث خطأ غير متوقع.', isError: true);
    }
  }

  // دالة مساعدة لمزامنة التوكن
  void _syncFCMToken(BuildContext context) {
    try {
      context.read<AuthViewModel>().syncFCMToken();
    } catch (e) {
      // نجهل الخطأ هنا لكي لا يعطل عملية تسجيل الدخول
    }
  }

  // دالة مساعدة لعرض الرسائل للمستخدم (SnackBar)
  // void _showSnackBar(BuildContext context, String message, {required bool isError}) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
  //       backgroundColor: isError ? context.qsColors.error : context.qsColors.success,
  //       behavior: SnackBarBehavior.floating,
  //     ),
  //   );
  // دالة مساعدة لعرض نافذة منبثقة (Alert Dialog) بدلاً من الـ SnackBar
  void _showAlert(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // يمنع إغلاق النافذة عند الضغط خارجها (يجب الضغط على حسناً)
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // حواف دائرية أنيقة
          ),
          title: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: isError ? context.qsColors.error : context.qsColors.success,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                isError ? 'تنبيه' : 'نجاح',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: isError ? context.qsColors.error : context.qsColors.success,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                backgroundColor: isError
                    ? context.qsColors.error.withOpacity(0.1)
                    : context.qsColors.success.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(), // إغلاق النافذة
              child: Text(
                'حسناً',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: isError ? context.qsColors.error : context.qsColors.success,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

