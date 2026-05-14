import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'failure.dart';

/// 📂 اسم الملف: api_error_handler.dart
/// 📝 الوصف: كلاس مسؤول عن تحويل الاستثناءات إلى رسائل خطأ مفهومة (Failure)
/// ومعالجة ردود أفعال السيرفر (Response Handling).
class ApiErrorHandler {
  // ✅ الدالة المضافة لحل الخطأ الأحمر في الـ Repository
  /// 📥 معالجة الاستجابة والتأكد من نجاحها واستخراج البيانات الصافية.
  static dynamic handleResponse(Response response) {
    // التحقق من أكواد النجاح (200 أو 201)
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;

      // 🎯 منطق استخراج البيانات المركزي:
      // إذا كانت البيانات مغلفة داخل مفتاح 'data' نقوم بفكها هنا مرة واحدة لكل التطبيق
      if (data is Map && data.containsKey('data')) {
        return data['data'];
      }
      return data;
    }

    // 🛑 إذا لم تكن الاستجابة ناجحة، نقوم برمي خطأ ليتم التقاطه في catch الـ Repository
    throw handle(
      DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      ),
    );
  }

  static Failure handle(dynamic error) {
    if (error is DioException) {
      // 🛑 معالجة أخطاء Dio (مكتبة الاتصال)
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return Failure(
            'انتهت مهلة الاتصال بالخادم. يرجى التحقق من الإنترنت.',
          );
        case DioExceptionType.sendTimeout:
          return Failure('فشل إرسال البيانات. انتهت المهلة.');
        case DioExceptionType.receiveTimeout:
          return Failure('فشل استقبال البيانات. انتهت المهلة.');
        case DioExceptionType.badCertificate:
          return Failure('هناك مشكلة في شهادة الحماية (SSL).');
        case DioExceptionType.cancel:
          return Failure('تم إلغاء الطلب.');
        case DioExceptionType.connectionError:
          return Failure('لا يوجد اتصال بالإنترنت. يرجى المحاولة لاحقاً.');
        case DioExceptionType.badResponse:
          // ⚠️ السيرفر رد ولكن بـ Status Code خطأ (400, 404, 500, ...)
          return Failure(_handleBadResponse(error.response));
        case DioExceptionType.unknown:
          if (error.error is FormatException) {
            return Failure('حدث خطأ في تنسيق البيانات (Data Format Error).');
          }
          return Failure('حدث خطأ غير متوقع في الاتصال.');
      }
    } else if (error is FormatException) {
      return Failure('حدث خطأ في تنسيق البيانات.');
    } else {
      if (kDebugMode) {
        return Failure('حدث خطأ غير متوقع: $error');
      } else {
        return Failure('حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.');
      }
    }
  }

  /// 📥 معالجة الردود السيئة من السيرفر (4xx, 5xx)
  // static String _handleBadResponse(Response? response) {
  //   try {
  //     if (response != null && response.data != null) {
  //       if (response.data is Map) {
  //         if (response.data.containsKey('message')) {
  //           return response.data['message'];
  //         } else if (response.data.containsKey('error')) {
  //           return response.data['error'];
  //         }
  //       } else if (response.data is String) {
  //         return response.data;
  //       }
  //     }
  //     switch (response?.statusCode) {
  //       case 400:
  //         return 'طلب غير صالح (Bad Request).';
  //       case 401:
  //         return 'غير مصرح لك بالوصول (Unauthorized).';
  //       case 403:
  //         return 'تم رفض الوصول (Forbidden).';
  //       case 404:
  //         return 'الرابط غير موجود (Not Found).';
  //       case 500:
  //         return 'حدث خطأ في السيرفر الداخلي (Internal Server Error).';
  //       case 503:
  //         return 'الخدمة غير متوفرة حالياً (Service Unavailable).';
  //       default:
  //         return 'حدث خطأ في الاستجابة (Code: ${response?.statusCode}).';
  //     }
  //   } catch (e) {
  //     return 'حدث خطأ في قراءة رد السيرفر.';
  //   }
  // }
  /// 📥 معالجة الردود السيئة من السيرفر (4xx, 5xx)
  static String _handleBadResponse(Response? response) {
    try {
      final statusCode = response?.statusCode;

      // 🎯 1. نحاول أولاً قراءة الرسالة التفصيلية القادمة من الباك اند (سواء 400 أو 500 أو غيره)
      if (response != null && response.data != null) {
        if (response.data is Map) {
          if (response.data.containsKey('message')) {
            String message = response.data['message'];
            if (message == 'Unauthenticated.') {
              return 'الجلسة منتهية أو بيانات الدخول غير صحيحة.';
            }
            return message;
          } else if (response.data.containsKey('error')) {
            return response.data['error'];
          }
        } else if (response.data is String && response.data!.isNotEmpty) {
          if (response.data == 'Unauthenticated.') {
            return 'الجلسة منتهية أو بيانات الدخول غير صحيحة.';
          }
          return response.data!;
        }
      }

      // 🎯 2. إذا لم يرسل الباك اند رسالة، نستخدم رسائلنا المخصصة حسب الكود
      if (statusCode == 403) {
        return 'عذراً، حسابك الحالي لا يملك صلاحية (مقدم خدمة) للقيام بهذا الإجراء.';
      } else if (statusCode == 401) {
        return 'انتهت جلسة الدخول، يرجى تسجيل الدخول مجدداً.';
      } else if (statusCode == 404) {
        return 'الرابط المطلوب غير موجود (Not Found).';
      } else if (statusCode != null && statusCode >= 500) {
        return 'يوجد خلل في السيرفر حالياً (Internal Server Error).';
      }

      // 🎯 3. كود احتياطي للأخطاء الأخرى غير المعروفة
      switch (statusCode) {
        case 400:
          return 'طلب غير صالح (Bad Request).';
        case 503:
          return 'الخدمة غير متوفرة حالياً (Service Unavailable).';
        default:
          return 'حدث خطأ في الاستجابة (Code: $statusCode).';
      }
    } catch (e) {
      return 'حدث خطأ في قراءة رد السيرفر.';
    }
  }
}
