import '../models/review_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/error/api_error_handler.dart';

class ReviewRepository {
  final ApiService _apiService;

  ReviewRepository(this._apiService);

  // جلب تقييمات مزود الخدمة
  Future<List<ReviewModel>> getProviderFeedback(int providerId) async {
    try {
      final response = await _apiService.get('providers/$providerId/feedback');
      
      print('🔥 Feedback Response: ${response.data}');
      
      // نفترض أن المراجعات موجودة داخل حقل 'data' أو مباشرة كمصفوفة
      final List<dynamic> data = response.data['data'] ?? response.data;
      
      return data.map((json) => ReviewModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
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
