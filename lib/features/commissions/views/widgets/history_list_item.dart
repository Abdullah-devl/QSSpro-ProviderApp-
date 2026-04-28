// مسار الملف: lib/features/commissions/views/widgets/history_list_item.dart

import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/qs_color_extension.dart';
import 'package:service_provider_app/features/commissions/models/history_models.dart';

class HistoryListItem extends StatelessWidget {
  final BaseHistoryItem item;

  const HistoryListItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد الألوان والأيقونات بناءً على نوع العملية
    Color iconBgColor;
    Color iconColor;
    IconData iconData;

    switch (item.type) {
      case HistoryType.package:
        iconBgColor = const Color(0xFFE3F2FD);
        iconColor = const Color(0xFF1976D2);
        iconData = Icons.inventory_2_rounded;
        break;
      case HistoryType.point:
        iconBgColor = const Color(0xFFFFF3E0);
        iconColor = const Color(0xFFF57C00);
        iconData = Icons.stars_rounded;
        break;
      case HistoryType.withdrawal:
        iconBgColor = const Color(0xFFE8F5E9);
        iconColor = const Color(0xFF388E3C);
        iconData = Icons.account_balance_rounded;
        break;
      case HistoryType.bond:
        iconBgColor = const Color(0xFFF3E5F5);
        iconColor = const Color(0xFF7B1FA2);
        iconData = Icons.receipt_long_rounded;
        break;
      default:
        iconBgColor = const Color(0xFFF5F5F5);
        iconColor = const Color(0xFF757575);
        iconData = Icons.history_rounded;
    }

    // تحديد ألوان شارة الحالة
    Color badgeBgColor;
    Color badgeTextColor;
    String statusKey = item.status.toLowerCase().trim();

    if (statusKey == 'completed' || statusKey == 'success' || statusKey == 'active') {
      badgeBgColor = const Color(0xFFE8F5E9);
      badgeTextColor = const Color(0xFF388E3C);
    } else if (statusKey == 'accepted_partial_paid' || statusKey == 'accepted_full_paid' || statusKey == 'processing') {
      badgeBgColor = const Color(0xFFFFF3E0);
      badgeTextColor = const Color(0xFFE65100);
    } else if (statusKey == 'pending' || statusKey == 'accepted_initial' || statusKey == 'waiting') {
      badgeBgColor = const Color(0xFFE1F5FE);
      badgeTextColor = const Color(0xFF0288D1);
    } else if (statusKey == 'rejected' || statusKey == 'cancelled') {
      badgeBgColor = const Color(0xFFFFEBEE);
      badgeTextColor = const Color(0xFFC62828);
    } else {
      badgeBgColor = const Color(0xFFF5F5F5);
      badgeTextColor = const Color(0xFF757575);
    }

    String translatedStatus = context.tr('status_$statusKey');
    if (translatedStatus == 'status_$statusKey') {
      translatedStatus = context.tr(statusKey).isNotEmpty ? context.tr(statusKey) : item.status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.qsColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.qsColors.textSub.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: context.qsColors.text.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. أيقونة النوع
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),

          // 2. المحتوى النصي
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.qsColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.date,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.qsColors.textSub,
                  ),
                ),
              ],
            ),
          ),

          // 3. المبلغ والحالة (اليسار)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    item.amount > 0 ? item.amount.toStringAsFixed(0) : '0',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.qsColors.text,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    item.type == HistoryType.point ? context.tr('points') : context.tr('currency_sar'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: context.qsColors.textSub,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  translatedStatus,
                  style: TextStyle(
                    color: badgeTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
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
