import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../viewmodels/custom_service_viewmodel.dart';
import 'package:service_provider_app/core/utils/dialog_helper.dart';

class EditCustomServiceView extends StatelessWidget {
  const EditCustomServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CustomServiceViewModel>(context);

    return Scaffold(
      backgroundColor: context.qsColors.background,
      appBar: AppBar(
        title: Text('تعديل الخدمة المخصصة', style: TextStyle(color: context.qsColors.text, fontWeight: FontWeight.bold)),
        backgroundColor: context.qsColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: context.qsColors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // حالة الخدمة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تنشيط الخدمة',
                  style: TextStyle(color: context.qsColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Switch.adaptive(
                  value: viewModel.isActive,
                  onChanged: viewModel.setIsActive,
                  activeColor: context.qsColors.success,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // وصف الخدمة
            Text(
              'وصف الخدمة',
              style: TextStyle(color: context.qsColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.qsColors.textSub.withOpacity(0.1)),
              ),
              child: TextField(
                controller: viewModel.descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'اكتب وصفاً للخدمة المخصصة...',
                  hintStyle: TextStyle(color: context.qsColors.textSub.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // زر الحفظ
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.qsColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: viewModel.isSaving
                    ? null
                    : () async {
                        bool success = await viewModel.updateCustomService(context);
                        if (success && context.mounted) {
                          await DialogHelper.showSuccessDialog(context, 'تم تعديل الخدمة بنجاح');
                          Navigator.pop(context, true);
                        }
                      },
                child: viewModel.isSaving
                    ? CircularProgressIndicator(color: context.qsColors.card)
                    : Text(
                        'حفظ التعديلات',
                        style: TextStyle(color: context.qsColors.card, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



