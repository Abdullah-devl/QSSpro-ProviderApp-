import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';

import '../viewmodels/verification_viewmodel.dart';

class SubmitVerificationView extends StatelessWidget {
  final int packageId;

  const SubmitVerificationView({super.key, required this.packageId});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<VerificationViewModel>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('verify_account_title'),
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 📝 1. الهيدر (العنوان والوصف)
            _buildHeader(context, colors),
            const SizedBox(height: 40),

            // 📸 2. قسم رفع الصورة (صورة السند)
            _buildSectionTitle(
              context,
              Icons.contact_mail_rounded,
              context.tr('bond_image_title'),
              colors,
            ),
            const SizedBox(height: 16),
            _buildImageUploadArea(context, vm, colors),
            const SizedBox(height: 32),

            // 🔢 3. قسم إدخال رقم السند
            _buildSectionTitle(
              context,
              Icons.receipt_long_rounded,
              context.tr('bond_number_title'),
              colors,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context,
              vm.bondNumberController,
              context.tr('bond_number_hint'),
              colors,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomSection(context, vm, colors),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    VerificationViewModel vm,
    dynamic colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        boxShadow: [
          BoxShadow(
            color: colors.text.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, color: colors.textSub.withValues(alpha: 0.5), size: 16),
                const SizedBox(width: 6),
                Text(
                  context.tr('data_encrypted_secure'),
                  style: TextStyle(color: colors.textSub, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : () => vm.submitVerification(context, packageId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.card,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: vm.isLoading
                    ? 
                     SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: colors.card, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.tr('submit_for_review'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic colors) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 32,
              height: 8,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          context.tr('verify_identity_heading'),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.text),
        ),
        const SizedBox(height: 12),
        Text(
          context.tr('verify_identity_desc'),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: colors.textSub, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, IconData icon, String title, dynamic colors) {
    return Row(
      children: [
        Icon(icon, color: colors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.text),
        ),
      ],
    );
  }

  Widget _buildImageUploadArea(BuildContext context, VerificationViewModel vm, dynamic colors) {
    if (vm.selectedImage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.textSub.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: colors.text.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(vm.selectedImage!, width: 60, height: 60, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('bond_image_title'), style: TextStyle(color: colors.text, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(context.tr('upload_success'), style: TextStyle(color: colors.success, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colors.error),
              onPressed: () => vm.removeImage(),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: () => vm.pickImage(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.textSub.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.05), shape: BoxShape.circle),
              child: Icon(Icons.cloud_upload_outlined, color: colors.primary, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('click_to_upload_bond'),
              style: TextStyle(color: colors.textSub, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, String hint, dynamic colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.textSub.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colors.text.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(color: colors.text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colors.textSub.withValues(alpha: 0.5), fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
