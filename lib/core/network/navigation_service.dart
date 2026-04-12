import 'package:flutter/material.dart';

/// 🌍 مفتاح التنقل العالمي
/// يسمح لنا بالتنقل بين الصفحات من أي مكان في الكود (مثل ApiService) بدون الحاجة لـ BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
