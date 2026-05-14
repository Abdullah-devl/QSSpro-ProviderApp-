// مسار الملف: lib/features/settings/viewmodels/platform_bank_accounts_viewmodel.dart

import 'package:flutter/material.dart';
import '../models/platform_bank_account_model.dart';
import '../repositories/settings_repository.dart';

class PlatformBankAccountsViewModel extends ChangeNotifier {
  final SettingsRepository repository;

  PlatformBankAccountsViewModel(this.repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PlatformBankAccountModel> _accounts = [];
  List<PlatformBankAccountModel> get accounts => _accounts;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAccounts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _accounts = await repository.getPlatformBankAccounts();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
