import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../../core/storage/hive_keys.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/error/api_error_handler.dart';
import '../../services/models/category_model.dart';
import '../models/platform_bank_account_model.dart';

class SettingsRepository {
  final ApiService apiService;

  SettingsRepository(this.apiService);

  Future<String> getProviderPolicy() async {
    try {
      final response = await apiService.get(ApiEndpoints.providerPolicy);
      
      // assuming the response format is { data: { seeker_policy: "...", provider_policy: "..." } } or just plain text/html.
      // We will extract provider_policy.
      if (response.data != null && response.data['provider_policy'] != null) {
        return response.data['provider_policy'] ?? '';
      }
      return '';
    } on DioException catch (e) {
      throw e.message ?? 'Unknown error occurred';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> acceptProviderPolicy() async {
    try {
      // 1. الموافقة على سياسة مزود الخدمة
      final providerFormData = FormData.fromMap({
        '_method': 'PATCH',
        'provider_policy': 1,
        'agreed': 1,
        'status': 1,
      });

      await apiService.post(
        ApiEndpoints.providerPolicy,
        data: providerFormData,
      );

      // 2. الموافقة على سياسة المستخدم (Seeker Policy) 
      // لأن السيرفر يتطلبها أحياناً لكل أنواع المستخدمين
      final seekerFormData = FormData.fromMap({
        '_method': 'PATCH',
        'seeker_policy': 1,
        'agreed': 1,
        'status': 1,
      });

      await apiService.post(
        ApiEndpoints.seekerPolicy,
        data: seekerFormData,
      );
      
      // ✅ نحفظ الموافقة محلياً في Hive
      var box = Hive.box(HiveKeys.settingsBox);
      await box.put('provider_policy_agreed', true);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<List<PlatformBankAccountModel>> getPlatformBankAccounts() async {
    try {
      final response = await apiService.get(ApiEndpoints.platformBankAccounts);
      final data = ApiErrorHandler.handleResponse(response);
      final List rawList = data is List ? data : (data['data'] ?? []);
      return rawList.map((e) => PlatformBankAccountModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 دالة جلب الأقسام المصرحة للمزود
  Future<List<CategoryModel>> getMyAuthorizedCategories() async {
    try {
      final response = await apiService.get(ApiEndpoints.myAuthorizedCategories);
      final data = ApiErrorHandler.handleResponse(response);
      final List responseList = data is List ? data : (data['categories'] ?? data['data'] ?? []);
      return responseList.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 دالة جلب كل الأقسام للـ Dropdown
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await apiService.get(ApiEndpoints.categories);
      final data = ApiErrorHandler.handleResponse(response);
      final List responseList = data['categories'] ?? data['data'] ?? [];
      return responseList.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 تقديم طلب قسم جديد
  Future<void> submitCategoryRequest({
    required int categoryId,
    required String description,
    required File document,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'category_id': categoryId.toString(),
        'description': description,
      });

      formData.files.add(
        MapEntry(
          'document',
          await MultipartFile.fromFile(
            document.path,
            filename: document.path.split('/').last,
          ),
        ),
      );

      final response = await apiService.post(
        ApiEndpoints.providerCategoryRequests,
        data: formData,
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
