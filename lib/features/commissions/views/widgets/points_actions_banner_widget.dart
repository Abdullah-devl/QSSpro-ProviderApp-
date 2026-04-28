// مسار الملف: lib/features/commissions/views/widgets/points_actions_banner_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/qs_color_extension.dart';
import 'package:service_provider_app/features/commissions/viewmodels/commissions_stats_viewmodel.dart';
import 'package:service_provider_app/features/withdraw/views/withdraw_view.dart';
import 'package:service_provider_app/features/points/views/convert_points_view.dart';

class PointsActionsBannerWidget extends StatelessWidget {
  const PointsActionsBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final statsViewModel = context.watch<CommissionsStatsViewModel>();
    final int availableToWithdraw = statsViewModel.pointsBalance?.paidPoints.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.text.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.swap_horizontal_circle_outlined,
                  color: colors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('points_actions_title'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('points_actions_subtitle'),
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSub,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // 📲 زر تحويل النقاط (بارز أكثر - جهة اليمين)
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConvertPointsView(
                          availablePaidPoints: statsViewModel.pointsBalance?.paidPoints ?? 0,
                          currentBonusPoints: statsViewModel.pointsBalance?.bonusPoints ?? 0,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.card,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    context.tr('transfer_points'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 💸 زر سحب النقاط (أقل بروزاً - جهة اليسار)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WithdrawView(availablePoints: availableToWithdraw),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    context.tr('withdraw_points'),
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
