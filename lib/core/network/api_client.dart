// // مسار الملف: lib/core/network/api_client.dart

// import 'package:dio/dio.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:service_provider_app/core/network/error/api_error_handler.dart';
// import '../storage/hive_keys.dart';
// import 'api_endpoints.dart';

// /// 📂 اسم الملف: api_client.dart
// /// 📝 الوصف: الطبقة المغلفة (Wrapper) للاتصال بالإنترنت متصلة بمعالج الأخطاء المخصص.

// class ApiClient {
//   late Dio _dio;

//   ApiClient() {
//     _dio = Dio(
//       BaseOptions(
//         baseUrl: ApiEndpoints.baseUrl,
//         receiveTimeout: const Duration(seconds: 15),
//         connectTimeout: const Duration(seconds: 15),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ),
//     );

//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) {
//           final token = Hive.box(HiveKeys.settingsBox).get(HiveKeys.tokenKey);
//           if (token != null) {
//             options.headers['Authorization'] = 'Bearer $token';
//           }
//           return handler.next(options);
//         },
//         onResponse: (response, handler) => handler.next(response),
//         onError: (DioException e, handler) => handler.next(e),
//       ),
//     );
//   }

//   // ===========================================================================
//   // 🟢 دالة الـ GET (لجلب البيانات)
//   // ===========================================================================
//   Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
//     try {
//       final response = await _dio.get(path, queryParameters: queryParameters);
//       // استخدام دالتك الذكية لتنقية البيانات والتأكد من نجاحها
//       return ApiErrorHandler.handleResponse(response);
//     } catch (e) {
//       // تمرير الخطأ لدالتك لترجمته إلى كلاس Failure ثم رميه
//       throw ApiErrorHandler.handle(e);
//     }
//   }

//   // ===========================================================================
//   // 🔵 دالة الـ POST (لإرسال البيانات)
//   // ===========================================================================
//   Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
//     try {
//       final response = await _dio.post(path, data: data, queryParameters: queryParameters);
//       // استخدام دالتك الذكية لتنقية البيانات
//       return ApiErrorHandler.handleResponse(response);
//     } catch (e) {
//       // تمرير الخطأ لدالتك لترجمته إلى كلاس Failure ثم رميه
//       throw ApiErrorHandler.handle(e);
//     }
//   }
// }

// مسار الملف: lib/core/network/api_service.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:service_provider_app/core/storage/token_storage.dart';
import 'package:service_provider_app/core/network/navigation_service.dart'; // 🌍 استيراد مفتاح التنقل
import 'dart:developer' as developer;
import 'api_endpoints.dart';


/// 📝 الوصف: المحرك الشامل للاتصال بالإنترنت (HTTP Requests).
/// يدعم جميع العمليات (GET, POST, PUT, PATCH, DELETE) مع طباعة مفصلة للـ Console.

