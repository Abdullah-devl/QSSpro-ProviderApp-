import 'package:flutter/material.dart';
import 'package:service_provider_app/core/network/error/failure.dart';
import '../../home/models/home_model.dart';
import '../repositories/commissions_repository.dart';

class UnpaidCommissionsViewModel extends ChangeNotifier {
  final CommissionsRepository _repository;

  UnpaidCommissionsViewModel(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<UnpaidRequestModel> _unpaidRequests = [];
  List<UnpaidRequestModel> get unpaidRequests => _unpaidRequests;

  Future<void> fetchUnpaidCommissions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _unpaidRequests = await _repository.getUnpaidCommissions();
      _isLoading = false;
      notifyListeners();
    } on Failure catch (failure) {
      _isLoading = false;
      _errorMessage = failure.message;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'error_occurred';
      notifyListeners();
    }
  }
}
