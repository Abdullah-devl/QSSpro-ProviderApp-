import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../../../core/storage/hive_keys.dart';
import '../models/review_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/error/api_error_handler.dart';

class ReviewRepository {
  final ApiService _apiService;

  ReviewRepository(this._apiService);

  // جلب تقييمات مزود الخدمة مع التخزين في Hive
  Future<List<ReviewModel>> getProviderFeedback(int providerId) async {
    var box = Hive.box(HiveKeys.reviewsBox);
    final cacheKey = 'cached_reviews_$providerId';

    try {
      final response = await _apiService.get('providers/$providerId/feedback');
      
      debugPrint('🔥 Feedback Response: ${response.data}');
      
      // نفترض أن المراجعات موجودة داخل حقل 'data' أو مباشرة كمصفوفة
      final List<dynamic> data = response.data['data'] ?? response.data;
      
      final reviews = data.map((json) => ReviewModel.fromJson(Map<String, dynamic>.from(json))).toList();
      
      // حفظ في Hive للعمل بدون إنترنت
      await box.put(cacheKey, data);
      
      return reviews;
    } catch (e) {
      debugPrint('❌ API Error fetching reviews: $e');
      
      final cachedData = box.get(cacheKey);
      if (cachedData != null) {
        debugPrint('🌐 لا يوجد إنترنت.. تم عرض التقييمات من (Hive)');
        return (cachedData as List).map((json) => ReviewModel.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      
      throw ApiErrorHandler.handle(e);
    }
  }

  // 📥 جلب النسخة المخزنة محلياً فوراً وبدون انتظار
  List<ReviewModel> getCachedProviderFeedback(int providerId) {
    try {
      var box = Hive.box(HiveKeys.reviewsBox);
      final cachedData = box.get('cached_reviews_$providerId');
      if (cachedData != null) {
        return (cachedData as List).map((json) => ReviewModel.fromJson(Map<String, dynamic>.from(json))).toList();
      }
    } catch (e) {
      debugPrint('❌ Error reading cached reviews: $e');
    }
    return [];
  }

  // إخفاء / إظهار التقييم
  Future<bool> toggleReviewVisibility(int reviewId, bool isHidden) async {
    try {
      // API: POST /api/reviews/{id} 
      final response = await _apiService.post(
        'reviews/$reviewId',
        data: {
          'is_hidden': isHidden,
        },
      );
      // تحقق من النجاح
      final status = response.statusCode;
      return status != null && status >= 200 && status < 300;
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
