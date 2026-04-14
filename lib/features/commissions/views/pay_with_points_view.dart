// مسار الملف: lib/features/commissions/views/pay_with_points_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../../../core/utils/dialog_helper.dart';
import '../viewmodels/pay_commissions_viewmodel.dart';

class PayWithPointsView extends StatelessWidget {
  final double amount;
  final int userId;
  final int availablePoints;
  final int equivalentPoints;
  final String? orderId;

  const PayWithPointsView({
    super.key,
    required this.amount,
    required this.userId,
    required this.availablePoints,
    required this.equivalentPoints,
    this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PayCommissionsViewModel>(context);
    final Color bgColor = const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('pay_with_points_title'),
          style: TextStyle(
            color: context.qsColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_ios, color: context.qsColors.text, size: 18),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // 1. بطاقة رصيد النقاط (Gradient Card)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5CA4B8), Color(0xFF4A8A9E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5CA4B8).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                        ),
                        child: const Icon(Icons.stars_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.tr('total_available_points'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        availablePoints.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        context.tr('points'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 2. تفاصيل العملية
                Text(
                  context.tr('transaction_details'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      // المبلغ المطلوب
                      _buildDetailRow(
                        context,
                        icon: Icons.account_balance_wallet_rounded,
                        iconBg: const Color(0xFFE4F3F8),
                        iconColor: const Color(0xFF5CA4B8),
                        title: context.tr('amount_required_to_pay'),
                        value: "${amount.toStringAsFixed(2)} ${context.tr('currency_sar')}",
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: List.generate(
                            150 ~/ 10,
                            (index) => Expanded(
                              child: Container(
                                color: index % 2 == 0 ? Colors.grey.shade300 : Colors.transparent,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // ما يعادله من نقاط
                      _buildDetailRow(
                        context,
                        icon: Icons.card_giftcard_rounded,
                        iconBg: const Color(0xFFFEF7E6),
                        iconColor: const Color(0xFFE6AE2D),
                        title: context.tr('equivalent_in_points'),
                        value: "${equivalentPoints.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ${context.tr('points')}",
                        valueColor: const Color(0xFF5CA4B8),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 3. ملاحظة الخصم
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF5CA4B8), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.tr('points_deduction_notice'),
                        style: const TextStyle(
                          color: Color(0xFF5CA4B8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // الزر السفلي
          Positioned(
            left: 24,
            right: 24,
            bottom: 30,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: viewModel.isLoading 
                  ? null 
                    : () async {
                        // 1. التحقق من الرصيد
                        if (availablePoints < equivalentPoints) {
                          DialogHelper.showErrorDialog(
                            context,
                            context.tr('insufficient_points'),
                          );
                          return;
                        }

                        // 2. التحقق من وجود رقم الطلب (لان الربط يتطلب ID)
                        if (orderId == null) {
                          DialogHelper.showErrorDialog(
                            context,
                            context.tr('error_order_id_required'),
                          );
                          return;
                        }

                        // 3. طلب تأكيد
                        final confirmed = await DialogHelper.showConfirmationDialog(
                          context,
                          title: context.tr('confirm_points_payment_title'),
                          message: context.tr('confirm_points_payment_msg')
                              .replaceAll('{amount}', amount.toStringAsFixed(2))
                              .replaceAll('{points}', equivalentPoints.toString()),
                        );

                        if (!confirmed) return;

                        // 4. تنفيذ الدفع
                        final success = await viewModel.payCommissionUsingPoints(orderId!, userId);
                        
                        if (context.mounted) {
                          if (success) {
                            await DialogHelper.showSuccessDialog(
                              context,
                              context.tr('payment_success_msg'),
                            );
                            if (context.mounted) Navigator.pop(context);
                          } else {
                            DialogHelper.showErrorDialog(
                              context,
                              viewModel.errorMessage ?? context.tr('payment_failed_msg'),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5CA4B8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: viewModel.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.tr('confirm_points_payment'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.check_circle_outline_rounded, size: 24),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
