// مسار الملف: lib/features/home/repositories/home_repository.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:service_provider_app/core/network/api_client.dart';
import 'package:service_provider_app/core/network/error/api_error_handler.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/hive_keys.dart'; // تأكد من مسار مفاتيح Hive لديك
import '../models/home_model.dart';

class HomeRepository {
  final ApiService _apiService;

  // مفتاح تخزين بيانات الرئيسية في Hive
  final String _homeCacheKey = 'cached_home_data';

  HomeRepository(this._apiService);

  Future<HomeDataModel> getHomeData() async {
    var box = Hive.box(HiveKeys.settingsBox);

    try {
      // 1. محاولة جلب البيانات الجديدة من السيرفر (API)
      final response = await _apiService.get(ApiEndpoints.getHomeData);
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
}
