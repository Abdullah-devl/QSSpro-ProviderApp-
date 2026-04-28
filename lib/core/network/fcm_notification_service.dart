import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:service_provider_app/core/network/navigation_service.dart';
import 'dart:developer' as developer;

/// معالج الإشعارات في الخلفية (يجب أن يكون خارج أي كلاس)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log("Handling a background message: ${message.messageId}", name: 'FCM_SERVICE');
}

class FCMNotificationService {
  static final FCMNotificationService _instance = FCMNotificationService._internal();
  factory FCMNotificationService() => _instance;
  FCMNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// تهيئة خدمة الإشعارات
  Future<void> initialize() async {
    // 1. طلب الصلاحيات (مهم للأندرويد 13+ و iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      developer.log('User granted permission', name: 'FCM_SERVICE');
    } else {
      developer.log('User declined or has not accepted permission', name: 'FCM_SERVICE');
    }

    // 2. إعداد قنوات الإشعارات (للأندرويد)
    await _createNotificationChannel();

    // 3. إعداد الإشعارات المحلية (للعرض والتطبيق مفتوح)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            Map<String, dynamic> data = jsonDecode(response.payload!);
            _handleNotificationClick(data);
          } catch (e) {
            developer.log("Error decoding notification payload: $e", name: 'FCM_SERVICE');
          }
        }
      },
    );

    // 4. معالجة الإشعارات والبرنامج في الواجهة (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log("Message received in foreground: ${message.notification?.title}", name: 'FCM_SERVICE');
      _showLocalNotification(message);
    });

    // 5. معالجة النقر على الإشعار والتطبيق في الخلفية (Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log("Notification clicked (Background): ${message.data}", name: 'FCM_SERVICE');
      _handleNotificationClick(message.data);
    });

    // 6. التحقق مما إذا تم فتح التطبيق من إشعار (بينما كان مغلقاً تماماً Terminated)
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      developer.log("App opened from terminated state by notification", name: 'FCM_SERVICE');
      _handleNotificationClick(initialMessage.data);
    }

    // 7. تعيين معالج الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 8. الاستماع لتحديث التوكن (Token Refresh)
    _fcm.onTokenRefresh.listen((newToken) {
      developer.log("FCM Token Refreshed: $newToken", name: 'FCM_SERVICE');
    });
  }

  /// إنشاء قناة إشعارات عالية الأهمية للأندرويد
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.', // description
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// الحصول على التوكن
  Future<String?> getToken() async {
    try {
      String? token = await _fcm.getToken();
      developer.log("FCM Token: $token", name: 'FCM_SERVICE');
      return token;
    } catch (e) {
      developer.log("Error getting token: $e", name: 'FCM_SERVICE');
      return null;
    }
  }

  /// استماع لتحديث التوكن
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  /// عرض إشعار محلي (عندما يكون التطبيق مفتوحاً)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'high_importance_channel', // id
        'High Importance Notifications', // name
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );
    }
  }

  /// إظهار نافذة منبثقة داخل التطبيق
  void _showInAppDialog(String title, String body, Map<String, dynamic> data) {
    BuildContext? context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إغلاق"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleNotificationClick(data);
              },
              child: const Text("عرض"),
            ),
          ],
        ),
      );
    }
  }

  /// التوجيه بناءً على نوع الإشعار
  void _handleNotificationClick(Map<String, dynamic> data) {
    String? type = data['type'];
    String? requestId = data['request_id']?.toString();

    developer.log("Handling click for type: $type, id: $requestId", name: 'FCM_SERVICE');

    if (type == null) return;

    switch (type) {
      case 'new_request':
      case 'request_accepted':
      case 'request_completed':
      case 'request_rejected':
      case 'req_msg':
        if (requestId != null) {
           // افترض وجود مسار لتفاصيل الطلب
           // navigatorKey.currentState?.pushNamed('/order_details', arguments: requestId);
           developer.log("Navigate to Request Details: $requestId", name: 'FCM_SERVICE');
        }
        break;
      case 'new_bond':
      case 'bond_status_updated':
        // navigatorKey.currentState?.pushNamed('/bonds');
        developer.log("Navigate to Bonds", name: 'FCM_SERVICE');
        break;
      case 'points_received':
        // navigatorKey.currentState?.pushNamed('/points');
        developer.log("Navigate to Points", name: 'FCM_SERVICE');
        break;
      case 'admin_message':
      case 'general':
        navigatorKey.currentState?.pushNamed('/notifications');
        developer.log("Navigate to Notifications History", name: 'FCM_SERVICE');
        break;
      case 'complaint_update':
        // navigatorKey.currentState?.pushNamed('/complaints');
        developer.log("Navigate to Complaints", name: 'FCM_SERVICE');
        break;
      default:
        navigatorKey.currentState?.pushNamed('/notifications');
    }
  }
}
