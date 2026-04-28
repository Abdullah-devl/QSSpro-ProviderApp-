import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/qs_color_extension.dart';

// استيرادات المييزات
import '../packages/repositories/packages_repository.dart';
import '../packages/viewmodels/packages_viewmodel.dart';
import '../packages/views/verification_packages_view.dart';
import '../submit_verification/repositories/verification_repository.dart';
import '../submit_verification/viewmodels/verification_viewmodel.dart';
import '../submit_verification/views/new_verification_request_view.dart';

class VerificationOptionsDialog extends StatelessWidget {
  const VerificationOptionsDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const VerificationOptionsDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: colors.background,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🛡️ 1. الأيقونة العلوية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_user_rounded,
                color: colors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),

            // 🏷️ 2. العنوان الرئيسي
            Text(
              context.tr('verification_options_title'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.text,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 📄 3. الوصف المختصر
            Text(
              context.tr('verification_options_subtitle'),
              style: TextStyle(
                fontSize: 13,
                color: colors.textSub,
                height: 1.6,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 🔘 4. زر "طلب توثيق جديد" (يفتح شاشة إدخال المحتوى النصي)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (context) => VerificationViewModel(
                          VerificationRepository(context.read<ApiService>()),
                        ),
                        child: const NewVerificationRequestView(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.post_add_rounded, color: context.qsColors.card, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('new_verification_request'),
                      style: TextStyle(
                        color: context.qsColors.card,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 🔘 5. زر "تجديد التوثيق الحالي" (يفتح صفحة الباقات)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (context) => PackagesViewModel(
                          PackagesRepository(context.read<ApiService>()),
                        ),
                        child: const VerificationPackagesView(),
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, color: colors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('renew_current_verification'),
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ❌ 6. زر "إلغاء الأمر"
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.tr('cancel'),
                style: TextStyle(
                  color: colors.textSub,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


