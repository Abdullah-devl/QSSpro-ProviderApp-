// مسار الملف: lib/features/commissions/views/widgets/history_list_item.dart

import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/qs_color_extension.dart';
import 'package:service_provider_app/features/commissions/models/history_models.dart';
import '../../../../core/network/api_endpoints.dart';

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
      case HistoryType.commission:
        iconBgColor = const Color(0xFFFFEBEE);
        iconColor = const Color(0xFFD32F2F);
        iconData = Icons.payment_rounded;
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

    if (statusKey == 'completed' || statusKey == 'success' || statusKey == 'active' || statusKey == 'approved') {
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showDetailsDialog(context, iconColor, iconBgColor, iconData, translatedStatus, badgeBgColor, badgeTextColor),
        child: Container(
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
                      _getLocalizedTitle(context, item.title),
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
                        item.amount.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: item.amount < 0 ? Colors.red : context.qsColors.text,
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
        ),
      ),
    );
  }

  void _showDetailsDialog(
    BuildContext context,
    Color iconColor,
    Color iconBgColor,
    IconData iconData,
    String translatedStatus,
    Color badgeBgColor,
    Color badgeTextColor,
  ) {
    final colors = context.qsColors;
    final Map<String, dynamic> raw = item.rawJson;

    // استخراج الحقول المهمة بشكل عام من البيانات
    String? bondImage = raw['bond_image']?.toString() ?? raw['image_path']?.toString();
    String? bondNumber = raw['bond_number']?.toString();
    String? bankName = raw['bank_name']?.toString();
    String? adminNote = raw['admin_note']?.toString();
    String? packageDetails;
    String? requestDetails;

    if (item.type == HistoryType.package) {
      if (raw['package'] is Map) {
        final p = raw['package'];
        packageDetails = '${p['name'] ?? ''} (${p['points'] ?? 0} ${context.tr('points')})';
      }
    } else if (item.type == HistoryType.bond) {
      if (raw['request'] is Map) {
        final r = raw['request'];
        requestDetails = '${context.tr('request_number_label')} #${r['id']} | ${context.tr('total_amount_label')}: ${r['total_price']} ${context.tr('currency_sar')}';
      }
    } else {
      if (raw['request_id'] != null) {
        requestDetails = '${context.tr('linked_to_request')} #${raw['request_id']}';
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: colors.card,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // الهيدر مع الأيقونة
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(iconData, color: iconColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getLocalizedTitle(context, item.title),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.date,
                              style: TextStyle(fontSize: 12, color: colors.textSub),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: colors.textSub.withValues(alpha: 0.1)),
                  ),

                  // تفاصيل المبلغ والحالة
                  _buildDetailRow(
                    context,
                    context.tr('auto_tr_42'),
                    '${item.amount.toStringAsFixed(2)} ${item.type == HistoryType.point ? context.tr('points') : context.tr('currency_sar')}',
                    valueColor: item.amount < 0 ? Colors.red : colors.text,
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.tr('auto_tr_44'), style: TextStyle(fontSize: 13, color: colors.textSub)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: badgeBgColor, borderRadius: BorderRadius.circular(8)),
                        child: Text(translatedStatus, style: TextStyle(color: badgeTextColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),

                  // الحقول الإضافية إن وجدت
                  if (packageDetails != null) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow(context, context.tr('auto_tr_58'), packageDetails),
                  ],
                  if (requestDetails != null) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow(context, context.tr('auto_tr_78'), requestDetails),
                  ],
                  if (bankName != null && bankName.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow(context, context.tr('auto_tr_3'), bankName),
                  ],
                  if (bondNumber != null && bondNumber.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow(context, context.tr('auto_tr_16'), bondNumber),
                  ],
                  if (adminNote != null && adminNote.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow(context, context.tr('auto_tr_23'), adminNote, valueColor: Colors.orange),
                  ],

                  // صورة الإيصال إن وجدت
                  if (bondImage != null && bondImage.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1, color: colors.textSub.withValues(alpha: 0.1)),
                    ),
                    Text(context.tr('auto_tr_50'), style: TextStyle(fontSize: 13, color: colors.textSub, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        final fullUrl = bondImage.startsWith('http')
                            ? bondImage
                            : '${ApiEndpoints.storageBaseUrl}$bondImage';
                        _showFullScreenImage(context, fullUrl);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              width: double.infinity,
                              color: colors.background,
                              child: Image.network(
                                bondImage.startsWith('http') ? bondImage : '${ApiEndpoints.storageBaseUrl}$bondImage',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Icon(Icons.broken_image_rounded, color: colors.textSub.withValues(alpha: 0.5), size: 40),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.tr('tap_to_zoom'),
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'Cairo'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      context.tr('close') != 'close' ? context.tr('close') : context.tr('auto_tr_85'),
                      style: TextStyle(color: colors.card, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {Color? valueColor}) {
    final colors = context.qsColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: colors.textSub)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: valueColor ?? colors.text),
          ),
        ),
      ],
    );
  }

  String _getLocalizedTitle(BuildContext context, String title) {
    String displayTitle = title;
    if (displayTitle == 'باقة نقاط') {
      displayTitle = context.tr('points_package');
    } else if (displayTitle.startsWith('باقة ')) {
      final pkgName = displayTitle.substring(5).trim();
      displayTitle = '${context.tr('points_package')}: $pkgName';
    } else if (displayTitle == 'عملية نقاط') {
      displayTitle = context.tr('points_transaction');
    } else if (displayTitle == 'نقاط مكافأة من النظام') {
      displayTitle = context.tr('bonus_points_system');
    } else if (displayTitle == 'استلام دفعة من عميل') {
      displayTitle = context.tr('payment_received_client');
    } else if (displayTitle == 'عملية سحب أموال (خصم)') {
      displayTitle = context.tr('withdrawal_deduction');
    } else if (displayTitle == 'سداد عمولة') {
      displayTitle = context.tr('pay_commission');
    } else if (displayTitle == 'تحويل أرباح إلى نقاط') {
      displayTitle = context.tr('convert_earnings_points');
    } else if (displayTitle == 'شراء باقة نقاط') {
      displayTitle = context.tr('buy_points_package');
    } else if (displayTitle == 'طلب سحب أرباح') {
      displayTitle = context.tr('withdraw_request');
    } else if (displayTitle.startsWith('سند دفع عمولة')) {
      final bondNumPart = displayTitle.replaceAll('سند دفع عمولة', '').trim();
      displayTitle = '${context.tr('commission_payment_receipt')} $bondNumPart';
    }
    return displayTitle;
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 64),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
