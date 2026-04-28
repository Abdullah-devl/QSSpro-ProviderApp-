// مسار الملف: lib/features/commissions/views/widgets/verification_banner_widget.dart

import 'package:flutter/material.dart';
import 'package:service_provider_app/features/verification/widgets/verification_options_dialog.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/qs_color_extension.dart';

class VerificationBannerWidget extends StatelessWidget {
  const VerificationBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر "وثق الآن" (يسار)
          ElevatedButton(
            onPressed: () => VerificationOptionsDialog.show(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.card,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              context.tr('verify_now'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(width: 12),

          // النصوص (الوسط)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  context.tr('verify_account_banner_title'),
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('verify_account_banner_subtitle'),
                  style: TextStyle(color: colors.textSub, fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // الأيقونة الدائرية (يمين)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: colors.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
