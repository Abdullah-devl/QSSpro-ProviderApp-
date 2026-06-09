import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:service_provider_app/core/network/api_client.dart';
import 'package:service_provider_app/core/network/error/api_error_handler.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';
import '../../services/models/category_model.dart';
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

  // 🚀 دالة التسجيل المدمج لمزود الخدمة
  Future<UserModel> registerProvider({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required int categoryId,
    required String location,
    required String requestContent,
    required File idCard,
    String? fcmToken,
    String? deviceToken,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'category_id': categoryId.toString(),
        'location': location,
        'requestContent': requestContent,
        if (fcmToken != null) 'fcm_token': fcmToken,
        if (deviceToken != null) 'device_token': deviceToken,
      });

      formData.files.add(
        MapEntry(
          'id_card',
          await MultipartFile.fromFile(
            idCard.path,
            filename: idCard.path.split('/').last,
          ),
        ),
      );

      final response = await _apiService.post(
        ApiEndpoints.registerProvider,
        data: formData,
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

  // 🚀 دالة توثيق البريد الإلكتروني
  Future<void> verifyEmail(String email, String code) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.verifyEmail,
        data: {
          'email': email,
          'code': code,
        },
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 دالة إعادة إرسال رمز التحقق
  Future<void> resendVerificationCode(String email) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.resendVerificationCode,
        data: {
          'email': email,
        },
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 دالة جلب الفئات
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiService.get(ApiEndpoints.categories);
      final data = ApiErrorHandler.handleResponse(response);
      final List responseList = data['categories'] ?? data['data'] ?? [];
      return responseList.map((e) => CategoryModel.fromJson(e)).toList();
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