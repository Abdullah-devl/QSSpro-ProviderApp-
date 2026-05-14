// مسار الملف: lib/features/commissions/views/widgets/commissions_stats_banner.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/qs_color_extension.dart';
import '../../viewmodels/commissions_stats_viewmodel.dart';
class CommissionsStatsBanner extends StatelessWidget {
  const CommissionsStatsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final viewModel = context.watch<CommissionsStatsViewModel>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            // 💰 1. العمولة المستحقة
            _buildStatCard(
              context,
              title: context.tr('total_due_commission_label'),
              value: '${viewModel.statsSummary?.currentBalance.toInt() ?? 0}',
              unit: context.tr('currency_sar'),
              icon: Icons.account_balance_wallet_rounded,
              color: colors.primary,
            ),

            // 💵 2. أرباح قابلة للسحب
            _buildStatCard(
              context,
              title: context.tr('withdrawable_points'),
              value: '${viewModel.pointsBalance?.paidPoints.toInt() ?? 0}',
              unit: context.tr('pts'),
              icon: Icons.monetization_on_rounded,
              color: colors.success,
            ),

            // 🎁 3. نقاط المكافأة
            _buildStatCard(
              context,
              title: context.tr('bonus_points_wallet'),
              value: '${viewModel.pointsBalance?.bonusPoints.toInt() ?? 0}',
              unit: context.tr('pts'),
              icon: Icons.card_giftcard_rounded,
              color: colors.warning,
            ),

            // 📅 4. أيام التوثيق المتبقية
            _buildStatCard(
              context,
              title: context.tr('verification_remaining_days'),
              value: viewModel.isVerified 
                  ? '${viewModel.verificationDaysLeft}' 
                  : context.tr('not_verified'),
              unit: viewModel.isVerified ? context.tr('days_label') : '',
              icon: Icons.verified_user_rounded,
              color: viewModel.isVerified ? const Color(0xFF9C27B0) : colors.textSub,
              isDayCount: viewModel.isVerified,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    bool isDayCount = false,
  }) {
    final colors = context.qsColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.text.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              color: colors.textSub,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.topStart,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.textSub,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
