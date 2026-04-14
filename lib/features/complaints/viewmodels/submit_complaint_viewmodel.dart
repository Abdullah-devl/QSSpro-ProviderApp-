import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../repositories/complaints_repository.dart';

class SubmitComplaintViewModel extends ChangeNotifier {
  final ComplaintsRepository _repository;

  SubmitComplaintViewModel(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  String _selectedType = 'type_other';
  String get selectedType => _selectedType;

  void setSelectedType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  Future<bool> submit(String orderId, String title, String content) async {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      _errorMessage = 'validation_empty_fields';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final complaint = ComplaintModel(
        requestId: orderId,
        title: title,
        content: content,
        type: _selectedType,
      );

      await _repository.submitOrderComplaint(complaint);
      
      _isSuccess = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void resetState() {
    _isLoading = false;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();
  }
}
