import 'package:flutter/material.dart';
import 'package:service_provider_app/core/network/error/failure.dart';
import 'package:service_provider_app/core/utils/dialog_helper.dart';
import '../models/service_details_model.dart';
import '../repositories/manage_services_repository.dart';

class MeetingServiceViewModel extends ChangeNotifier {
  final ManageServicesRepository _repository;
  final int serviceId;
  ServiceDetailsModel? service;

  MeetingServiceViewModel(this._repository, this.serviceId) {
    if (serviceId != 0) {
      fetchDetails();
    } else {
      _isLoading = false;
    }
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // للحقول الخاصة بالتعديل
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController pricePerKmController = TextEditingController();
  bool isActive = true;
  bool isSaving = false;

  Future<void> fetchDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      service = await _repository.getServiceDetails(serviceId);
      if (service != null) {
        descriptionController.text = service!.description;
        isActive = service!.isActive;
        // السعر يأتي في priceText مثل "100 ر.س"، نأخذ الرقم فقط
        priceController.text = service!.priceText.split(' ').first;
        pricePerKmController.text = service!.pricePerKm.toString();
      }
      _isLoading = false;
      notifyListeners();
    } on Failure catch (f) {
      _isLoading = false;
      _errorMessage = f.message;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'حدث خطأ غير متوقع';
      notifyListeners();
    }
  }

  void setIsActive(bool val) {
    isActive = val;
    notifyListeners();
  }

  Future<bool> updateMeetingService(BuildContext context) async {
    isSaving = true;
    notifyListeners();

    try {
      await _repository.updateSpecialService(
        isCustom: false,
        description: descriptionController.text.trim(),
        price: double.tryParse(priceController.text.trim()) ?? 0,
        pricePerKm: double.tryParse(pricePerKmController.text.trim()) ?? 0,
        isActive: isActive,
      );
      isSaving = false;
      await fetchDetails();
      return true;
    } catch (e) {
      isSaving = false;
      notifyListeners();
      DialogHelper.showErrorDialog(context, 'حدث خطأ أثناء حفظ التعديلات');
      return false;
    }
  }
}
