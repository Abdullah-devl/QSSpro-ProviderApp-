import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import 'dart:developer' as developer;

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationViewModel(this._repository);

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// عدد الإشعارات غير المقروءة
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// جلب الإشعارات من السيرفر
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications();
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'فشل جلب الإشعارات';
      _isLoading = false;
      developer.log('Error in fetchNotifications: $e', name: 'NotificationVM');
    }
    notifyListeners();
  }

  /// تعيين إشعار كمقروء
  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      
      // تحديث القائمة محلياً
      int index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          data: _notifications[index].data,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      developer.log('Error marking as read: $e', name: 'NotificationVM');
    }
  }

  /// تعيين الكل كمقروء
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      
      // تحديث كل الإشعارات محلياً
      _notifications = _notifications.map((n) {
        return NotificationModel(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          data: n.data,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      developer.log('Error marking all as read: $e', name: 'NotificationVM');
    }
  }

  /// إضافة إشعار جديد للقائمة (مفيد عند استلام إشعار والتطبيق مفتوح)
  void addNotificationLocally(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
}
