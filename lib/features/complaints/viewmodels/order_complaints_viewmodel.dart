import 'package:flutter/material.dart';
import '../models/request_complaint_model.dart';
import '../repositories/complaints_repository.dart';
import '../../../../core/network/error/api_error_handler.dart';

class OrderComplaintsViewModel extends ChangeNotifier {
  final ComplaintsRepository _repository;

  OrderComplaintsViewModel(this._repository) {
    fetchComplaints();
  }

  List<RequestComplaintModel> _complaints = [];
  List<RequestComplaintModel> get complaints => _complaints;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchComplaints() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _complaints = await _repository.getRequestComplaints();
    } catch (e) {
      _errorMessage = ApiErrorHandler.handle(e).message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
