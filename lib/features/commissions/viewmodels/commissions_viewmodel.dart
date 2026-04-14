// مسار الملف: lib/features/commissions/viewmodels/commissions_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:service_provider_app/core/network/error/failure.dart';
import '../models/commission_model.dart';
import '../repositories/commissions_repository.dart';

class CommissionsViewModel extends ChangeNotifier {
  final CommissionsRepository _repository;

  CommissionsViewModel(this._repository) {
    // تم إلغاء الجلب التلقائي لتجنب الخطأ 404 (api/commissions غير موجود حالياً)
    // fetchCommissionsData();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CommissionDataModel? _commissionsData;
  CommissionDataModel? get commissionsData => _commissionsData;

  // 0: الكل (All), 1: مدفوع (Paid), 2: معلق (Pending)
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  final List<String> tabKeys = ['all', 'paid', 'pending'];

  Future<void> fetchCommissionsData() async {
    // تم إيقاف محتوى هذه الدالة لتجنب الخطأ 404 بالسيرفر
    // _isLoading = true;
    // _errorMessage = null;
    // notifyListeners();

    // try {
    //   _commissionsData = await _repository.getCommissionsData();

    //   _isLoading = false;
    //   notifyListeners();
    // } on Failure catch (failure) {
    //   _isLoading = false;
    //   _errorMessage = failure.message;
    //   notifyListeners();
    // } catch (e) {
    //   _isLoading = false;
    //   _errorMessage = 'error_unexpected_fetch_data';
    //   notifyListeners();
    // }
  }

  // فلترة التعاملات المالية حسب التبويب المختار
  List<CommissionTransactionModel> get filteredTransactions {
    if (_commissionsData == null) return [];

    final all = _commissionsData!.transactions;

    if (_selectedTabIndex == 0) {
      return all; // الكل
    } else if (_selectedTabIndex == 1) {
      return all.where((t) => t.status == 'completed').toList(); // مدفوع
    } else {
      return all
          .where((t) => t.status == 'pending' || t.status == 'processing')
          .toList(); // معلق أو قيد المعالجة
    }
  }

  void changeTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }
}
