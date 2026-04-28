// مسار الملف: lib/features/withdraw/views/withdraw_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:service_provider_app/core/utils/dialog_helper.dart';
import '../viewmodels/withdraw_viewmodel.dart';

class WithdrawView extends StatefulWidget {
  final int availablePoints;

  const WithdrawView({super.key, required this.availablePoints});

  @override
  State<WithdrawView> createState() => _WithdrawViewState();
}

class _WithdrawViewState extends State<WithdrawView> {
  final _amountController = TextEditingController();

  Future<void> _handleWithdraw(WithdrawViewModel viewModel) async {
    final String amountStr = _amountController.text.trim();
    if (amountStr.isEmpty) return;

    final double? amount = double.tryParse(amountStr);
    if (amount == null) return;

    final success = await viewModel.validateAndSubmit(
      amount: amount,
      availablePoints: widget.availablePoints,
    );

    if (success && mounted) {
      await DialogHelper.showSuccessDialog(
        context,
        context.tr('withdrawal_request_sent'),
      );
      if (mounted) {
        Navigator.pop(context); // العودة لصفحة العمولات
      }
    } else if (mounted && viewModel.errorMessage != null) {
      DialogHelper.showErrorDialog(context, context.tr(viewModel.errorMessage!));
      viewModel.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final viewModel = context.watch<WithdrawViewModel>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('withdraw_points'),
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 💳 كرت الرصيد المتاح
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, colors.primary.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    context.tr('available_balance'),
                    style: TextStyle(color: colors.card.withValues(alpha: 0.7), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.availablePoints}',
                    style: TextStyle(
                      color: colors.card,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('pts'),
                    style: TextStyle(color: colors.card, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 💰 حقل إدخال المبلغ
            Text(
              context.tr('withdraw_amount'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.text),
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.card,
                hintText: context.tr('enter_amount'),
                hintStyle: TextStyle(color: colors.textSub.withValues(alpha: 0.5)),
                prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: colors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.textSub.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.textSub.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.primary),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // 🔘 زر التأكيد
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : () => _handleWithdraw(viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.card,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: viewModel.isLoading
                    ? CircularProgressIndicator(color: colors.card)
                    : Text(
                        context.tr('withdraw_points'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
