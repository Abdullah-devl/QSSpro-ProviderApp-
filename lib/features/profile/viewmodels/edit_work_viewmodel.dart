import 'dart:io';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/profile_repository.dart';
import '../models/work_model.dart';
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
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('error_title_required')), backgroundColor: context.qsColors.error));
       return;
    }

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

  Future<void> delete(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      await repository.deleteWork(work.id);

      isLoading = false;
      notifyListeners();
      
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

