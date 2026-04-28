// مسار الملف: lib/features/commissions/views/widgets/due_commission_card.dart

import 'package:flutter/material.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import '../../../../core/localization/app_localizations.dart';
import '../pay_commissions_view.dart';

class DueCommissionCard extends StatelessWidget {
  final double amount;

  const DueCommissionCard({
    super.key,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.qsColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.qsColors.text.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // القسم العلوي: النصوص والقيمة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة المحفظة (في البداية)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.qsColors.warning,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: context.qsColors.warning,
                  size: 26,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // التسمية والتنبيه الأحمر (في الوسط)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('due_commission'),
                      style: TextStyle(
                        color: context.qsColors.info, // لون أزرق غامق للعنوان
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('pay_to_avoid_suspension'),
                      style: TextStyle(
                        color: context.qsColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // القيمة والرصيد (في النهاية)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: context.qsColors.text,
                    ),
                  ),
                  Text(
                    context.tr('currency_sar'),
                    style: TextStyle(
                      color: context.qsColors.textSub,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // زر سداد الآن الأزرق الكبير
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PayCommissionsView(amount: amount),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1CB0F6),
                foregroundColor: context.qsColors.card,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.credit_card, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('pay_now'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr('pay_commission_subtitle'),
                    style: TextStyle(
                      fontSize: 10,
                      color: context.qsColors.card.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


