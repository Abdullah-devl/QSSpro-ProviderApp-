import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../../notifications/repositories/notification_repository.dart';
import '../../../core/network/fcm_notification_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final NotificationRepository? _notificationRepository;

  AuthViewModel(this._authRepository, [this._notificationRepository]);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// تسجيل خروج المستخدم وحذف توكن الإشعارات
  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. حذف التوكن من السيرفر قبل تسجيل الخروج
      if (_notificationRepository != null) {
        String? token = await FCMNotificationService().getToken();
        if (token != null) {
          await _notificationRepository.removeToken(token);
        }
      }

      // 2. تسجيل الخروج من السيرفر وحذف التوكن المحلي
      await _authRepository.logout();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تخزين توكن الإشعارات (يتم استدعاؤه بعد تسجيل الدخول الناجح)
  Future<void> syncFCMToken() async {
    if (_notificationRepository == null) return;
    
    String? token = await FCMNotificationService().getToken();
    if (token != null) {
      await _notificationRepository.storeToken(token);
    }
  }
}
