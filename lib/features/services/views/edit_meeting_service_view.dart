import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../viewmodels/meeting_service_viewmodel.dart';
import 'package:service_provider_app/core/utils/dialog_helper.dart';

class EditMeetingServiceView extends StatelessWidget {
  const EditMeetingServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MeetingServiceViewModel>(context);

    return Scaffold(
      backgroundColor: context.qsColors.background,
      appBar: AppBar(
        title: Text('تعديل خدمة الحضور', style: TextStyle(color: context.qsColors.text, fontWeight: FontWeight.bold)),
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
            // التنشيط
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

            // السعر الأساسي
            Text('سعر الخدمة الأساسي', style: TextStyle(color: context.qsColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildAmountField(context, controller: viewModel.priceController, hint: 'مثال: 100'),
            const SizedBox(height: 20),

            // سعر الكيلو
            Text('سعر الكيلومتر الواحد', style: TextStyle(color: context.qsColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildAmountField(context, controller: viewModel.pricePerKmController, hint: 'مثال: 2.5'),
            const SizedBox(height: 20),

            // الوصف
            Text('وصف الخدمة', style: TextStyle(color: context.qsColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.qsColors.textSub.withOpacity(0.1)),
              ),
              child: TextField(
                controller: viewModel.descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'اكتب وصفاً هنا...',
                  hintStyle: TextStyle(color: context.qsColors.textSub.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // الحفظ
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
                        bool success = await viewModel.updateMeetingService(context);
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

  Widget _buildAmountField(BuildContext context, {required TextEditingController controller, required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.qsColors.textSub.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: context.qsColors.textSub.withOpacity(0.1))),
            ),
            child: Text('ر.س', style: TextStyle(color: context.qsColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}



