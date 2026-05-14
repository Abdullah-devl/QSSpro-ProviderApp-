import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../../core/storage/hive_keys.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/error/api_error_handler.dart';
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
      // نستخدم FormData لضمان وصول البيانات للسيرفر بشكل صحيح
      // ونرسل الطلب كـ POST مع _method: PATCH كحل تقني متقدم
      final formData = FormData.fromMap({
        '_method': 'PATCH',
        'provider_policy': 1,
        'agreed': 1,
        'status': 1,
      });

      final response = await apiService.post(
        'policies/provider',
        data: formData,
      );
      ApiErrorHandler.handleResponse(response);
      
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
}
