// مسار الملف: lib/features/profile/views/add_work_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../viewmodels/add_work_viewmodel.dart';

class AddWorkView extends StatelessWidget {
  const AddWorkView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddWorkViewModel>();
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(context.tr('add_previous_work'), style: TextStyle(color: colors.text, fontWeight: FontWeight.bold)),
        centerTitle: true, 
        backgroundColor: context.qsColors.card, 
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.close, color: context.qsColors.textSub), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // منطقة رفع الصورة
            GestureDetector(
              onTap: vm.pickImage,
              child: Container(
                height: 200, width: double.infinity,
                decoration: BoxDecoration(
                  color: context.qsColors.card, borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF5CA4B8).withOpacity(0.3)),
                ),
                child: vm.image != null 
                    ? ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.file(vm.image!, fit: BoxFit.cover))
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.add_photo_alternate_outlined, size: 48, color: Color(0xFF5CA4B8)),
                        Text(context.tr('work_image')),
                      ]),
              ),
            ),
            const SizedBox(height: 24),
            _buildInput(context, context.tr('work_title'), vm.titleController),
            const SizedBox(height: 16),
            _buildInput(context, context.tr('work_description'), vm.descController, maxLines: 4),
            const SizedBox(height: 40),
            
            // زر الحفظ
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : () => vm.save(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5CA4B8), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))
                ),
                child: vm.isLoading 
                    ? CircularProgressIndicator(color: context.qsColors.card) 
                    : Text(context.tr('save_work'), style: TextStyle(color: context.qsColors.card, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context, String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(label, style: TextStyle(color: context.qsColors.primary, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: controller, 
        maxLines: maxLines, 
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          filled: true, 
          fillColor: context.qsColors.card, 
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)
        ),
      ),
    ]);
  }
}


