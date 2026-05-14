// مسار الملف: lib/features/profile/viewmodels/profile_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:service_provider_app/core/network/navigation_service.dart';
import 'package:service_provider_app/features/settings/views/privacy_policy_view.dart';
import '../models/work_model.dart';
import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository repository;

  ProfileViewModel(this.repository) {
    fetchProfile(); // جلب البيانات عند التهيئة
  }

  bool isLoading = false;
  String? errorMessage;
  ProfileModel? profile;
  List<WorkModel> works = [];

  bool _hasFetchedOnce = false;

  // جلب بيانات الملف الشخصي (Cache-Then-Network)
  Future<void> fetchProfile() async {
    // 1. 📥 جلب البيانات من الكاش المحلي فوراً وعرضها للمستخدم بدون أي تأخير
    final cachedProfile = repository.getCachedProfile();
    final cachedWorks = repository.getCachedPreviousWorks();
    
    if (cachedProfile != null) {
      profile = cachedProfile;
      debugPrint('⚡ ProfileViewModel: Loaded profile instantly from local Hive cache.');
    }
    if (cachedWorks.isNotEmpty) {
      works = cachedWorks;
      debugPrint('⚡ ProfileViewModel: Loaded ${works.length} works instantly from local Hive cache.');
    }
    
    // إشعار الواجهة بالبيانات المحلية فوراً
    if (profile != null || works.isNotEmpty) {
      notifyListeners();
    }

    // 2. ⚡ تفعيل الشيمر في المرة الأولى فقط خلال جلسة التطبيق الحالية
    if (!_hasFetchedOnce) {
      isLoading = true;
      _hasFetchedOnce = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      profile = await repository.getMyProfile();
      errorMessage = null;

      // 🛡️ المراقبة الدائمة للسياسة: في أي وقت نكتشف أن الموافقة أصبحت false
      if (profile != null && !profile!.providerPolicy) {
        // نستخدم navigatorKey للانتقال الفوري من أي مكان في التطبيق
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const PrivacyPolicyView(requiresAcceptance: true),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('❌ ProfileViewModel fetchProfile error: $e');
      if (profile == null) {
        errorMessage = e.toString();
      }
    }

    try {
      works = await repository.getPreviousWorks(); // 🚀 جلب الأعمال السابقة بشكل منضبط
    } catch (e) {
      debugPrint('❌ ProfileViewModel fetchWorks error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // دالة مساعدة للتحقق مما إذا كان المزود موثقاً حالياً
  bool get isCurrentlyVerified {
    if (profile == null) return false;
    if (!profile!.verificationProvider) return false;
    if (profile!.providerVerifiedUntil == null) return false;
    
    return profile!.providerVerifiedUntil!.isAfter(DateTime.now());
  }

  // حساب إجمالي النقاط (المدفوعة + المكافأة)
  double get totalPoints => (profile?.bonusPoints ?? 0) + (profile?.paidPoints ?? 0);
}