// مسار الملف: lib/features/commissions/viewmodels/commissions_stats_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:service_provider_app/features/points/repositories/points_repository.dart';
import 'package:service_provider_app/features/profile/repositories/profile_repository.dart';

import '../models/provider_commission_summary_model.dart';
import '../../points/models/points_balance_model.dart';
import '../repositories/commissions_repository.dart';

class CommissionsStatsViewModel extends ChangeNotifier {
  final CommissionsRepository _repository;
  final PointsRepository _pointsRepository;
  final ProfileRepository _profileRepository;

  CommissionsStatsViewModel(
    this._repository,
    this._pointsRepository,
    this._profileRepository,
  ) {
    // جلب البيانات فوراً عند بدء الـ ViewModel
    fetchStatsData();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProviderCommissionSummaryModel? _statsSummary;
  ProviderCommissionSummaryModel? get statsSummary => _statsSummary;

  PointsBalanceModel? _pointsBalance;
  PointsBalanceModel? get pointsBalance => _pointsBalance;

  int _verificationDaysLeft = 0;
  int get verificationDaysLeft => _verificationDaysLeft;

  bool _isVerified = false;
  bool get isVerified => _isVerified;

  Future<void> fetchStatsData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 🚀 جلب البيانات بشكل مستقل لضمان استقرار العرض حتى لو فشل أحد الطلبات
      
      // 1. ملخص العمولات
      try {
        _statsSummary = await _repository.getProviderCommissionSummary();
        debugPrint('✅ CommissionsStatsViewModel: statsSummary loaded');
      } catch (e) {
        debugPrint('❌ CommissionsStatsViewModel: Error loading statsSummary: $e');
      }

      // 2. رصيد النقاط
      try {
        _pointsBalance = await _pointsRepository.getPointsBalance();
        debugPrint('✅ CommissionsStatsViewModel: pointsBalance loaded: ${_pointsBalance?.bonusPoints} pts');
      } catch (e) {
        debugPrint('❌ CommissionsStatsViewModel: Error loading pointsBalance: $e');
      }
      
      // 3. بيانات البروفايل
      try {
        final profile = await _profileRepository.getMyProfile();
        _isVerified = profile.verificationProvider;
        _calculateVerificationDays(profile.providerVerifiedUntil);
        debugPrint('✅ CommissionsStatsViewModel: Profile loaded (Verified: $_isVerified)');
      } catch (e) {
        debugPrint('❌ CommissionsStatsViewModel: Error loading profile: $e');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ CommissionsStatsViewModel: Global Error in fetchStatsData: $e');
      _isLoading = false;
      _errorMessage = 'error_unexpected_fetch_data';
      notifyListeners();
    }
  }

  void _calculateVerificationDays(DateTime? verifiedUntil) {
    if (verifiedUntil == null) {
      _verificationDaysLeft = 0;
      return;
    }
    final now = DateTime.now();
    final difference = verifiedUntil.difference(now).inDays;
    _verificationDaysLeft = difference > 0 ? difference : 0;
  }
}
