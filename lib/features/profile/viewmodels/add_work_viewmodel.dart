// مسار الملف: lib/features/profile/viewmodels/add_work_viewmodel.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/profile_repository.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../../../core/localization/app_localizations.dart';

class AddWorkViewModel extends ChangeNotifier {
  final ProfileRepository repository;

  AddWorkViewModel(this.repository);

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  File? image;
  bool isLoading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> save(BuildContext context) async {
    if (image == null) {
       DialogHelper.showErrorDialog(context, context.tr('error_image_required'));
       return;
    }
    if (titleController.text.trim().isEmpty) {
       DialogHelper.showErrorDialog(context, context.tr('error_title_required'));
       return;
    }

    final bool confirm = await DialogHelper.showConfirmationDialog(
      context,
      title: context.tr('save_work'),
      message: 'هل أنت متأكد أنك تريد إضافة هذا العمل إلى معرض أعمالك؟',
    );

    if (!confirm) return;

    isLoading = true;
    notifyListeners();

    try {
      await repository.uploadWork(
        title: titleController.text.trim(),
        desc: descController.text.trim(),
        image: image!,
      );

      isLoading = false;
      notifyListeners();
      
      await DialogHelper.showSuccessDialog(
        context,
        'تمت إضافة العمل بنجاح',
      );

      // نعود للصفحة السابقة بنجاح (نرجع true ليتم تحديث البروفايل)
      if (context.mounted) {
        Navigator.pop(context, true);
      }

    } catch (e) {
      isLoading = false;
      notifyListeners();
      if (context.mounted) {
        DialogHelper.showErrorDialog(context, e.toString());
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }
}
