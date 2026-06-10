import 'dart:developer' as developer;
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
import 'package:google_sign_in/google_sign_in.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import '../repositories/auth_repository.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/register_viewmodel.dart';
import '../views/email_verification_view.dart';
import 'package:service_provider_app/core/utils/dialog_helper.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

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
        context.tr('error_enter_email_password'),
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

      // 🛑 التحقق من نوع الحساب (يجب أن يكون مزود خدمة)
      if (user.role.toLowerCase() == 'seeker') {
        await HiveHelper.clareAllData(); // مسح التوكن الذي تم حفظه في الريبوزيتوري
        _isLoading = false;
        notifyListeners();
        _showAlert(
          context,
          context.tr('error_provider_app_only'),
          isError: true,
        );
        return;
      }

      // 2. 🛡️ تطبيق شرط التحقق (Middleware / Guard)
      if (user.isVerified) {
        _isLoading = false;
        notifyListeners();

        // التحقق من الموافقة على السياسة مباشرة من بيانات تسجيل الدخول
        final box = Hive.box(HiveKeys.settingsBox);
        await box.put('provider_policy_agreed', user.providerPolicy);

        if (user.providerPolicy) {
          // ✅ تحديث توكن الإشعارات فور تسجيل الدخول لضمان وصولها
          _syncFCMToken(context);

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
        // إذا لم يكن موثقاً -> نرسل الكود أولاً ثم نوجهه لصفحة التحقق
        try {
          await _authRepository.resendVerificationCode(emailController.text.trim());
        } catch (e) {
          debugPrint('Failed to send verification code automatically on login: $e');
        }

        _isLoading = false;
        notifyListeners();

        _showAlert(
          context,
          context.tr('email_verification_subtitle'),
          isError: false,
        );

        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => RegisterViewModel(_authRepository),
              child: EmailVerificationView(email: emailController.text.trim()),
            ),
          ),
        );
      }
    } on Failure catch (failure) {
      _isLoading = false;
      notifyListeners();
      _showAlert(context, failure.message, isError: true);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      _showAlert(context, context.tr('error_unexpected'), isError: true);
    }
  }

  // 🚀 دالة تسجيل الدخول بجوجل
  Future<void> loginWithGoogle(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 0. تهيئة GoogleSignIn مع الصلاحيات المطلوبة (مطلوب في v7)
      if (!_googleSignInInitialized) {
        const String serverClientId =
            '507923305565-n1mpoiimku862uvp56fh5smgka9v7te1.apps.googleusercontent.com';
        
        await _googleSignIn.initialize(
          serverClientId: serverClientId,
        );
        _googleSignInInitialized = true;
      }

      // 1. بدء عملية تسجيل الدخول بجوجل مع طلب الصلاحيات المطلوبة
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: [
          'email',
          'https://www.googleapis.com/auth/userinfo.profile',
          'openid',
        ],
      );

      // 2. الحصول على التوكن (الطريقة الجديدة في v7 للحصول على Access Token)
      final List<String> scopes = [
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
        'openid',
      ];
      
      // طلب الهيدرز التي تحتوي على التوكن
      final Map<String, String>? authHeaders = await googleUser.authorizationClient.authorizationHeaders(
        scopes,
        promptIfNecessary: true,
      );

      // استخراج الـ Access Token من الهيدر (يكون بعد كلمة Bearer)
      final String? authHeader = authHeaders?['Authorization'];
      final String? accessToken = authHeader?.replaceAll('Bearer ', '');
      
      developer.log('🎫 Access Token obtained via Client: ${accessToken?.substring(0, 10)}...', name: 'GOOGLE_AUTH');

      if (accessToken == null) {
        throw Failure(context.tr('error_google_token_failed'));
      }

      // 3. إرسال التوكن للسيرفر الخاص بنا
      await HiveHelper.clareAllData();
      final user = await _authRepository.loginWithGoogle(accessToken);

      // 🛑 التحقق من نوع الحساب (يجب أن يكون مزود خدمة)
      if (user.role.toLowerCase() == 'seeker') {
        await HiveHelper.clareAllData();
        _isLoading = false;
        notifyListeners();
        _showAlert(
          context,
          context.tr('error_google_seeker_account'),
          isError: true,
        );
        await _googleSignIn.signOut();
        return;
      }

      // 4. تطبيق منطق التوجيه (نفس منطق الـ Login العادي)
      if (user.isVerified) {
        final box = Hive.box(HiveKeys.settingsBox);
        await box.put('provider_policy_agreed', user.providerPolicy);

        if (user.providerPolicy) {
          _syncFCMToken(context);
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainView()),
            (route) => false,
          );
        } else {
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const PrivacyPolicyView(requiresAcceptance: true)),
            (route) => false,
          );
        }
      } else {
        try {
          await _authRepository.resendVerificationCode(user.email);
        } catch (e) {
          debugPrint('Failed to send verification code automatically on google login: $e');
        }

        _showAlert(context, context.tr('email_verification_subtitle'), isError: false);

        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => RegisterViewModel(_authRepository),
              child: EmailVerificationView(email: user.email),
            ),
          ),
        );
      }
    } on Failure catch (failure) {
      _showAlert(context, failure.message, isError: true);
    } catch (e) {
      debugPrint('❌ Google Login Error: $e');
      _showAlert(context, context.tr('error_google_login_failed'), isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
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
  // دالة مساعدة لعرض نافذة منبثقة (Alert Dialog) عبر DialogHelper بدلاً من الـ SnackBar
  void _showAlert(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    if (isError) {
      DialogHelper.showErrorDialog(context, message);
    } else {
      DialogHelper.showSuccessDialog(context, message);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

