// مسار الملف: lib/features/verification/views/new_verification_request_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import 'package:service_provider_app/features/verification/submit_verification/viewmodels/verification_viewmodel.dart';

class NewVerificationRequestView extends StatelessWidget {
  const NewVerificationRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<VerificationViewModel>();
    final bgColor = const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('new_verification_request_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📝 الهيدر
            Text(
              context.tr('why_verify_question'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('verification_request_hint_desc'),
              style: TextStyle(fontSize: 14, color: colors.textSub, height: 1.6),
            ),
            const SizedBox(height: 32),

            // ✍️ حقل النص الرئيسي
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: TextField(
                controller: vm.contentController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: context.tr('write_here'),
                  hintStyle: TextStyle(color: colors.textSub, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 🚀 زر الإرسال
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : () => vm.submitContentRequest(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5CA4B8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: vm.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        context.tr('submit_verification_request'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
