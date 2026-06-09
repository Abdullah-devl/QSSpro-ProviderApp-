// مسار الملف: lib/core/utils/dialog_helper.dart

import 'package:flutter/material.dart';
import '../theme/qs_color_extension.dart';
import '../localization/app_localizations.dart';

class DialogHelper {
  // ❌ دالة عرض رسالة الخطأ (بتصميم عصري)
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        final colors = ctx.qsColors;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: colors.background,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.error_outline_rounded, color: Colors.red.shade600, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  context.tr('auto_tr_52'),
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textSub,
                    fontSize: 14,
                    height: 1.5,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(context.tr('auto_tr_40'),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🏆 دالة عرض رسالة النجاح (بتصميم جذاب جداً Premium)
  static Future<void> showSuccessDialog(BuildContext context, String message, {VoidCallback? onPressed}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final colors = ctx.qsColors;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: colors.background,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // أيقونة النجاح مع تدرج لوني خفيف
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
                ),
                const SizedBox(height: 24),
                Text(context.tr('auto_tr_36'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textSub,
                    fontSize: 15,
                    height: 1.5,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5CA4B8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      onPressed?.call();
                    },
                    child: Text(context.tr('auto_tr_40'),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ❓ دالة عرض حوار التأكيد (Confirmation Dialog)
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colors = ctx.qsColors;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: colors.background,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.help_outline_rounded,
                      color: Colors.blue.shade600, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textSub,
                    fontSize: 14,
                    height: 1.5,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(
                          cancelText ?? context.tr('auto_tr_51'),
                          style: TextStyle(
                            color: colors.textSub,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5CA4B8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text(
                          confirmText ?? context.tr('auto_tr_13'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }
}