// مسار الملف: lib/features/commissions/views/pay_with_receipt_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'dart:io';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../../../core/utils/dialog_helper.dart';
import '../viewmodels/pay_commissions_viewmodel.dart';

class PayWithReceiptView extends StatefulWidget {
  final String? orderId;
  final double amount;

  const PayWithReceiptView({super.key, this.orderId, required this.amount});

  @override
  State<PayWithReceiptView> createState() => _PayWithReceiptViewState();
}

class _PayWithReceiptViewState extends State<PayWithReceiptView> {
  @override
  void initState() {
    super.initState();
    // تهيئة البيانات تلقائياً في المتحكمات عند التمرير
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<PayCommissionsViewModel>();
      if (widget.orderId != null) {
        vm.requestIdController.text = widget.orderId!;
      }
      vm.amountController.text = widget.amount.toStringAsFixed(2);
    });
  }

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
          context.tr('attach_payment_receipt'),
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
              decoration: BoxDecoration(
                color: context.qsColors.card,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_ios,
                  color: context.qsColors.text, size: 18),
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

                // 1. بطاقة التعليمات والرفع
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.qsColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: context.qsColors.textSub.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0F7F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_upload_outlined,
                          color: Color(0xFF5CA4B8),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.tr('receipt_upload_title'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.qsColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('receipt_upload_subtitle'),
                        style: TextStyle(
                          fontSize: 13,
                          color: context.qsColors.textSub,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // منطقة اختيار الصورة
                      GestureDetector(
                        onTap: () => viewModel.pickReceiptImage(),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF5CA4B8).withOpacity(0.2),
                              style: viewModel.receiptImage == null
                                  ? BorderStyle.solid
                                  : BorderStyle.none,
                            ),
                          ),
                          child: viewModel.receiptImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    viewModel.receiptImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_photo_alternate_outlined,
                                        color: Color(0xFF5CA4B8), size: 40),
                                    const SizedBox(height: 12),
                                    Text(
                                      context.tr('click_to_upload_receipt'),
                                      style: const TextStyle(
                                        color: Color(0xFF5CA4B8),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      context.tr('upload_limit_hint'),
                                      style: TextStyle(
                                        color: context.qsColors.textSub,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 2. حقول البيانات
                Text(
                  context.tr('bank_details'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.qsColors.text,
                  ),
                ),
                const SizedBox(height: 16),

                _buildInputField(
                  context,
                  controller: viewModel.bondNumberController,
                  label: context.tr('bond_number'),
                  hint: context.tr('bond_number_hint'),
                  icon: Icons.numbers,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  context,
                  controller: viewModel.amountController,
                  label: context.tr('amount'),
                  hint: context.tr('enter_amount'),
                  icon: Icons.money_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  context,
                  controller: viewModel.descriptionController,
                  label: context.tr('description_label'),
                  hint: context.tr('description_hint'),
                  icon: Icons.description_outlined,
                  maxLines: 3,
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
                        final enteredAmount = double.tryParse(viewModel.amountController.text) ?? widget.amount;
                        final success = await viewModel.submitReceipt(enteredAmount);
                        if (context.mounted) {
                          if (success) {
                            await DialogHelper.showSuccessDialog(
                              context,
                              context.tr('payment_under_review'),
                            );
                            if (context.mounted) Navigator.pop(context);
                          } else {
                            DialogHelper.showErrorDialog(
                              context,
                              viewModel.errorMessage != null
                                  ? context.tr(viewModel.errorMessage!)
                                  : context.tr('error_occurred'),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5CA4B8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: viewModel.isLoading
                    ? CircularProgressIndicator(color: context.qsColors.card)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.tr('send_receipt'),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.send_rounded, size: 24),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: context.qsColors.text,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF5CA4B8), size: 20),
            filled: true,
            fillColor: readOnly ? context.qsColors.textSub : context.qsColors.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.qsColors.textSub),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.qsColors.textSub),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5CA4B8), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}


