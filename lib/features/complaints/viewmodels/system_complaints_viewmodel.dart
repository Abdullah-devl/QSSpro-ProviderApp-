import 'package:flutter/material.dart';
import '../models/system_complaint_model.dart';
import '../repositories/complaints_repository.dart';

class SystemComplaintsViewModel extends ChangeNotifier {
  final ComplaintsRepository _repository;

  SystemComplaintsViewModel(this._repository);

  List<SystemComplaintModel> _complaints = [];
  List<SystemComplaintModel> get complaints => _complaints;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedType = 'type_technical';
  String get selectedType => _selectedType;

  void setSelectedType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  Future<void> fetchComplaints() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _complaints = await _repository.getSystemComplaints();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitComplaint(String title, String content) async {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      _errorMessage = 'validation_empty_fields';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final complaint = SystemComplaintModel(
        title: title,
        type: _selectedType,
        content: content,
      );

      await _repository.submitSystemComplaint(complaint);
      
      _isSubmitting = false;
      await fetchComplaints(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
