// مسار الملف: lib/features/commissions/repositories/commissions_repository.dart

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:service_provider_app/core/network/api_client.dart';
import 'package:service_provider_app/core/network/api_endpoints.dart';
import 'package:service_provider_app/core/network/error/api_error_handler.dart';
import 'package:service_provider_app/core/storage/hive_keys.dart';
import '../models/commission_model.dart';
import '../models/provider_commission_summary_model.dart';

class CommissionsRepository {
  final ApiService _apiService;
  final String _cacheKey = 'cached_commissions_data';

  CommissionsRepository(this._apiService);

  Future<CommissionDataModel> getCommissionsData() async {
    var box = Hive.box(HiveKeys.settingsBox);

    try {
      // محاولة جلب البيانات من الـ API الحقيقي
      final response = await _apiService.get(ApiEndpoints.commissions);
      final data = ApiErrorHandler.handleResponse(response);

      // التأكد من استخراج البيانات الصحيحة سواء كانت بالخارج أو داخل مفتاح 'data'
      final Map<String, dynamic> responseData = data['data'] ?? data;

      // تخزين البيانات للعمل بدون انترنت
      await box.put(_cacheKey, responseData);

      // تحويلها للنموذج
      return CommissionDataModel.fromJson(responseData);
    } catch (e) {
      // إذا فشل الاتصال، نجلب من الكاش (Hive)
      final cachedData = box.get(_cacheKey);

      if (cachedData != null) {
        final Map<String, dynamic> mapData =
            Map<String, dynamic>.from(cachedData);
        return CommissionDataModel.fromJson(mapData);
      }

      // إذا لم يكن هناك كاش، نرمي الخطأ ليعالجه الـ ViewModel
      throw ApiErrorHandler.handle(e);
    }
  }

  // دالة السداد باستخدام نقاط المكافآت لطلب محدد
  Future<void> payCommissionWithPoints(String requestId) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.payCommission(requestId),
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // دالة عامة للسداد باستخدام النقاط (قد تُستخدم لاحقاً)
  Future<void> payWithPoints(double amount) async {
    // Implementing if needed, but for now just closing the syntax.
  }

  // دالة السداد بإرفاق السند
  Future<void> payWithReceipt({
    required String requestId,
    required String bondNumber,
    required String imagePath,
    required double amount,
    String? description,
  }) async {
    try {
      final formData = FormData.fromMap({
        'request_id': requestId,
        'bond_number': bondNumber,
        'amount': amount,
        'description': description ?? '',
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });

      final response = await _apiService.post(
        ApiEndpoints.requestCommissionBonds,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  /// 📊 جلب ملخص العمولات المستحقة (نقطة 5.8) (API + Hive)
  Future<ProviderCommissionSummaryModel> getProviderCommissionSummary() async {
    var box = Hive.box(HiveKeys.settingsBox);
    final String summaryCacheKey = 'cached_provider_commission_summary';

    try {
      final response = await _apiService.get(ApiEndpoints.providerCommissionSummary);
      final data = ApiErrorHandler.handleResponse(response);
      print("==00000000 data 00000=======");
      print("==00000000$data 00000=======");
      // استخراج البيانات من مفتاح 'data' إذا وجد
      final Map<String, dynamic> responseData = data['data'] ?? data;
      print("==00000000 responseData 00000=======");
      print("==00000000$responseData 00000=======");
      // 💾 تحديث الكاش
      await box.put(summaryCacheKey, responseData);
      
      return ProviderCommissionSummaryModel.fromJson(responseData);
    } catch (e) {
      // 🔄 جلب من الكاش في حال الفشل
      final cachedData = box.get(summaryCacheKey);
      if (cachedData != null) {
        return ProviderCommissionSummaryModel.fromJson(Map<String, dynamic>.from(cachedData));
      }
      throw ApiErrorHandler.handle(e);
    }
  }

  /// 💰 جلب رصيد النقاط فقط (نقطة 5.11)
  Future<Map<String, dynamic>> getPointsBalance(int userId) async {
    try {
      final response = await _apiService.get(ApiEndpoints.pointsBalance);
      final data = ApiErrorHandler.handleResponse(response);
      return data['data'] ?? data;
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
