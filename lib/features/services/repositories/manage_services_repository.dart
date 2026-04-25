// مسار الملف: lib/features/services/repositories/manage_services_repository.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:service_provider_app/core/network/api_client.dart';
import 'package:service_provider_app/core/network/api_endpoints.dart';
import 'package:service_provider_app/core/network/error/api_error_handler.dart';
import 'package:service_provider_app/features/services/models/category_model.dart';
import 'package:service_provider_app/features/services/models/service_details_model.dart';
// import 'package:service_provider_app/features/services/models/service_list_model.dart';
import '../../../core/storage/hive_keys.dart';
import '../models/manage_services_model.dart';
// أضف هذا الاستيراد في أعلى الملف لرفع الملفات
import 'package:dio/dio.dart';
import 'dart:io';
// import 'dart:convert';
import '../models/service_schedule_model.dart';

class ManageServicesRepository {
  final ApiService _apiService;
  final String _cacheKey = 'cached_manage_services';

  ManageServicesRepository(this._apiService);

  Future<List<ServiceModel>> getServices() async {
    var box = Hive.box(HiveKeys.settingsBox);

    try {
      // 1. جلب البيانات من الـ API (استبدل 'provider/services' بالرابط الفعلي لديك)
      final response = await _apiService.get(ApiEndpoints.myServices);
      final data = ApiErrorHandler.handleResponse(response);

      // // 2. تحويل البيانات وتخزينها في Hive لتعمل بدون إنترنت
      // final List responseList = data['data'] ?? data;
      List responseList = [];
      if (data is List) {
        responseList = data; // إذا كانت مصفوفة مباشرة نأخذها كما هي
      } else if (data is Map) {
        responseList =
            data['data'] ??
            data['services'] ??
            []; // إذا كانت Map نبحث عن المفتاح
      }

      await box.put(_cacheKey, responseList);

      // 3. إرجاع المودل
      return responseList.map((e) => ServiceModel.fromJson(e)).toList();
    } catch (e) {
      // 4. في حال فشل السيرفر أو انقطاع النت، نجلب من Hive
      final cachedData = box.get(_cacheKey);

      if (cachedData != null) {
        final List mapData = List.from(cachedData);
        return mapData
            .map((e) => ServiceModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 دالة إضافة خدمة جديدة (POST /services)
  Future<ServiceDetailsModel> createService({
    required String name,
    required String description,
    required double price,
    required int categoryId,
    required int requiredPartialPercent,
    bool distanceBasedPrice = false,
    double pricePerKm = 0.0,
    List<ServiceScheduleModel>? schedules,
    File? imageFile,
  }) async {
    try {
      // تجهيز البيانات كـ FormData لرفع الصورة مع النصوص
      FormData formData = FormData.fromMap({
        "name": name,
        "description": description,
        "price": price.toString(),
        "category_id": categoryId.toString(),
        "status": "available", // قيمة افتراضية حسب وثيقة الباك اند
        "is_available": "1",
        "is_active": "1",
        "distance_based_price": (distanceBasedPrice ? 1 : 0).toString(),
        "price_per_km": pricePerKm.toString(),
        "required_partial_percentage": requiredPartialPercent.toString(),
      });

      // إضافة الجداول الزمنية إذا وجدت
      if (schedules != null && schedules.isNotEmpty) {
        for (int i = 0; i < schedules.length; i++) {
          final schedule = schedules[i];
          formData.fields.addAll([
            MapEntry(
              "schedules[$i][start_time]",
              schedule.startTime.toString(),
            ),
            MapEntry("schedules[$i][end_time]", schedule.endTime.toString()),
            MapEntry("schedules[$i][is_active]", schedule.isActive ? "1" : "0"),
          ]);
          for (int j = 0; j < schedule.days.length; j++) {
            formData.fields.add(
              MapEntry(
                "schedules[$i][days][$j]",
                schedule.days[j].toLowerCase(),
              ),
            );
          }
        }
      }

      // إضافة الصورة إذا قام المستخدم باختيارها
      if (imageFile != null) {
        formData.files.add(
          MapEntry(
            "image_path", // نفس الاسم المطلوب في الوثيقة
            await MultipartFile.fromFile(
              imageFile.path,
              filename: imageFile.path.split('/').last,
            ),
          ),
        );
      }

      // إرسال الطلب (التوكن يتم إرفاقه تلقائياً)
      final response = await _apiService.post(
        ApiEndpoints.myServices,
        data: formData,
      );
      final data = ApiErrorHandler.handleResponse(response);
      return ServiceDetailsModel.fromJson(data);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // مفتاح تخزين الفئات
  final String _categoriesCacheKey = 'cached_main_categories';

  // 🚀 دالة جلب الفئات الرئيسية (GET /categories/main)
  Future<List<CategoryModel>> getMainCategories() async {
    var box = Hive.box(HiveKeys.settingsBox);

    try {
      final response = await _apiService.get(ApiEndpoints.mainCategories);
      final data = ApiErrorHandler.handleResponse(response);

      // final List responseList = data['data'] ?? data;
      final List responseList = data['categories'] ?? data['data'] ?? [];
      // تخزينها في Hive
      await box.put(_categoriesCacheKey, responseList);

      return responseList.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      // قراءة من Hive في حال عدم وجود إنترنت
      final cachedData = box.get(_categoriesCacheKey);
      if (cachedData != null) {
        final List mapData = List.from(cachedData);
        return mapData
            .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 دالة جلب الخدمات المخصصة
  Future<List<ServiceModel>> getCustomServices(dynamic userId) async {
    try {
      final response = await _apiService.get(ApiEndpoints.getCustomService(userId));
      final data = ApiErrorHandler.handleResponse(response);
      
      if (data is Map) {
        return [ServiceModel.fromJson(Map<String, dynamic>.from(data))];
      } else if (data is List) {
        return data.map((e) => ServiceModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 دالة جلب خدمات الحضور
  Future<List<ServiceModel>> getMeetingServices(dynamic userId) async {
    try {
      final response = await _apiService.get(ApiEndpoints.getMeetingService(userId));
      final data = ApiErrorHandler.handleResponse(response);
      
      if (data is Map) {
        return [ServiceModel.fromJson(Map<String, dynamic>.from(data))];
      } else if (data is List) {
        return data.map((e) => ServiceModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 دالة جلب تفاصيل خدمة واحدة (GET /services/{id}) (API + Hive)
  Future<ServiceDetailsModel> getServiceDetails(int id) async {
    var box = Hive.box(HiveKeys.settingsBox);
    final String detailsCacheKey = 'cached_service_details_$id';

    try {
      final response = await _apiService.get('${ApiEndpoints.myServices}/$id');
      final data = ApiErrorHandler.handleResponse(response);

      // عادة السيرفر يرسل التفاصيل داخل 'data' أو مباشرة
      final Map<String, dynamic> responseData = data['data'] ?? data;

      // 💾 تحديث الكاش
      await box.put(detailsCacheKey, responseData);

      return ServiceDetailsModel.fromJson(responseData);
    } catch (e) {
      // 🔄 جلب من الكاش في حال الفشل
      final cachedData = box.get(detailsCacheKey);
      if (cachedData != null) {
        return ServiceDetailsModel.fromJson(
          Map<String, dynamic>.from(cachedData),
        );
      }
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 دالة إضافة خدمة فرعية (POST /services/child)
  Future<void> createSubService({
    required int parentId,
    required String name,
    required double price,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.childServices,
        data: {
          "parent_service_id": parentId,
          "name": name,
          "price": price,
          "description": "", // نتركه فارغاً كما طلب الباك اند (nullable)
        },
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 دالة حذف الخدمة (DELETE /services/{id})
  Future<void> deleteService(int id) async {
    try {
      final response = await _apiService.delete(
        '${ApiEndpoints.myServices}/$id',
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 دالة تحديث بيانات الخدمة (POST مع خدعة _method=PUT لارافيل)
  Future<void> updateService({
    required int serviceId,
    String? name,
    String? description,
    double? price,
    int? categoryId,
    int? requiredPartialPercent,
    bool? isActive,
    bool distanceBasedPrice = false,
    double pricePerKm = 0.0,
    List<ServiceScheduleModel>? schedules,
    File? imageFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "_method": "PUT",
        if (name != null) "name": name,
        if (description != null) "description": description,
        if (price != null) "price": price.toString(),
        if (categoryId != null) "category_id": categoryId.toString(),
        if (requiredPartialPercent != null)
          "required_partial_percentage": requiredPartialPercent.toString(),
        if (isActive != null) "is_active": (isActive ? 1 : 0).toString(),
        "distance_based_price": (distanceBasedPrice ? 1 : 0).toString(),
        "price_per_km": pricePerKm.toString(),
      });

      // إضافة الجداول الزمنية لتعديلها
      if (schedules != null && schedules.isNotEmpty) {
        print("========$schedules");
        for (int i = 0; i < schedules.length; i++) {
          final schedule = schedules[i];
          if (schedule.days.isNotEmpty) {
            formData.fields.add(
              MapEntry("schedules[$i][start_time]", schedule.startTime),
            );
            formData.fields.add(
              MapEntry("schedules[$i][end_time]", schedule.endTime),
            );
            formData.fields.add(
              MapEntry(
                "schedules[$i][is_active]",
                schedule.isActive ? "1" : "0",
              ),
            );
            if (schedule.label != null) {
              formData.fields.add(
                MapEntry("schedules[$i][label]", schedule.label!),
              );
            }
            if (schedule.id != null) {
              formData.fields.add(
                MapEntry("schedules[$i][id]", schedule.id.toString()),
              );
            }
            for (int j = 0; j < schedule.days.length; j++) {
              formData.fields.add(
                MapEntry(
                  "schedules[$i][days][$j]",
                  schedule.days[j].toLowerCase(),
                ),
              );
            }
          }
        }
      }

      if (imageFile != null) {
        formData.files.add(
          MapEntry(
            "image_path",
            await MultipartFile.fromFile(
              imageFile.path,
              filename: imageFile.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _apiService.post(
        '${ApiEndpoints.myServices}/$serviceId',
        data: formData,
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // ==========================================
  // إدراة مواعيد الخدمة (Schedules CRUD)
  // ==========================================

  // إضافة موعد جديد
  Future<void> addServiceSchedule({
    required int serviceId,
    required String startTime,
    required String endTime,
    required List<String> days,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiEndpoints.myServices}/schedules',
        data: {
          "service_id": serviceId,
          "start_time": startTime,
          "end_time": endTime,
          "days": days.map((d) => d.toLowerCase()).toList(),
        },
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // تعديل موعد موجود
  Future<void> updateServiceSchedule({
    required int scheduleId,
    required String startTime,
    required String endTime,
    required List<String> days,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiEndpoints.myServices}/schedules/$scheduleId',
        data: {
          "start_time": startTime,
          "end_time": endTime,
          "days": days.map((d) => d.toLowerCase()).toList(),
        },
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // حذف موعد
  Future<void> deleteServiceSchedule(int scheduleId) async {
    try {
      final response = await _apiService.delete(
        '${ApiEndpoints.myServices}/schedules/$scheduleId',
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 دالة تحديث الخدمات التلقائية (Meeting/Custom) باستخدام PUT
  Future<void> updateSpecialService({
    required bool isCustom,
    required bool isActive,
    double? price,
  }) async {
    try {
      final endpoint = isCustom ? ApiEndpoints.updateCustomService : ApiEndpoints.updateMeetingService;
      final response = await _apiService.put(
        endpoint,
        data: {
          "is_active": isActive ? 1 : 0,
          if (price != null) "price": price,
        },
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
