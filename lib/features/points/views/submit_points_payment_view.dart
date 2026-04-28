// مسار الملف: lib/features/points/views/submit_points_payment_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:service_provider_app/core/utils/dialog_helper.dart';
import '../models/points_package_model.dart';
import '../viewmodels/points_viewmodel.dart';

class SubmitPointsPaymentView extends StatefulWidget {
  final PointsPackageModel package;

  const SubmitPointsPaymentView({super.key, required this.package});

  @override
  State<SubmitPointsPaymentView> createState() => _SubmitPointsPaymentViewState();
}

class _SubmitPointsPaymentViewState extends State<SubmitPointsPaymentView> {
  final _bondNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  File? _selectedImage;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      DialogHelper.showErrorDialog(context, context.tr('error_image_selection'));
    }
  }

  Future<void> _submit(PointsViewModel viewModel) async {
    if (_bondNumberController.text.isEmpty) {
      DialogHelper.showErrorDialog(context, context.tr('error_missing_bond_number'));
      return;
    }
    if (_bankNameController.text.isEmpty) {
      DialogHelper.showErrorDialog(context, context.tr('bank_name_required'));
      return;
    }
    if (_selectedImage == null) {
      DialogHelper.showErrorDialog(context, context.tr('error_missing_receipt_image'));
      return;
    }

    final success = await viewModel.subscribeToPackage(
      packageId: widget.package.id,
      bondNumber: _bondNumberController.text,
      bankName: _bankNameController.text,
      bondImage: _selectedImage!,
    );

    if (success && mounted) {
      await DialogHelper.showSuccessDialog(
        context,
        context.tr('payment_success'),
      );
      if (mounted) {
        Navigator.pop(context); // العودة لشاشة الباقات
        Navigator.pop(context); // العودة لصفحة العمولات
      }
    } else if (mounted) {
      DialogHelper.showErrorDialog(context, viewModel.errorMessage ?? context.tr('payment_failed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final viewModel = context.watch<PointsViewModel>();
    final Color bgColor = colors.background;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('submit_payment'),
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
            // 🏷️ ملخص الباقة
            _buildPackageSummary(colors),
            const SizedBox(height: 32),

            // 🔢 رقم السند
            Text(
              context.tr('bond_number'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.text),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bondNumberController,
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.card,
                hintText: context.tr('bond_number_hint'),
                hintStyle: TextStyle(color: colors.textSub),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(18),
              ),
            ),
            const SizedBox(height: 24),

            // 🏦 اسم البنك
            Text(
              context.tr('bank_name'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.text),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bankNameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.card,
                hintText: context.tr('bank_name_hint'),
                hintStyle: TextStyle(color: colors.textSub),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(18),
              ),
            ),
            const SizedBox(height: 24),

            // 📷 صورة السند
            Text(
              context.tr('receipt_upload_title'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.text),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.2), width: 2),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, color: colors.primary, size: 48),
                          const SizedBox(height: 12),
                          Text(context.tr('click_to_upload_receipt'), style: TextStyle(color: colors.textSub)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 48),

            // 🔘 زر التقديم
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : () => _submit(viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.card,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: viewModel.isLoading
                    ? CircularProgressIndicator(color: colors.card)
                    : Text(
                        context.tr('submit_payment'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageSummary(dynamic colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(widget.package.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.text)),
          const SizedBox(height: 8),
          Text(
            '${widget.package.price.toInt()} ${context.tr('sar')}',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('points_amount', args: {'count': widget.package.points.toString()}),
            style: TextStyle(color: colors.textSub),
          ),
        ],
      ),
    );
  }
}