class ApiService {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  // 🏗️ البناء (Constructor)
  ApiService(this._tokenStorage)
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Accept': 'application/json'},
        ),
      ) {
    // 🕵️ حراس الطلبات (Interceptors)
    _dio.interceptors.add(
      InterceptorsWrapper(
        // =======================================================
        // 📤 1. قبل إرسال الطلب (On Request)
        // =======================================================
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            // طباعة التوكن بشكل آمن (إخفاء معظمه)
            final displayToken = token.length > 10
                ? token.substring(token.length - 10)
                : token;
            developer.log(
              '🔑 Token Attached: ...$displayToken',
              name: 'API_REQUEST',
            );
          }

          developer.log(
            '🚀 [${options.method}] ${options.uri}',
            name: 'API_REQUEST',
          );

          // طباعة البيانات المرسلة إذا وجدت (مفيدة جداً للـ Debugging)
          if (options.data != null) {
            developer.log(
              '📦 Request Data: ${options.data}',
              name: 'API_REQUEST',
            );
          }

          return handler.next(options);
        },

        // =======================================================
        // 📥 2. عند الاستقبال بنجاح (On Response)
        // =======================================================
        onResponse: (response, handler) {
          developer.log(
            '✅ [${response.statusCode}] Response from: ${response.requestOptions.uri}',
            name: 'API_RESPONSE',
          );

          // طباعة محتوى الرد لمعرفة البيانات القادمة من السيرفر
          developer.log(
            '📄 Response Data: ${response.data}',
            name: 'API_RESPONSE',
          );

          return handler.next(response);
        },

        // =======================================================
        // ❌ 3. عند حدوث خطأ (On Error)
        // =======================================================
        onError: (DioException e, handler) {
          final statusCode = e.response?.statusCode;
          final errorData = e.response?.data;

          developer.log(
            '❌ [${statusCode ?? 'N/A'}] Error at: ${e.requestOptions.uri}',
            name: 'API_ERROR',
            error: e.message,
          );

          // 📄 طباعة كامل بيانات الرد من السيرفر لمعرفة الخطأ الحقيقي (مثلاً: حقل مفقود)
          if (errorData != null) {
            developer.log(
              '📄 Error Response Data: $errorData',
              name: 'API_ERROR',
            );
          }

          // تفصيل الأخطاء الشائعة لتسهيل حلها
            if (statusCode == 401) {
              developer.log(
                '⚠️ [401] Unauthorized - التوكن منتهي أو غير صالح. يتم التوجيه لتسجيل الدخول...',
                name: 'API_ERROR',
              );
              // 🗑️ حذف التوكن المنتهي لتجنب المحاولات الفاشلة مستقبلاً
              _tokenStorage.deleteToken();

              // 🚪 إعادة التوجيه الفوري لشاشة تسجيل الدخول ومسح كل السجلات السابقة
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/login', 
                (route) => false,
              );
            } else if (statusCode == 422) {
            developer.log(
              '⚠️ [422] Validation Error - البيانات المرسلة غير صحيحة: $errorData',
              name: 'API_ERROR',
            );
          } else if (statusCode == 403) {
            developer.log(
              '⛔ [403] Forbidden - لا تملك صلاحية لهذا الطلب: $errorData',
              name: 'API_ERROR',
            );

            // 🔒 التحقق إذا كان السبب هو سياسة الخصوصية غير الموافق عليها
            final errorMessage = errorData is Map
                ? (errorData['message']?.toString() ?? '')
                : errorData?.toString() ?? '';

            final isPolicyError = errorMessage.contains('سياسة') ||
                errorMessage.contains('policy') ||
                errorMessage.contains('الموافقة');

            if (isPolicyError) {
              developer.log(
                '📜 [403] سياسة الخصوصية غير موافق عليها - تسجيل الخروج تلقائياً...',
                name: 'API_ERROR',
              );

              // 🗑️ حذف التوكن فوراً
              _tokenStorage.deleteToken();

              // 🪟 عرض dialog يشرح السبب قبل التوجيه
              final ctx = navigatorKey.currentContext;
              if (ctx != null) {
                showDialog(
                  context: ctx,
                  barrierDismissible: false,
                  builder: (dialogCtx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: const Row(
                      children: [
                        Icon(Icons.policy_rounded,
                            color: Colors.orange, size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'تحديث سياسة الخصوصية',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                    content: const Text(
                      'قامت الإدارة بتحديث سياسة الخصوصية.\n\nيرجى تسجيل الدخول مرة أخرى والموافقة على السياسة الجديدة للمتابعة.',
                      style: TextStyle(
                          fontFamily: 'Cairo', fontSize: 14, height: 1.6),
                    ),
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.of(dialogCtx).pop();
                          // 🚪 التوجيه لشاشة تسجيل الدخول ومسح كل السجلات
                          navigatorKey.currentState?.pushNamedAndRemoveUntil(
                            '/login',
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // إذا لم يكن هناك context، نوجّه مباشرة بدون dialog
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            }
          } else if (statusCode == 500) {
            developer.log(
              '🔥 [500] Server Error - مشكلة في السيرفر نفسه',
              name: 'API_ERROR',
            );
          }

          return handler.next(e);
        },
      ),
    );
  }

  // ===========================================================================
  // 📡 دوال الطلبات الشاملة (HTTP Methods)
  // ===========================================================================

  /// 🔹 GET: لجلب البيانات
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 🔹 POST: لإرسال بيانات جديدة أو رفع ملفات (عبر Options و FormData)
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 🔹 PUT: لتحديث البيانات بالكامل
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 🔹 PATCH: لتحديث جزء محدد من البيانات (مهم جداً في بعض الـ APIs)
  Future<Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 🔹 DELETE: لحذف البيانات
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
}
