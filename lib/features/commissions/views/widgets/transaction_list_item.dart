// مسار الملف: lib/features/commissions/views/widgets/transaction_list_item.dart

import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../models/commission_model.dart';

class TransactionListItem extends StatelessWidget {
  final CommissionTransactionModel transaction;

  const TransactionListItem({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد الألوان والأيقونات بناءً على حالة العملية
    Color iconBgColor;
    Color iconColor;
    IconData iconData;
    Color badgeBgColor;
    Color badgeTextColor;

    String normalizedStatus = transaction.status.trim().toLowerCase();
    String translatedStatus;

    switch (normalizedStatus) {
      case 'completed':
        iconBgColor = const Color(0xFFE8F5E9);
        iconColor = const Color(0xFF388E3C);
        iconData = Icons.done_all_rounded;
        badgeBgColor = const Color(0xFFE8F5E9);
        badgeTextColor = const Color(0xFF388E3C);
        translatedStatus = context.tr('status_completed');
        break;
      case 'pending':
      case 'accepted_initial':
        iconBgColor = const Color(0xFFE0F7FA);
        iconColor = const Color(0xFF00BCD4);
        iconData = Icons.new_releases_rounded;
        badgeBgColor = const Color(0xFFE0F7FA);
        badgeTextColor = const Color(0xFF0097A7);
        translatedStatus = context.tr('status_$normalizedStatus');
        break;
      case 'accepted_partial_paid':
      case 'accepted_full_paid':
      case 'processing':
        iconBgColor = const Color(0xFFFFF3E0);
        iconColor = const Color(0xFFF57C00);
        iconData = Icons.engineering_rounded;
        badgeBgColor = const Color(0xFFFFF3E0);
        badgeTextColor = const Color(0xFFE65100);
        translatedStatus = context.tr('status_$normalizedStatus');
        break;
      case 'rejected':
      case 'cancelled':
        iconBgColor = const Color(0xFFFFEBEE);
        iconColor = const Color(0xFFD32F2F);
        iconData = Icons.cancel_rounded;
        badgeBgColor = const Color(0xFFFFEBEE);
        badgeTextColor = const Color(0xFFC62828);
        translatedStatus = context.tr('status_$normalizedStatus');
        break;
      case 'archived':
        iconBgColor = const Color(0xFFF5F5F5);
        iconColor = const Color(0xFF9E9E9E);
        iconData = Icons.history_rounded;
        badgeBgColor = const Color(0xFFF5F5F5);
        badgeTextColor = const Color(0xFF757575);
        translatedStatus = context.tr('status_archived');
        break;
      default:
        iconBgColor = const Color(0xFFF5F5F5);
        iconColor = const Color(0xFF9E9E9E);
        iconData = Icons.info_outline_rounded;
        badgeBgColor = const Color(0xFFF5F5F5);
        badgeTextColor = const Color(0xFF757575);
        translatedStatus = context.tr('status_$normalizedStatus');
        if (translatedStatus == 'status_$normalizedStatus') {
           translatedStatus = transaction.status;
        }
        break;
    }

    // لغة الواجهة العربية، لذلك سنضع الأيقونة على اليمين والنصوص في الوسط والسعر على اليسار
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. الأيقونة الملونة (يمين)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          
          const SizedBox(width: 16),
          
          // 2. تفاصيل العملية (العنوان، المعرف، التاريخ)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      transaction.id,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (transaction.date.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.circle, size: 4, color: Colors.grey.shade400),
                      const SizedBox(width: 6),
                      Text(
                        transaction.date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 3. السعر وحالة العملية (أقصى اليسار)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end, // نعكس المحاذاة حسب اللغة
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transaction.amount.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.tr('currency_sar'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // شارة الحالة الصغيرة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(12),
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
