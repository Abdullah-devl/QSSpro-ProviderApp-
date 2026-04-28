import 'package:flutter/material.dart';

/// 📂 اسم الملف: custm_color.dart
/// 📝 الوصف: يحتوي هذا الكلاس على الألوان الثابتة المستخدمة في التطبيق.
/// بدلاً من كتابة كود اللون (Hex Code) في كل مكان، نستخدم هذا الكلاس لتوحيد الألوان وتسهيل تغييرها مستقبلاً.

class CustomColor {
  // ⛔ منع إنشاء كائن من هذا الكلاس لأنه يحتوي فقط على ثوابت (static).
  CustomColor._();

  // ===========================================================================
  // ☀️ ألوان الثيم الفاتح (Light Mode Colors)
  // ===========================================================================

  /// لون النصوص الرئيسي في الوضع الفاتح (فحمي داكن).
  static const Color lightText = Color(0xFF2D3436);

  /// لون النصوص الفرعية أو الوصف (رمادي).
  static const Color lightTextSub = Color(0xFF636E72);

  /// لون الخلفية في الوضع الفاتح (أزرق سماوي ناعم).
  static const Color lightBackground = Color(0xFFF1FAFF);

  /// اللون الأساسي للتطبيق (أزرق حيوي).
  static const Color lightPrimary = Color(0xFF1CB0F6);

  /// اللون الثانوي (أزرق فاتح).
  static const Color lightSecondary = Color(0xFF74B9FF);

  /// لون التمييز (Accent Color).
  static const Color lightAccent = Color(0xFF1CB0F6);

  /// لون البطاقات في الوضع الفاتح.
  static const Color lightCard = Colors.white;

  // ===========================================================================
  // 🌙 ألوان الثيم الداكن (Dark Mode Colors)
  // ===========================================================================

  /// لون النصوص الرئيسي في الوضع الداكن (أبيض ناعم).
  static const Color darkText = Color(0xFFDFE6E9);

  /// لون النصوص الفرعية (رمادي فاتح).
  static const Color darkTextSub = Color(0xFFB2BEC3);

  /// لون الخلفية في الوضع الداكن (أسود عميق).
  static const Color darkBackground = Color(0xFF0A0E10);

  /// اللون الأساسي في الوضع الداكن (أزرق هادئ).
  static const Color darkPrimary = Color(0xFF189AD3);

  /// لون النصوص الفرعية (رمادي فاتح).
  static const Color darkSecondary = Color(0xFF0984E3);

  /// لون التمييز في الوضع الداكن.
  static const Color darkAccent = Color(0xFF189AD3);

  /// لون البطاقات في الوضع الداكن.
  static const Color darkCard = Color(0xFF1A1D1E);

  // ===========================================================================
  // 🛠️ ألوان الوظائف (Functional Colors - ثابتة في كل الأوضاع)
  // ===========================================================================

  /// البرتقالي: للتحذيرات والتنبيهات.
  static const Color amber = Color(0xFFFFA502);

  /// الأخضر: للنجاح والعمليات المكتملة.
  static const Color success = Color(0xFF2ECC71);

  /// الأحمر: للأخطاء والرفض.
  static const Color error = Color(0xFFFF4757);

  // ألوان الحالات للوضع الداكن (بدرجات أقل حدة)
  static const Color darkSuccess = Color(0xFF27AE60);
  static const Color darkWarning = Color(0xFFE67E22);
  static const Color darkError = Color(0xFFD63031);
  static const Color darkInfo = Color(0xFF189AD3);
}
