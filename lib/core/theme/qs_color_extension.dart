import 'package:flutter/material.dart';
import 'custm_color.dart';
import 'qs_colors.dart';

/// 📂 اسم الملف: qs_color_extension.dart
/// 📝 الوصف: يحتوي على Extension لـ `BuildContext`.
/// الهدف: تسهيل الوصول إلى الألوان المخصصة (QSColors) من أي مكان في التطبيق.
/// بدلاً من كتابة جمل شرطية طويلة في كل شاشة للتحقق من الثيم (فاتح/داكن)،
/// نستخدم `context.qsColors` مباشرة.

extension QSColorExt on BuildContext {
  /// 🎨 getter يعيد كائن QSColors المناسب للثيم الحالي.
  QSColors get qsColors {
    // التحقق مما إذا كان الثيم الحالي داكناً
    final isDark = Theme.of(this).brightness == Brightness.dark;

    // إرجاع الألوان بناءً على حالة الثيم
    return isDark
        ? const QSColors(
            text: CustomColor.darkText,
            textSub: CustomColor.darkTextSub,
            background: CustomColor.darkBackground,
            primary: CustomColor.darkPrimary,
            secondary: CustomColor.darkSecondary,
            accent: CustomColor.darkAccent,
            error: CustomColor.darkError,
            success: CustomColor.darkSuccess,
            warning: CustomColor.darkWarning,
            info: CustomColor.darkInfo,
            card: CustomColor.darkCard,
          )
        : const QSColors(
            text: CustomColor.lightText,
            textSub: CustomColor.lightTextSub,
            background: CustomColor.lightBackground,
            primary: CustomColor.lightPrimary,
            secondary: CustomColor.lightSecondary,
            accent: CustomColor.lightAccent,
            error: CustomColor.error,
            success: CustomColor.success,
            warning: CustomColor.amber,
            info: CustomColor.lightPrimary,
            card: CustomColor.lightCard,
          );
  }
}
