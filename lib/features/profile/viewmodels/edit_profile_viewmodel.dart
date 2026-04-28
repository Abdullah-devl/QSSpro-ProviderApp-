// مسار الملف: lib/features/profile/viewmodels/edit_profile_viewmodel.dart

import 'dart:io';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';
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
    jobTitleController = TextEditingController(text: currentProfile.jobTitle);
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
    isLoading = true;
    notifyListeners();

    try {
      await repository.updateProfile(
        id: currentProfile.id,
        name: nameController.text.trim(),
        jobTitle: jobTitleController.text.trim(),
        bio: bioController.text.trim(),
        isAvailable: isAvailable,
        avatar: newAvatar,
      );

      isLoading = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('profile_updated_successfully')), backgroundColor: context.qsColors.success),
      );

      // 🚀 نعود للصفحة السابقة مع إرسال القيمة (true) لكي يتم التحديث فوراً
      Navigator.pop(context, true);

    } catch (e) {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: context.qsColors.error),
      );
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
