// مسار الملف: lib/features/points/repositories/points_repository.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:service_provider_app/core/network/api_client.dart';
import 'package:service_provider_app/core/network/api_endpoints.dart';
import 'package:service_provider_app/core/network/error/api_error_handler.dart';
import 'package:service_provider_app/core/storage/hive_keys.dart';
import '../models/points_package_model.dart';
import '../models/points_balance_model.dart';

class PointsRepository {
  final ApiService _apiService;
  final String _packagesCacheKey = 'cached_points_packages';
  final String _balanceCacheKey = 'cached_points_balance';

  PointsRepository(this._apiService);

  // 📥 جلب باقات النقاط المتاحة (API + Hive)
  Future<List<PointsPackageModel>> getPointsPackages() async {
    var box = Hive.box(HiveKeys.settingsBox);
    try {
      final response = await _apiService.get(ApiEndpoints.getPointsPackages);

      // استخدام handleResponse لتنقية البيانات
      final data = ApiErrorHandler.handleResponse(response);

      List responseList = [];
      if (data is List) {
        responseList = data;
      } else if (data is Map && data.containsKey('packages')) {
        responseList = data['packages'];
      }

      // 💾 تحديث الكاش
      await box.put(_packagesCacheKey, responseList);

      return responseList
          .map((json) => PointsPackageModel.fromJson(json))
          .toList();
    } catch (e) {
      // 🔄 جلب من الكاش في حال الفشل
      final cachedData = box.get(_packagesCacheKey);
      if (cachedData != null) {
        final List list = List.from(cachedData);
        return list
            .map(
              (json) =>
                  PointsPackageModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
      }
      throw ApiErrorHandler.handle(e);
    }
  }

  // 📥 جلب النسخة المخزنة محلياً من باقات النقاط فوراً وبدون انتظار
  List<PointsPackageModel> getCachedPointsPackages() {
    try {
      var box = Hive.box(HiveKeys.settingsBox);
      final cachedData = box.get(_packagesCacheKey);
      if (cachedData != null) {
        final List list = List.from(cachedData);
        return list
            .map((json) => PointsPackageModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
    } catch (e) {
      // التجاهل الصامت عند غياب الكاش
    }
    return [];
  }

  // 📦 إرسال طلب اشتراك في باقة (سند دفع)
  Future<void> subscribeToPackage({
    required int packageId,
    required String bondNumber,
    required String bankName,
    required File bondImage,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'package_id': packageId.toString(),
        'bond_number': bondNumber,
        'bank_name': bankName, // ✅ تمرير اسم البنك المدخل
        'bond_image': await MultipartFile.fromFile(
          bondImage.path,
          filename: bondImage.path.split(RegExp(r'[/\\]')).last,
        ),
      });

      await _apiService.post(
        ApiEndpoints.subscribePointsPackage,
        data: formData,
      );
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  /// 💰 جلب رصيد النقاط الفعلي (نقطة 5.11) (API + Hive)
  Future<PointsBalanceModel> getPointsBalance() async {
    var box = Hive.box(HiveKeys.settingsBox);
    try {
      final response = await _apiService.get(ApiEndpoints.pointsBalance);
      // ✅ ApiErrorHandler.handleResponse already handles the 'data' unwrapping
      final data = ApiErrorHandler.handleResponse(response);
      debugPrint('🔍 PointsRepository: Raw data from handleResponse: $data');
      
      final Map<String, dynamic> responseData = Map<String, dynamic>.from(data);
      debugPrint('🔍 PointsRepository: responseData keys: ${responseData.keys.toList()}');

      // 💾 تحديث الكاش
      await box.put(_balanceCacheKey, responseData);

      final model = PointsBalanceModel.fromJson(responseData);
      debugPrint('🔍 PointsRepository: Parsed Model - Bonus: ${model.bonusPoints}, Paid: ${model.paidPoints}');
      
      return model;
    } catch (e) {

      // 🔄 جلب من الكاش في حال الفشل
      final cachedData = box.get(_balanceCacheKey);
      if (cachedData != null) {
        return PointsBalanceModel.fromJson(
          Map<String, dynamic>.from(cachedData),
        );
      }
      throw ApiErrorHandler.handle(e);
    }
  }

  // 📥 جلب النسخة المخزنة محلياً من رصيد النقاط فوراً وبدون انتظار
  PointsBalanceModel? getCachedPointsBalance() {
    try {
      var box = Hive.box(HiveKeys.settingsBox);
      final cachedData = box.get(_balanceCacheKey);
      if (cachedData != null) {
        return PointsBalanceModel.fromJson(Map<String, dynamic>.from(cachedData));
      }
    } catch (e) {
      // التجاهل الصامت عند غياب الكاش
    }
    return null;
  }

  /// 🔄 تحويل الأرباح إلى نقاط مكافأة (+1%)
  Future<void> convertPoints(double amount) async {
    try {
      await _apiService.post(
        ApiEndpoints.convertPoints,
        data: {'amount': amount},
      );
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
