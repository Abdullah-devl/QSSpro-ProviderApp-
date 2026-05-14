import 'package:flutter/material.dart';
import '../repositories/profile_repository.dart';
import '../models/phone_model.dart';
import '../models/bank_model.dart';

class ContactInfoViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  List<PhoneModel> phones = [];
  List<BankModel> banks = [];

  List<SystemBankModel> systemBanks = [];

  ContactInfoViewModel(this._repository) {
    fetchData();
  }

  bool isLoading = false;
  String? errorMessage;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> fetchData() async {
    // 1. 📥 تحميل الهواتف والبنوك من الكاش المحلي فوراً
    final cachedPhones = _repository.getCachedPhones();
    final cachedBanks = _repository.getCachedBanks();
    if (cachedPhones.isNotEmpty) {
      phones = cachedPhones;
    }
    if (cachedBanks.isNotEmpty) {
      banks = cachedBanks;
    }
    if (phones.isNotEmpty || banks.isNotEmpty) {
      debugPrint('⚡ ContactInfoViewModel: Loaded local phones/banks instantly from local Hive cache.');
      notifyListeners();
    }

    // 2. 🌐 التحديث في الخلفية
    isLoading = phones.isEmpty && banks.isEmpty;
    errorMessage = null;
    notifyListeners();
    
    try {
      phones = await _repository.getPhones();
    } catch (e) {
      debugPrint('Failed to fetch phones: $e');
    }

    try {
      banks = await _repository.getBanks();
    } catch (e) {
      debugPrint('Failed to fetch banks: $e');
    }

    try {
      systemBanks = await _repository.getSystemBanks();
    } catch (e) {
      debugPrint('Failed to fetch system banks: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // 📞 Phone Operations...
  Future<bool> addPhone({
    required String phone,
    required String countryCode,
    String? type,
    bool isPrimary = false,
  }) async {
    _setLoading(true);
    errorMessage = null;
    try {
      await _repository.addPhone(
        phone: phone,
        countryCode: countryCode,
        type: type,
        isPrimary: isPrimary,
      );
      await fetchData(); // تحديث القائمة بعد الإضافة
      return true;
    } catch (e) {
      errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updatePhone({
    required int id,
    required String phone,
    required String countryCode,
    String? type,
    bool isPrimary = false,
  }) async {
    _setLoading(true);
    errorMessage = null;
    try {
      await _repository.updatePhone(
        id: id,
        phone: phone,
        countryCode: countryCode,
        type: type,
        isPrimary: isPrimary,
      );
      await fetchData();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deletePhone(int id) async {
    _setLoading(true);
    errorMessage = null;
    try {
      await _repository.deletePhone(id);
      await fetchData();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // 🏦 Bank Operations
  Future<bool> addBank({
    required int bankId,
    required String bankAccount,
    bool isActive = true,
  }) async {
    _setLoading(true);
    errorMessage = null;
    try {
      await _repository.addBank(
        bankId: bankId,
        bankAccount: bankAccount,
        isActive: isActive,
      );
      await fetchData();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateBank({
    required int id,
    required int bankId,
    required String bankAccount,
    required bool isActive,
  }) async {
    _setLoading(true);
    errorMessage = null;
    try {
      await _repository.updateBank(
        id: id,
        bankId: bankId,
        bankAccount: bankAccount,
        isActive: isActive,
      );
      await fetchData();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteBank(int id) async {
    _setLoading(true);
    errorMessage = null;
    try {
      await _repository.deleteBank(id);
      await fetchData();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
