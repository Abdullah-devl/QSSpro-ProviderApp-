import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:service_provider_app/features/home/viewmodels/main_viewmodel.dart';
import '../repositories/settings_repository.dart';

class PolicyViewModel extends ChangeNotifier {
  final SettingsRepository repository;

  PolicyViewModel(this.repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _policyText;
  String? get policyText => _policyText;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProviderPolicy() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _policyText = await repository.getProviderPolicy();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> agreeToPolicy(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.acceptProviderPolicy();
      
      // ✅ تحديث فوري لبيانات التطبيق لكي لا يضطر المستخدم لتسجيل الخروج
      if (context.mounted) {
        try {
          // 1. تحديث بيانات البروفايل (سوف يقوم بتحديث Hive وإبلاغ الواجهات)
          await context.read<ProfileViewModel>().fetchProfile();
          
          // 2. تحديث بيانات الصفحة الرئيسية (الطلبات، الإحصائيات، الإعلانات)
          // نستخدم try-catch تحسباً لو لم يكن الـ HomeViewModel موجوداً في الـ context حالياً
          try {
            await context.read<HomeViewModel>().fetchHomeData();
          } catch (_) {}
          
        } catch (e) {
          debugPrint('Failed to refresh data after policy agreement: $e');
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
