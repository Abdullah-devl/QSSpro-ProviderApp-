import 'package:flutter/material.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import '../../../../core/localization/app_localizations.dart';

class TotalDueCommissionCard extends StatelessWidget {
  final double amount;

  const TotalDueCommissionCard({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors.text.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // التسمية والأيقونة (في البداية)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:  Icon(
                  Icons.account_balance_wallet_rounded,
                  color: colors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.tr('total_due_commission'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
            ],
          ),

          // القيمة (في النهاية)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                context.tr('currency_sar'),
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textSub,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
