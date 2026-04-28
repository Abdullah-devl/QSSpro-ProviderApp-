// مسار الملف: lib/features/commissions/views/widgets/payment_method_option_widget.dart

import 'package:flutter/material.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';

class PaymentMethodOptionWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodOptionWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? context.qsColors.primary.withOpacity(0.1) : context.qsColors.card, // خلفية زرقاء خفيفة عند التحديد
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.qsColors.primary : context.qsColors.textSub,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: context.qsColors.text.withOpacity(0.01),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // زر الراديو الدائري (يسار)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? context.qsColors.primary : context.qsColors.textSub,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration:  BoxDecoration(
                          color: context.qsColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            // النصوص (العنوان والوصف) في الوسط، محاذاة لليمين
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.qsColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.qsColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // الأيقونة (يمين)
            Icon(
              iconData,
              color: iconColor,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}


