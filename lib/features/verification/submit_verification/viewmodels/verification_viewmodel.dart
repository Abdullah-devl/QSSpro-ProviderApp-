// مسار الملف: lib/features/verification/viewmodels/verification_viewmodel.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/verification_repository.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/dialog_helper.dart';

class VerificationViewModel extends ChangeNotifier {
  final VerificationRepository repository;

  VerificationViewModel(this.repository);

  File? selectedImage;
  final TextEditingController bondNumberController = TextEditingController();
  final TextEditingController contentController =
      TextEditingController(); // للميزة الجديدة

  bool isLoading = false;

  // 📸 اختيار الصورة من المعرض
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  // 🗑️ حذف الصورة المحددة
  void removeImage() {
    selectedImage = null;
    notifyListeners();
  }

  // 🚀 إرسال طلب التوثيق عبر الباقات (سند وصورة)
  Future<void> submitVerification(BuildContext context, int packageId) async {
    if (selectedImage == null) {
      DialogHelper.showErrorDialog(
        context,
        context.tr('upload_image_validation'),
      );
      return;
    }
    if (bondNumberController.text.trim().isEmpty) {
      DialogHelper.showErrorDialog(
        context,
        context.tr('enter_bond_number_validation'),
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await repository.submitVerificationPackage(
        packageId: packageId,
        bondNumber: bondNumberController.text.trim(),
        imageBond: selectedImage!,
      );

      isLoading = false;
      notifyListeners();

      await DialogHelper.showSuccessDialog(
        context,
        context.tr('verification_submitted_success'),
      );

      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      if (context.mounted) {
        DialogHelper.showErrorDialog(context, e.toString());
      }
    }
  }

  // 🛡️ إرسال طلب توثيق جديد (Content فقط)
  Future<void> submitContentRequest(BuildContext context) async {
    if (contentController.text.trim().isEmpty) {
      DialogHelper.showErrorDialog(context, context.tr('error_missing_verification_content'));
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await repository.sendVerificationRequest(contentController.text.trim());

      isLoading = false;
      notifyListeners();

      await DialogHelper.showSuccessDialog(
        context,
        context.tr('verification_content_submitted_success'),
      );

      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
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
    bondNumberController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
