// مسار الملف: lib/features/commissions/views/widgets/reward_points_card.dart

import 'package:flutter/material.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import '../../../../core/localization/app_localizations.dart';

class RewardPointsCard extends StatelessWidget {
  final int pointsBalance;

  const RewardPointsCard({
    super.key,
    this.pointsBalance = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.textSub.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colors.text.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // التسمية والأيقونة (في البداية)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.warning.withValues(alpha: 0.2)),
                    ),
                    child:  Icon(
                      Icons.stars_rounded,
                      color: colors.warning,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.tr('reward_points'),
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // الرصيد (في النهاية)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    pointsBalance.toString(),
                    style:  TextStyle(
                      color: colors.warning,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.tr('points'),
                    style:  TextStyle(
                      color: colors.warning,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // النص التوضيحي بالأسفل
          Text(
            context.tr('redeem_points_subtitle'),
            style: TextStyle(
              color: colors.textSub,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
