// مسار الملف: lib/features/profile/viewmodels/edit_profile_viewmodel.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../../../core/localization/app_localizations.dart';

class EditProfileViewModel extends ChangeNotifier {
  final ProfileRepository repository;
  final ProfileModel currentProfile;

  late TextEditingController nameController;
  late TextEditingController jobTitleController;
  late TextEditingController bioController;
  late bool isAvailable;
  
  File? newAvatar;
  bool isLoading = false;

  EditProfileViewModel(this.repository, this.currentProfile) {
    // 🚀 تعبئة البيانات الحالية في الحقول فور فتح الشاشة
    nameController = TextEditingController(text: currentProfile.name);
    jobTitleController = TextEditingController(
      text: (currentProfile.jobTitle.toLowerCase() == 'null' || currentProfile.jobTitle.isEmpty) 
          ? '' 
          : currentProfile.jobTitle
    );
    bioController = TextEditingController(text: currentProfile.bio);
    isAvailable = currentProfile.isAvailable;
  }

  // ⚡ تغيير حالة التوفر
  void toggleAvailability(bool value) {
    isAvailable = value;
    notifyListeners();
  }

  // 📸 التقاط الصورة
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      newAvatar = File(pickedFile.path);
      notifyListeners();
    }
  }

  // 💾 حفظ التعديلات وإرسالها للباك إند
  Future<void> saveProfile(BuildContext context) async {
    // عرض رسالة التأكيد أولاً
    final bool confirm = await DialogHelper.showConfirmationDialog(
      context,
      title: context.tr('confirm_save_changes'),
      message: context.tr('confirm_save_changes_message'),
    );

    if (!confirm) return;

    isLoading = true;
    notifyListeners();

    try {
      await repository.updateProfile(
        id: currentProfile.id,
        jobTitle: jobTitleController.text.trim(),
        bio: bioController.text.trim(),
        isAvailable: isAvailable,
        avatar: newAvatar,
      );

      isLoading = false;
      notifyListeners();

      // عرض رسالة النجاح
      await DialogHelper.showSuccessDialog(
        context,
        context.tr('profile_updated_successfully'),
      );

      // 🚀 نعود للصفحة السابقة مع إرسال القيمة (true) لكي يتم التحديث فوراً
      if (context.mounted) {
        Navigator.pop(context, true);
      }

    } catch (e) {
      isLoading = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, e.toString());
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    jobTitleController.dispose();
    bioController.dispose();
    super.dispose();
  }
}
