// مسار الملف: lib/features/profile/viewmodels/add_work_viewmodel.dart
import 'dart:io';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/profile_repository.dart';
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
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('error_image_required')), backgroundColor: context.qsColors.error));
       return;
    }
    if (titleController.text.trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('error_title_required')), backgroundColor: context.qsColors.error));
       return;
    }

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
      
      // نعود للصفحة السابقة بنجاح (نرجع true ليتم تحديث البروفايل)
      if (context.mounted) {
        Navigator.pop(context, true);
      }

    } catch (e) {
      isLoading = false;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: context.qsColors.error));
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
