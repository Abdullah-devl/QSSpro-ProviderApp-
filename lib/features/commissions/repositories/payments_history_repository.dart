// مسار الملف: lib/features/commissions/repositories/payments_history_repository.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:service_provider_app/core/network/api_client.dart';
import 'package:service_provider_app/core/network/api_endpoints.dart';
import 'package:service_provider_app/core/network/error/api_error_handler.dart';
import 'package:service_provider_app/core/storage/hive_keys.dart';
import '../models/history_models.dart';

class PaymentsHistoryRepository {
  final ApiService _apiService;

  PaymentsHistoryRepository(this._apiService);

  /// 📦 جلب باقات النقاط المشتراة
  Future<List<PointsPackageHistoryModel>> getMyPointsPackages() async {
    return _fetchDataFromApiOrHive<PointsPackageHistoryModel>(
      endpoint: ApiEndpoints.myPointsPackages,
      cacheKey: 'cached_my_points_packages',
      fromJson: (json) => PointsPackageHistoryModel.fromJson(json),
    );
  }

  /// 🔄 جلب عمليات النقاط
  Future<List<PointsTransactionModel>> getPointsTransactions() async {
    return _fetchDataFromApiOrHive<PointsTransactionModel>(
      endpoint: ApiEndpoints.pointTransactions,
      cacheKey: 'cached_points_transactions',
      fromJson: (json) => PointsTransactionModel.fromJson(json),
    );
  }

  /// 📤 جلب طلبات السحب
  Future<List<WithdrawRequestModel>> getMyWithdrawRequests() async {
    return _fetchDataFromApiOrHive<WithdrawRequestModel>(
      endpoint: ApiEndpoints.myWithdrawRequests,
      cacheKey: 'cached_my_withdraw_requests',
      fromJson: (json) => WithdrawRequestModel.fromJson(json),
    );
  }

  /// 📄 جلب سندات الدفع
  Future<List<ProviderRequestBondModel>> getProviderRequestBonds() async {
    return _fetchDataFromApiOrHive<ProviderRequestBondModel>(
      endpoint: ApiEndpoints.providerRequestBonds,
      cacheKey: 'cached_provider_request_bonds',
      fromJson: (json) => ProviderRequestBondModel.fromJson(json),
    );
  }

  // 📥 جلب النسخة المخزنة محلياً فوراً وبدون انتظار
  List<T> getCachedList<T>(String cacheKey, T Function(Map<String, dynamic>) fromJson) {
    try {
      var box = Hive.box(HiveKeys.settingsBox);
      final cached = box.get(cacheKey);
      if (cached != null) {
        return (cached as List).map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      // التجاهل الصامت عند غياب الكاش
    }
    return [];
  }

  /// 🛠️ دالة مساعدة لتوحيد منطق جلب البيانات من السيرفر وفشل الوصول للتخزين المحلي
  Future<List<T>> _fetchDataFromApiOrHive<T>({
    required String endpoint,
    required String cacheKey,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    var box = Hive.box(HiveKeys.settingsBox);

    try {
      final response = await _apiService.get(endpoint);
      final data = ApiErrorHandler.handleResponse(response);

      List<dynamic> listJson = [];
      if (data is Map) {
         listJson = data['data'] ?? data['items'] ?? data['transactions'] ?? data['bonds'] ?? [];
      } else if (data is List) {
         listJson = data;
      }

      // 💾 تحديث الكاش لتعمل بدون إنترنت
      await box.put(cacheKey, listJson);

      return listJson.map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      // 🔄 محاولة الجلب من الكاش في حال فشل الإنترنت
      final cached = box.get(cacheKey);
      if (cached != null) {
        return (cached as List)
            .map((e) => fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      throw ApiErrorHandler.handle(e);
    }
  }
}
