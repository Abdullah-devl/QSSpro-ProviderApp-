
import 'package:service_provider_app/core/network/api_client.dart';
import 'package:service_provider_app/core/network/error/api_error_handler.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user_model.dart'; 

class AuthRepository {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;

  AuthRepository(this._apiService, this._tokenStorage);
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login, 
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = ApiErrorHandler.handleResponse(response);

      // تحويل البيانات إلى كائن باستخدام المودل الذي صنعناه
      final user = UserModel.fromJson(data);
      
      // حفظ التوكن في Hive لكي يستخدمه ApiService لاحقاً في كل الطلبات
      if (user.token.isNotEmpty) {
        await _tokenStorage.saveToken(user.token);
      }

      // إرجاع المستخدم بالكامل للـ ViewModel للتحقق من الشروط
      return user;

    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post(ApiEndpoints.logout);
      await _tokenStorage.deleteToken();
    } catch (e) {
      await _tokenStorage.deleteToken();
      throw ApiErrorHandler.handle(e);
    }
  }
}