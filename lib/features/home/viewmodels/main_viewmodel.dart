import 'package:flutter/material.dart';
import 'package:service_provider_app/core/network/error/failure.dart';
import 'package:service_provider_app/features/home/models/home_model.dart';
import 'package:service_provider_app/features/home/repositories/home_repository.dart' hide debugPrint;
import 'package:service_provider_app/features/home/models/advertisement_model.dart';
import 'package:url_launcher/url_launcher.dart';

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
    fetchAds();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  HomeDataModel? _homeData;
  HomeDataModel? get homeData => _homeData;

  // الإعلانات
  List<AdvertisementModel> _carouselAds = [];
  List<AdvertisementModel> get carouselAds => _carouselAds;

  AdvertisementModel? _popupAd;
  AdvertisementModel? get popupAd => _popupAd;

  // جلب اسم المستخدم من الـ Repository الذي يقرأه من Hive
  String get userName => _repository.getUserName();
  String get userImage => _repository.getUserImage();

  bool _hasFetchedOnce = false;

  Future<void> fetchHomeData() async {
    // 1. 📥 تحميل الكاش المحلي مسبقاً ليكون جاهزاً للعرض الفوري في حال تعطل الإنترنت
    final cachedHome = _repository.getCachedHomeData();
    if (cachedHome != null) {
      _homeData = cachedHome;
    }
    final cachedAds = _repository.getCachedAdvertisements();
    if (cachedAds.isNotEmpty) {
      _carouselAds = cachedAds.where((ad) => ad.type == 'carousel' || ad.type == 'section').toList();
      final popups = cachedAds.where((ad) => ad.type == 'popup').toList();
      _popupAd = popups.isNotEmpty ? popups.first : null;
    }

    // 2. ⚡ تفعيل الشيمر في بداية تشغيل التطبيق فقط لهذه الجلسة
    if (!_hasFetchedOnce) {
      _isLoading = true;
      _hasFetchedOnce = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      debugPrint('Fetching home data and ads from server...');
      _homeData = await _repository.getHomeData();
      await fetchAds(); // نضمن استدعاء الإعلانات الحية من السيرفر
      _isLoading = false;
      notifyListeners();
    } on Failure catch (failure) {
      _isLoading = false;
      if (_homeData == null) {
        _errorMessage = failure.message;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error in fetchHomeData: $e');
      _isLoading = false;
      if (_homeData == null) {
        _errorMessage = 'حدث خطأ غير متوقع أثناء جلب البيانات.';
      }
      notifyListeners();
    }
  }

  Future<void> fetchAds() async {
    debugPrint('Starting fetchAds from server...');
    final ads = await _repository.getAdvertisements();
    debugPrint('Ads fetched from server: ${ads.length}');
    
    // فلترة الإعلانات: ندمج إعلانات الكاروسيل والأقسام معاً في السلايدر الرئيسي بناءً على طلبك
    _carouselAds = ads.where((ad) => ad.type == 'carousel' || ad.type == 'section').toList();
    
    // نأخذ أول إعلان بوب أب متاح
    final popups = ads.where((ad) => ad.type == 'popup').toList();
    _popupAd = popups.isNotEmpty ? popups.first : null;
    
    notifyListeners();
  }

  void trackAdView(int id) {
    _repository.trackAdView(id);
  }

  Future<void> handleAdClick(BuildContext context, AdvertisementModel ad) async {
    _repository.trackAdClick(ad.id);

    switch (ad.targetType) {
      case 'service':
        if (ad.targetId != null) {
          Navigator.pushNamed(context, '/service-details', arguments: ad.targetId);
        }
        break;
      case 'category':
        if (ad.targetId != null) {
          Navigator.pushNamed(context, '/category-services', arguments: ad.targetId);
        }
        break;
      case 'external':
        if (ad.externalLink != null) {
          final uri = Uri.parse(ad.externalLink!);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
        break;
      case 'none':
      default:
        break;
    }
  }

  void clearPopup() {
    _popupAd = null;
    notifyListeners();
  }
}
