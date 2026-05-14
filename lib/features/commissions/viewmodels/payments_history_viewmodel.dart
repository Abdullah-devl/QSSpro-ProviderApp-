// مسار الملف: lib/features/commissions/viewmodels/payments_history_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:service_provider_app/core/network/error/failure.dart';
import '../models/history_models.dart';
import '../repositories/payments_history_repository.dart';

class PaymentsHistoryViewModel extends ChangeNotifier {
  final PaymentsHistoryRepository _repository;

  PaymentsHistoryViewModel(this._repository) {
    // جلب كافة السجلات عند بدء التشغيل لتقديم تبويب "الكل" مباشرة
    fetchAllHistory();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // قوائم البيانات المصنفة
  List<PointsPackageHistoryModel> _packages = [];
  List<PointsTransactionModel> _transactions = [];
  List<WithdrawRequestModel> _withdrawals = [];
  List<ProviderRequestBondModel> _bonds = [];

  // القائمة الموحدة (الكل)
  List<BaseHistoryItem> _allHistory = [];

  // التبويب المختار (0: الكل، 1: باقاتي، 2: العمليات، 3: السحوبات، 4: السندات)
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  final List<String> tabKeys = [
    'history_tab_all',
    'history_tab_packages',
    'history_tab_points',
    'history_tab_withdrawals',
    'history_tab_bonds',
  ];

  /// 🚀 دالة جلب كافة السجلات بشكل متوازي (Cache-Then-Network)
  Future<void> fetchAllHistory() async {
    // 1. 📥 تحميل البيانات المحلية من الكاش فوراً وعرضها للمستخدم
    final cachedPackages = _repository.getCachedList<PointsPackageHistoryModel>(
      'cached_my_points_packages',
      (json) => PointsPackageHistoryModel.fromJson(json),
    );
    final cachedTransactions = _repository.getCachedList<PointsTransactionModel>(
      'cached_points_transactions',
      (json) => PointsTransactionModel.fromJson(json),
    );
    final cachedWithdrawals = _repository.getCachedList<WithdrawRequestModel>(
      'cached_my_withdraw_requests',
      (json) => WithdrawRequestModel.fromJson(json),
    );
    final cachedBonds = _repository.getCachedList<ProviderRequestBondModel>(
      'cached_provider_request_bonds',
      (json) => ProviderRequestBondModel.fromJson(json),
    );

    if (cachedPackages.isNotEmpty || cachedTransactions.isNotEmpty || cachedWithdrawals.isNotEmpty || cachedBonds.isNotEmpty) {
      _packages = cachedPackages;
      _transactions = cachedTransactions;
      _withdrawals = cachedWithdrawals;
      _bonds = cachedBonds;

      _allHistory = [
        ..._packages,
        ..._transactions,
        ..._withdrawals,
        ..._bonds,
      ];
      _allHistory.sort((a, b) => b.date.compareTo(a.date));

      debugPrint('⚡ PaymentsHistoryViewModel: Loaded local payments history instantly from local Hive cache.');
      notifyListeners();
    }

    // 2. 🌐 جلب التحديثات الحية في الخلفية
    _isLoading = _allHistory.isEmpty;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getMyPointsPackages(),
        _repository.getPointsTransactions(),
        _repository.getMyWithdrawRequests(),
        _repository.getProviderRequestBonds(),
      ]);

      _packages = results[0] as List<PointsPackageHistoryModel>;
      _transactions = results[1] as List<PointsTransactionModel>;
      _withdrawals = results[2] as List<WithdrawRequestModel>;
      _bonds = results[3] as List<ProviderRequestBondModel>;

      // دمج وترتيب كافة السجلات حسب التاريخ (الأحدث أولاً)
      _allHistory = [
        ..._packages,
        ..._transactions,
        ..._withdrawals,
        ..._bonds,
      ];
      
      // ترتيب تنازلي حسب التاريخ (نفترض أن التاريخ قيد قادم بصيغة ISO أو قابلة للمقارنة)
      _allHistory.sort((a, b) => b.date.compareTo(a.date));

      _isLoading = false;
      notifyListeners();
    } on Failure catch (failure) {
      _isLoading = false;
      if (_allHistory.isEmpty) {
        _errorMessage = failure.message;
      }
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (_allHistory.isEmpty) {
        _errorMessage = 'error_unexpected_fetch_data';
      }
      notifyListeners();
    }
  }

  /// القائمة المفلترة بناءً على التبويب المختار
  List<BaseHistoryItem> get filteredHistory {
    switch (_selectedTabIndex) {
      case 0:
        return _allHistory;
      case 1:
        return _packages;
      case 2:
        return _transactions;
      case 3:
        return _withdrawals;
      case 4:
        return _bonds;
      default:
        return _allHistory;
    }
  }

  void changeTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  /// دالة لتحديث البيانات يدوياً
  Future<void> refresh() => fetchAllHistory();
}
