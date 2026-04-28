// import 'package:dio/dio.dart';
import 'package:service_provider_app/core/network/api_client.dart';
import 'package:service_provider_app/core/network/api_endpoints.dart';
import '../models/notification_model.dart';
import 'dart:developer' as developer;

class NotificationRepository {
  final ApiService _apiService;

  NotificationRepository(this._apiService);

  /// جلب قائمة الإشعارات
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiService.get(ApiEndpoints.notifications);
      if (response.data != null && response.data is List) {
        return (response.data as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      developer.log('Error fetching notifications: $e', name: 'NotificationRepo');
      rethrow;
    }
  }

  /// تعيين إشعار كمقروء
  Future<void> markAsRead(String id) async {
    try {
      await _apiService.post(ApiEndpoints.markNotificationAsRead(id));
    } catch (e) {
      developer.log('Error marking notification as read: $e', name: 'NotificationRepo');
      rethrow;
    }
  }

  /// تعيين كل الإشعارات كمقروءة
  Future<void> markAllAsRead() async {
    try {
      await _apiService.post(ApiEndpoints.markAllNotificationsAsRead);
    } catch (e) {
      developer.log('Error marking all notifications as read: $e', name: 'NotificationRepo');
      rethrow;
    }
  }

  /// تخزين توكن الجهاز في السيرفر
  Future<void> storeToken(String token) async {
    try {
      await _apiService.post(
        ApiEndpoints.storeToken,
        data: {'token': token},
      );
      developer.log('FCM Token stored successfully on server', name: 'NotificationRepo');
    } catch (e) {
      developer.log('Error storing FCM token: $e', name: 'NotificationRepo');
      // لا نرمي الخطأ هنا لكي لا يتوقف التطبيق إذا فشل تسجيل التوكن
    }
  }

  /// إزالة توكن الجهاز عند تسجيل الخروج
  Future<void> removeToken(String token) async {
    try {
      await _apiService.post(
        ApiEndpoints.removeToken,
        data: {'token': token},
      );
      developer.log('FCM Token removed from server', name: 'NotificationRepo');
    } catch (e) {
      developer.log('Error removing FCM token: $e', name: 'NotificationRepo');
    }
  }
}
