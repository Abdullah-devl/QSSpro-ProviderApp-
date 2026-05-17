// // مسار الملف: lib/features/orders/repositories/orders_repository.dart

// import '../../../core/network/api_client.dart';
// import '../../../core/network/api_endpoints.dart';
// import '../../../core/network/error/api_error_handler.dart';
// import '../models/order_model.dart';

// class OrdersRepository {
//   final ApiService _apiService;

//   OrdersRepository(this._apiService);

//   // 🚀 دالة جلب الطلبات (GET /requests)
//   Future<List<OrderModel>> getOrders() async {
//     try {
//       final response = await _apiService.get(ApiEndpoints.getOrders);
//       final data = ApiErrorHandler.handleResponse(response);

//       // السيرفر عادة يرسل القائمة داخل 'data' أو مباشرة
//       final List responseList = data['data'] ?? data;

//       return responseList.map((e) => OrderModel.fromJson(e)).toList();
//     } catch (e) {
//       throw ApiErrorHandler.handle(e);
//     }
//   }
// }
// مسار الملف: lib/features/orders/repositories/orders_repository.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/error/api_error_handler.dart';
import '../../../core/storage/hive_keys.dart';
import '../Models/order_model.dart';

class OrdersRepository {
  final ApiService _apiService;

  OrdersRepository(this._apiService);

  // دالة جلب تفاصيل طلب واحد
  Future<OrderModel> getOrderDetail(String requestId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.getOrderDetail(requestId),
      );
      final data = ApiErrorHandler.handleResponse(response);
      debugPrint('🔍 [ORDER DETAIL RESPONSE] Raw Data: $data');

      // السيرفر قد يرسل الطلب داخل مفتاح 'request' أو 'data' أو مباشرة
      final Map<String, dynamic> orderJson =
          data['request'] ?? data['data'] ?? data;

      return OrderModel.fromJson(orderJson);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // دالة جلب الطلبات (من السيرفر أو من هايف)
  Future<List<OrderModel>> getOrders() async {
    try {
      // 1. محاولة جلب البيانات الحديثة من السيرفر
      final response = await _apiService.get(ApiEndpoints.getOrders);
      final data = ApiErrorHandler.handleResponse(response);

      // 🕵️ تشخيص البيانات القادمة من السيرفر
      debugPrint('🔍 [STORAGE] Raw Data from Server: $data');

      List responseList;
      if (data is Map) {
        final rawData = data['requests'] ?? data['data'] ?? data['orders'] ?? [];
        responseList = rawData is List ? rawData : [];
      } else if (data is List) {
        responseList = data;
      } else {
        responseList = [];
      }

      // 2. 🚀 حفظ البيانات (الكاش) في هايف فور وصولها بنجاح
      var box = Hive.box(HiveKeys.ordersBox);
      await box.put('cached_orders', responseList);

      return responseList.map((e) {
        final orderMap = Map<String, dynamic>.from(e);
        return OrderModel.fromJson(orderMap);
      }).toList();
    } catch (e) {
      // 3. 🚀 في حال فشل السيرفر (لا يوجد إنترنت أو السيرفر متوقف)، نقرأ من هايف
      try {
        var box = Hive.box(HiveKeys.ordersBox);
        final cachedData = box.get('cached_orders');

        if (cachedData != null) {
          debugPrint('⚠️ فشل الاتصال بالسيرفر.. تم جلب الطلبات من الكاش (Hive)');
          final List mapData = List.from(cachedData);
          return mapData
              .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      } catch (hiveError) {
        debugPrint('❌ خطأ في قراءة الكاش: $hiveError');
      }

      // إذا فشل السيرفر ولا يوجد كاش مسبق، نعرض رسالة الخطأ للمستخدم
      throw ApiErrorHandler.handle(e);
    }
  }

  // 📥 جلب النسخة المخزنة محلياً من الطلبات فوراً وبدون انتظار
  List<OrderModel> getCachedOrders() {
    try {
      var box = Hive.box(HiveKeys.ordersBox);
      final cachedData = box.get('cached_orders');
      if (cachedData != null) {
        final List mapData = List.from(cachedData);
        return mapData
            .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (e) {
      // التجاهل الصامت
    }
    return [];
  }

  Future<void> updateOrderStatus(String requestId, String status) async {
    try {
      debugPrint('🚀 [NETWORK] Updating Status to: $status for Request ID: $requestId');
      final response = await _apiService.patch(
        ApiEndpoints.updateStatus(requestId),
        data: {'status': status},
      );
      debugPrint('🔍 [UPDATE STATUS RESPONSE] Raw Data: ${response.data}');
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      debugPrint('❌ [UPDATE STATUS ERROR]: $e');
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 إضافة مبلغ مدفوع (POST /api/requests/{id}/addAmountToMoneyPaid)
  Future<void> addPaidAmount(String requestId, double amount) async {
    try {
      final url = ApiEndpoints.addAmount(requestId);
      debugPrint('🚀 [NETWORK] Calling AddPayment API...');
      debugPrint('📍 URL: $url');
      debugPrint('📦 DATA: {"added_amount": $amount}');
      debugPrint('🆔 Request ID used in URL: $requestId');

      final response = await _apiService.post(
        url,
        data: {'added_amount': amount},
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 الإشارة إلى إنهاء العمل (PATCH /api/requests/{id}/finish)
  Future<void> finishRequest(String requestId) async {
    try {
      final response = await _apiService.patch(
        ApiEndpoints.finishRequest(requestId),
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 قبول السند
  Future<void> approveBond(String bondId) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.approveBond(bondId),
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 رفض السند
  Future<void> rejectBond(String bondId) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.rejectBond(bondId),
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 جلب بيانات حساب طالب الخدمة
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.getUserProfile(userId),
      );
      final data = ApiErrorHandler.handleResponse(response);
      debugPrint('🔍 [SEEKER PROFILE RESPONSE] Raw Data: $data');
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      debugPrint('❌ [SEEKER PROFILE ERROR]: $e');
      throw ApiErrorHandler.handle(e);
    }
  }
}
