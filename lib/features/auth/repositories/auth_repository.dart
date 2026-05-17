import 'package:flutter/foundation.dart';
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
      
      // حفظ التوكن فقط كما طلبت
      if (user.token.isNotEmpty) {
        await _tokenStorage.saveToken(user.token);
      }

      // إرجاع المستخدم بالكامل للـ ViewModel للتحقق من الشروط
      return user;

    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 دالة تسجيل الدخول بجوجل
  Future<UserModel> loginWithGoogle(String googleToken) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.googleLogin,
        data: {'access_token': googleToken},
      );

      final data = ApiErrorHandler.handleResponse(response);
      final user = UserModel.fromJson(data);

      if (user.token.isNotEmpty) {
        await _tokenStorage.saveToken(user.token);
      }

      return user;
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final response = await _apiService.get('user');
      final data = ApiErrorHandler.handleResponse(response);
      return data is Map<String, dynamic> ? data : null;
    } catch (e) {
      debugPrint('AuthRepository: getUserData error: $e');
      return null;
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