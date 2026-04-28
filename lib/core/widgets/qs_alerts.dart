import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/qs_color_extension.dart';

/// 📂 اسم الملف: qs_alerts.dart
/// 📝 الوصف: كلاس مخصص لعرض التنبيهات (Alerts) بتصميم Glassmorphism (زجاجي) فخم.
/// يدعم النجاح، الخطأ، التحذير، والمعلومات.

class QSAlerts {
  QSAlerts._();

  /// عرض تنبيه نجاح (Success)
  static void showSuccess(BuildContext context, String message) {
    _showCustomAlert(
      context: context,
      message: message,
      title: 'نجاح العملية',
      icon: Icons.check_circle_rounded,
      color: context.qsColors.success,
    );
  }

  /// عرض تنبيه خطأ (Error)
  static void showError(BuildContext context, String message) {
    _showCustomAlert(
      context: context,
      message: message,
      title: 'خطأ',
      icon: Icons.error_rounded,
      color: context.qsColors.error,
    );
  }

  /// عرض تنبيه تحذير (Warning)
  static void showWarning(BuildContext context, String message) {
    _showCustomAlert(
      context: context,
      message: message,
      title: 'تنبيه',
      icon: Icons.warning_rounded,
      color: context.qsColors.warning,
    );
  }

  /// عرض تنبيه معلومات (Info)
  static void showInfo(BuildContext context, String message) {
    _showCustomAlert(
      context: context,
      message: message,
      title: 'معلومات',
      icon: Icons.info_rounded,
      color: context.qsColors.info,
    );
  }

  /// الدالة الأساسية لبناء التنبيه المخصص بتصميم Glassmorphism
  static void _showCustomAlert({
    required BuildContext context,
    required String message,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.1),
      builder: (ctx) {
        final colors = ctx.qsColors;
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.background.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // أيقونة التنبيه
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 45),
                        ),
                        const SizedBox(height: 20),
                        // العنوان
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 12),
                        // الرسالة
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: colors.textSub,
                            fontFamily: 'Cairo',
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 30),
                        // زر الإغلاق
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              'فهمت',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
