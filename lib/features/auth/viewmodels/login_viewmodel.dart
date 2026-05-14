import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:service_provider_app/core/storage/hive_keys.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:service_provider_app/core/network/error/failure.dart';
import 'package:service_provider_app/features/home/views/main_view.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/features/profile/repositories/profile_repository.dart';
import 'package:service_provider_app/features/settings/views/privacy_policy_view.dart';
import 'package:service_provider_app/core/storage/hive_helper.dart';
import 'package:service_provider_app/core/network/fcm_notification_service.dart';
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
      // 0. مسح كل البيانات السابقة من الكاش لضمان تحديث كل شيء للمستخدم الجديد
      await HiveHelper.clareAllData();

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
        // 🔔 عرض حالة الـ FCM Token بعد الاستجابة من Firebase (ينتظر حتى يغلق المستخدم النافذة)
        await _showFCMTokenAlert(context);

        // التحقق من الموافقة على السياسة مباشرة من بيانات تسجيل الدخول
        final box = Hive.box(HiveKeys.settingsBox);
        await box.put('provider_policy_agreed', user.providerPolicy);

        if (user.providerPolicy) {
          // الانتقال للشاشة الرئيسية مع تنظيف مكدس التنقل
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainView()),
            (route) => false,
          );
        } else {
          // لم يوافق على السياسة -> نقله لصفحة سياسة الخصوصية
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const PrivacyPolicyView(requiresAcceptance: true)),
            (route) => false,
          );
        }
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

  /// 🔔 عرض نتيجة الـ FCM Token بعد تسجيل الدخول
  Future<void> _showFCMTokenAlert(BuildContext context) async {
    // الانتظار قليلاً ريثما تستجيب Firebase
    String? token;
    try {
      token = await FCMNotificationService().getToken();
    } catch (_) {
      token = null;
    }

    if (!context.mounted) return;

    final bool tokenReceived = token != null && token.isNotEmpty;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        title: Row(
          children: [
            Icon(
              tokenReceived ? Icons.check_circle_rounded : Icons.error_rounded,
              color: tokenReceived ? context.qsColors.success : context.qsColors.error,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                tokenReceived
                    ? 'تم الاتصال بـ Firebase'
                    : 'فشل الاتصال بـ Firebase',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: tokenReceived
                      ? context.qsColors.success
                      : context.qsColors.error,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          tokenReceived
              ? 'تم استلام رمز الإشعارات (FCM Token) من Firebase بنجاح.\n\nالرمز:\n${token!.substring(0, 20)}...'
              : 'لم يتم استلام رمز الإشعارات (FCM Token) من Firebase.\nتحقق من الاتصال بالإنترنت أو إعدادات Firebase.',
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: tokenReceived
                  ? context.qsColors.success.withOpacity(0.1)
                  : context.qsColors.error.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'حسناً',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: tokenReceived
                    ? context.qsColors.success
                    : context.qsColors.error,
              ),
            ),
          ),
        ],
      ),
    );
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

