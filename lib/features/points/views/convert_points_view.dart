// مسار الملف: lib/features/points/views/convert_points_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:service_provider_app/core/utils/dialog_helper.dart';
import '../viewmodels/convert_points_viewmodel.dart';

class ConvertPointsView extends StatefulWidget {
  final double availablePaidPoints;
  final double currentBonusPoints;

  const ConvertPointsView({
    super.key,
    required this.availablePaidPoints,
    required this.currentBonusPoints,
  });

  @override
  State<ConvertPointsView> createState() => _ConvertPointsViewState();
}

class _ConvertPointsViewState extends State<ConvertPointsView> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value, ConvertPointsViewModel viewModel) {
    final double? amount = double.tryParse(value);
    viewModel.setAmount(amount ?? 0);
  }

  Future<void> _handleConvert(ConvertPointsViewModel viewModel) async {
    if (viewModel.amount <= 0) return;

    if (viewModel.amount > widget.availablePaidPoints) {
      DialogHelper.showErrorDialog(context, context.tr('insufficient_balance'));
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.qsColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.tr('conversion_confirmation'),
          style: TextStyle(color: context.qsColors.text),
        ),
        content: Text(
          context.tr('conversion_confirmation_msg', args: {'amount': viewModel.amount.toStringAsFixed(2)}),
          style: TextStyle(color: context.qsColors.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel'), style: TextStyle(color: context.qsColors.textSub)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.qsColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(context.tr('confirm'), style: TextStyle(color: context.qsColors.card)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await viewModel.convertPoints(
        availablePaidPoints: widget.availablePaidPoints,
      );

      if (success && mounted) {
        await DialogHelper.showSuccessDialog(context, context.tr('conversion_success'));
        if (mounted) Navigator.pop(context, true);
      } else if (mounted && viewModel.errorMessage != null) {
        DialogHelper.showErrorDialog(context, context.tr(viewModel.errorMessage!));
        viewModel.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final viewModel = context.watch<ConvertPointsViewModel>();
    final Color primaryColor = colors.primary;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('convert_points_title'),
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: colors.text, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        leading: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 💰 بطاقة الأرصدة الحالية
            Row(
              children: [
                _buildBalanceCard(
                  context,
                  title: context.tr('withdrawable_points'),
                  value: widget.availablePaidPoints.toStringAsFixed(0),
                  color: colors.success,
                  icon: Icons.monetization_on_rounded,
                ),
                const SizedBox(width: 12),
                _buildBalanceCard(
                  context,
                  title: context.tr('bonus_points_wallet'),
                  value: widget.currentBonusPoints.toStringAsFixed(0),
                  color: colors.warning,
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ✍️ حقل الإدخال
            Text(
              context.tr('convert_amount_label'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.text),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              onChanged: (val) => _onAmountChanged(val, viewModel),
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.text),
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.card,
                hintText: '0.00',
                hintStyle: TextStyle(color: colors.textSub),
                prefixIcon: Icon(Icons.swap_horiz_rounded, color: primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // ✨ ملاحظة المكافأة 1% العائمة
            if (viewModel.amount > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.stars_rounded, color: primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.tr('conversion_bonus_note', args: {'total': viewModel.totalWithBonus.toStringAsFixed(2)}),
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 48),

            // 🔘 زر التحويل
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : () => _handleConvert(viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: colors.card,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: viewModel.isLoading
                    ? CircularProgressIndicator(color: colors.card)
                    : Text(
                        context.tr('confirm'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.qsColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.qsColors.text.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 12, color: context.qsColors.textSub), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
