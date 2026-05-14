import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/profile_repository.dart';
import '../models/work_model.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../../../core/localization/app_localizations.dart';

class EditWorkViewModel extends ChangeNotifier {
  final ProfileRepository repository;
  final WorkModel work;

  EditWorkViewModel(this.repository, this.work) {
    titleController.text = work.title;
    descController.text = work.description;
  }

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
    if (titleController.text.trim().isEmpty) {
       DialogHelper.showErrorDialog(context, context.tr('error_title_required'));
       return;
    }

    final bool confirm = await DialogHelper.showConfirmationDialog(
      context,
      title: context.tr('save_changes'),
      message: 'هل أنت متأكد أنك تريد حفظ التعديلات على هذا العمل؟',
    );

    if (!confirm) return;

    isLoading = true;
    notifyListeners();

    try {
      await repository.updateWork(
        id: work.id,
        title: titleController.text.trim(),
        desc: descController.text.trim(),
        image: image,
      );

      isLoading = false;
      notifyListeners();
      
      await DialogHelper.showSuccessDialog(
        context,
        'تم حفظ التعديلات بنجاح',
      );

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

  Future<void> delete(BuildContext context) async {
    final bool confirm = await DialogHelper.showConfirmationDialog(
      context,
      title: context.tr('delete'),
      message: context.tr('delete_confirm_msg_specific', args: {'title': work.title}),
    );

    if (!confirm) return;

    isLoading = true;
    notifyListeners();

    try {
      await repository.deleteWork(work.id);

      isLoading = false;
      notifyListeners();
      
      await DialogHelper.showSuccessDialog(
        context,
        context.tr('delete_success'),
      );

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

