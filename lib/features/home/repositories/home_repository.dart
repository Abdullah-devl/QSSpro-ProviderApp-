// مسار الملف: lib/features/home/repositories/home_repository.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:service_provider_app/core/network/api_client.dart';
import 'package:service_provider_app/core/network/error/api_error_handler.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/hive_keys.dart'; // تأكد من مسار مفاتيح Hive لديك
import '../models/home_model.dart';
import '../models/advertisement_model.dart';

class HomeRepository {
  final ApiService _apiService;

  // مفتاح تخزين بيانات الرئيسية في Hive
  final String _homeCacheKey = 'cached_home_data';

  HomeRepository(this._apiService);

  Future<HomeDataModel> getHomeData() async {
    var box = Hive.box(HiveKeys.settingsBox);

    try {
      // 1. محاولة جلب البيانات الجديدة من السيرفر (API)
      final response = await _apiService.get(ApiEndpoints.dashboard);
      final data = ApiErrorHandler.handleResponse(response);

      // 2. تخزين البيانات (Caching) في Hive لتعمل بدون إنترنت لاحقاً
      // افترضنا أن البيانات ترجع بداخل مفتاح اسمه 'data'
      final responseData = data['data'] ?? data;
      await box.put(_homeCacheKey, responseData);

      // 3. إرجاع المودل
      return HomeDataModel.fromJson(responseData);
    } catch (e) {
      // 4. في حالة انقطاع الإنترنت أو فشل السيرفر، نحاول جلب البيانات المخزنة من Hive
      final cachedData = box.get(_homeCacheKey);

      if (cachedData != null) {
        // تحويل البيانات المخزنة إلى Map لتناسب المودل
        final mapData = Map<String, dynamic>.from(cachedData);
        return HomeDataModel.fromJson(mapData);
      }

      // إذا لم يكن هناك إنترنت ولا بيانات مخزنة مسبقاً، نرمي الخطأ للواجهة
      throw ApiErrorHandler.handle(e);
    }
  }

  // 📥 جلب النسخة المخزنة محلياً من بيانات الرئيسية فوراً وبدون انتظار
  HomeDataModel? getCachedHomeData() {
    try {
      var box = Hive.box(HiveKeys.settingsBox);
      final cachedData = box.get(_homeCacheKey);
      if (cachedData != null) {
        final mapData = Map<String, dynamic>.from(cachedData);
        return HomeDataModel.fromJson(mapData);
      }
    } catch (e) {
      // التجاهل الصامت
    }
    return null;
  }

  // دالة لجلب اسم المستخدم من Hive لكي نعرضه في الهيدر
  String getUserName() {
    var box = Hive.box(HiveKeys.settingsBox);
    return box.get('user_name', defaultValue: 'شريكنا العزيز');
  }

  // دالة لجلب صورة المستخدم من Hive
  String getUserImage() {
    var box = Hive.box(HiveKeys.settingsBox);
    return box.get('user_image', defaultValue: '');
  }

  // ==========================================
  // الإعلانات (Advertisements)
  // ==========================================

  final String _adsCacheKey = 'cached_provider_ads';

  Future<List<AdvertisementModel>> getAdvertisements() async {
    var box = Hive.box(HiveKeys.settingsBox);
    try {
      debugPrint('======================================================');
      debugPrint('🚀 📢 [ADS REQUEST] Fetching advertisements for Provider...');
      final response = await _apiService.get(ApiEndpoints.advertisements, queryParameters: {'user_type': 'provider'});
      final data = ApiErrorHandler.handleResponse(response);
      
      final List adsList;
      if (data is Map && data.containsKey('data')) {
        adsList = data['data'];
      } else if (data is List) {
        adsList = data;
      } else {
        adsList = [];
      }
      
      // 💾 حفظ الإعلانات في الكاش
      await box.put(_adsCacheKey, adsList);

      return adsList.map((e) => AdvertisementModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      debugPrint('❌ 🛑 [ADS ERROR] Failed to fetch ads: $e');
      // 🔄 محاولة الجلب من الكاش عند الفشل
      final cachedAds = box.get(_adsCacheKey);
      if (cachedAds != null) {
        final List list = List.from(cachedAds);
        return list.map((e) => AdvertisementModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      return [];
    }
  }

  // 📥 جلب الإعلانات المخزنة محلياً فوراً
  List<AdvertisementModel> getCachedAdvertisements() {
    try {
      var box = Hive.box(HiveKeys.settingsBox);
      final cachedAds = box.get(_adsCacheKey);
      if (cachedAds != null) {
        final List list = List.from(cachedAds);
        return list.map((e) => AdvertisementModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      // التجاهل الصامت
    }
    return [];
  }

  Future<void> trackAdView(int adId) async {
    try {
      await _apiService.post(ApiEndpoints.adView(adId));
    } catch (e) {
      debugPrint('Error tracking ad view: $e');
    }
  }

  Future<void> trackAdClick(int adId) async {
    try {
      await _apiService.post(ApiEndpoints.adClick(adId));
    } catch (e) {
      debugPrint('Error tracking ad click: $e');
    }
  }
}

// دالة مساعدة لتسهيل طباعة الأخطاء في المستودع
void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
