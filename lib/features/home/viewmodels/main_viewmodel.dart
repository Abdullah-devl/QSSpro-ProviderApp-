import 'package:flutter/material.dart';
import 'package:service_provider_app/core/network/error/failure.dart';
import 'package:service_provider_app/features/home/models/home_model.dart';
import 'package:service_provider_app/features/home/repositories/home_repository.dart';

class MainViewModel extends ChangeNotifier {
  // للتحكم في شريط التنقل السفلي
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  // للتحكم في حالة مقدم الخدمة (متاح / غير متاح) كما في الزر العلوي
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  void changeTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void toggleOnlineStatus(bool value) {
    _isOnline = value;
    notifyListeners();
    // هنا مستقبلاً يمكنك إرسال طلب للـ API لتغيير حالة مقدم الخدمة
  }
}

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository;

  HomeViewModel(this._repository) {
    // جلب البيانات بمجرد بناء الشاشة
    fetchHomeData();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  HomeDataModel? _homeData;
  HomeDataModel? get homeData => _homeData;

  // جلب اسم المستخدم من الـ Repository الذي يقرأه من Hive
  String get userName => _repository.getUserName();
  String get userImage => _repository.getUserImage();

  Future<void> fetchHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _homeData = await _repository.getHomeData();
      _isLoading = false;
      notifyListeners();
    } on Failure catch (failure) {
      _isLoading = false;
      _errorMessage = failure.message;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'حدث خطأ غير متوقع أثناء جلب البيانات.';
      notifyListeners();
    }
  }
}
