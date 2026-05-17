// مسار الملف: lib/features/profile/repositories/profile_repository.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart'; // 🚀 استيراد Hive
import 'package:service_provider_app/core/network/api_client.dart';
import '../../../../core/storage/hive_keys.dart'; // مسار مفاتيح الهايڤ
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/error/api_error_handler.dart';
import '../models/profile_model.dart';
import '../models/work_model.dart'; // 🚀 استيراد مودل الأعمال
import '../models/service_model.dart'; // استيراد مودل الخدمات
import '../models/phone_model.dart';
import '../models/bank_model.dart';

class ProfileRepository {
  final ApiService _apiService;

  // مفتاح تخزين البروفايل في الهايڤ
  final String _profileCacheKey = 'cached_my_profile';

  ProfileRepository(this._apiService);

  // 📥 جلب البروفايل (API + Hive)
  Future<ProfileModel> getMyProfile() async {
    var box = Hive.box(HiveKeys.settingsBox); // نفتح صندوق التخزين

    try {
      final response = await _apiService.get(ApiEndpoints.myProfile);
      final data = ApiErrorHandler.handleResponse(response);

      Map<String, dynamic> finalMap = {};

      if (data is Map<String, dynamic> && data.containsKey('profile')) {
        finalMap = Map<String, dynamic>.from(data['profile']);
      } else if (data is Map<String, dynamic>) {
        finalMap = data;
      }

      if (finalMap.isEmpty) throw 'البيانات المستلمة فارغة';

      // 🚨 ترقيع هام (Patch): الباك إند لا يرسل provider_policy في مسار my-profile!
      // لذلك نعتمد على القيمة المخزنة محلياً إذا لم نجدها في الاستجابة.
      final box = Hive.box(HiveKeys.settingsBox);
      bool localPolicyAgreed = box.get('provider_policy_agreed', defaultValue: false);
      
      if (!finalMap.containsKey('user')) {
        finalMap['user'] = {};
      }
      // إذا كانت القيمة غير موجودة في الـ API، نستخدم القيمة المحلية
      if (finalMap['user']['provider_policy'] == null) {
        finalMap['user']['provider_policy'] = localPolicyAgreed ? 1 : 0;
      } else {
        // إذا أرسلها الباك إند فعلاً، نحدث الكاش المحلي
        bool apiPolicy = finalMap['user']['provider_policy'] == 1 || finalMap['user']['provider_policy'] == true || finalMap['user']['provider_policy'] == '1';
        await box.put('provider_policy_agreed', apiPolicy);
      }

      debugPrint('🔍 ProfileRepository: finalMap keys: ${finalMap.keys.toList()}');
      debugPrint('🔍 ProfileRepository: job_title in finalMap: ${finalMap['profile']?['job_title']}');

      // 💾 التخزين في Hive ليعمل التطبيق بدون إنترنت
      await box.put(_profileCacheKey, finalMap);

      final model = ProfileModel.fromJson(finalMap);
      debugPrint('🔍 ProfileRepository: Parsed jobTitle: ${model.jobTitle}');
      return model;
    } catch (e) {
      print('❌ API Error: $e');

      // 🔄 في حال فشل الاتصال بالسيرفر، نبحث عن آخر نسخة محفوظة في Hive
      final cachedData = box.get(_profileCacheKey);

      if (cachedData != null) {
        print('🌐 لا يوجد إنترنت.. تم عرض البروفايل من (Hive)');
        return ProfileModel.fromJson(Map<String, dynamic>.from(cachedData));
      }

      throw ApiErrorHandler.handle(e);
    }
  }

  // 📥 جلب النسخة المخزنة محلياً من البروفايل فوراً وبدون انتظار
  ProfileModel? getCachedProfile() {
    try {
      var box = Hive.box(HiveKeys.settingsBox);
      final cachedData = box.get(_profileCacheKey);
      if (cachedData != null) {
        return ProfileModel.fromJson(Map<String, dynamic>.from(cachedData));
      }
    } catch (e) {
      debugPrint('❌ Error reading cached profile: $e');
    }
    return null;
  }

  // 🚀 دالة تحديث الملف الشخصي
  Future<void> updateProfile({
    required int id,
    String? name,
    required String jobTitle,
    required String bio,
    required bool isAvailable,
    File? avatar,
    double? latitude,
    double? longitude,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        '_method': 'PUT',
        if (name != null) 'name': name,
        'job_title': jobTitle, // Fixed from job-title
        'job-title': jobTitle, // Added both to be safe
        'bio': bio,
        'is_available': isAvailable ? 1 : 0,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      });

      if (avatar != null) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              avatar.path,
              filename: avatar.path.split('/').last,
            ),
          ),
        );
      }

      debugPrint('🚀 ProfileRepository: Updating Profile ID: $id');
      debugPrint('🚀 ProfileRepository: FormData fields: ${formData.fields}');

      // 🚀 نرسل التحديث لرابط البروفايل في لارافل
      final response = await _apiService.post('profiles/$id', data: formData);
      debugPrint('✅ ProfileRepository: Update Response: ${response.data}');

      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      debugPrint('❌ ProfileRepository: Update Error: $e');
      throw ApiErrorHandler.handle(e);
    }
  }

  // lib/features/profile/repositories/profile_repository.dart

  // 📥 جلب الأعمال السابقة مع التخزين في Hive
  Future<List<WorkModel>> getPreviousWorks() async {
    var box = Hive.box(HiveKeys.worksBox); // افترضنا وجود صندوق للأعمال
    try {
      final response = await _apiService.get('previous-work');
      final data = ApiErrorHandler.handleResponse(response);

      List<dynamic> worksJson = [];
      if (data is Map) {
        worksJson =
            data['works'] ??
            data['data'] ??
            data['previous_works'] ??
            data['previousWorks'] ??
            [];
      } else if (data is List) {
        worksJson = data;
      }

      List<WorkModel> works = worksJson
          .map((e) => WorkModel.fromJson(e))
          .toList();

      // تخزين في Hive
      await box.put('cached_works', worksJson);
      return works;
    } catch (e) {
      final cached = box.get('cached_works');
      if (cached != null) {
        return (cached as List)
            .map((e) => WorkModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      throw ApiErrorHandler.handle(e);
    }
  }

  // 📥 جلب النسخة المخزنة محلياً من الأعمال السابقة فوراً وبدون انتظار
  List<WorkModel> getCachedPreviousWorks() {
    try {
      var box = Hive.box(HiveKeys.worksBox);
      final cached = box.get('cached_works');
      if (cached != null) {
        return (cached as List)
            .map((e) => WorkModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('❌ Error reading cached works: $e');
    }
    return [];
  }

  // 📥 جلب خدمات المزود الأساسية
  Future<List<ServiceModel>> getServices() async {
    var box = Hive.box(HiveKeys.servicesBox); // 🛠️ صندوق الخدمات
    try {
      final response = await _apiService.get('services');
      final data = ApiErrorHandler.handleResponse(response);

      debugPrint('🔍 Services API Response type: ${data.runtimeType}');
      debugPrint('🔍 Services API Response: $data');

      List<dynamic> servicesJson = [];
      if (data is Map) {
        servicesJson = data['services'] ?? data['data'] ?? [];
      } else if (data is List) {
        servicesJson = data;
      }

      debugPrint('🔍 Services parsed count: ${servicesJson.length}');
      if (servicesJson.isNotEmpty) {
        debugPrint(
          '🔍 First service keys: ${servicesJson.first is Map ? (servicesJson.first as Map).keys.toList() : "NOT A MAP"}',
        );
      }

      List<ServiceModel> services = servicesJson
          .map((e) => ServiceModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // 💾 التخزين في Hive ليعمل التطبيق بدون إنترنت
      await box.put('cached_services', servicesJson);

      return services;
    } catch (e) {
      debugPrint('❌ ProfileRepository getServices error: $e');

      // 🔄 في حال فشل الاتصال بالسيرفر، نبحث عن آخر نسخة محفوظة في Hive
      final cached = box.get('cached_services');
      if (cached != null) {
        debugPrint('🌐 لا يوجد إنترنت.. تم عرض الخدمات من (Hive)');
        return (cached as List)
            .map((e) => ServiceModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      throw ApiErrorHandler.handle(e);
    }
  }

  // 📥 جلب النسخة المخزنة محلياً من الخدمات فوراً وبدون انتظار
  List<ServiceModel> getCachedServices() {
    try {
      var box = Hive.box(HiveKeys.servicesBox);
      final cached = box.get('cached_services');
      if (cached != null) {
        return (cached as List)
            .map((e) => ServiceModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('❌ Error reading cached services: $e');
    }
    return [];
  }

  // 🚀 دالة تفعيل/إلغاء تفعيل الخدمة
  Future<void> toggleServiceStatus(int serviceId, bool isActive) async {
    try {
      // نرسل الطلب للباك إند
      // ملاحظة: المسار قد يحتاج تعديل بناءً على توثيق الباك إند
      await _apiService.post('services/$serviceId', data: {
        '_method': 'PUT',
        'is_active': isActive ? 1 : 0,
      });
      
      debugPrint('✅ Service $serviceId status updated to: $isActive');
    } catch (e) {
      debugPrint('❌ Error toggling service status: $e');
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 رفع عمل جديد
  Future<void> uploadWork({
    required String title,
    required String desc,
    required File image,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'title': title,
        'description': desc,
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      });
      await _apiService.post('previous-work', data: formData);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 تعديل عمل سابق
  // Future<void> updateWork({
  //   required int id,
  //   required String title,
  //   required String desc,
  //   File? image, // اختياري في حالة التعديل
  // }) async {
  //   try {
  //     Map<String, dynamic> map = {
  //       '_method': 'PUT',
  //       'title': title,
  //       'description': desc,
  //     };

  //     if (image != null) {
  //       map['image'] = await MultipartFile.fromFile(
  //         image.path,
  //         filename: image.path.split('/').last,
  //       );
  //     }

  //     FormData formData = FormData.fromMap(map);
  //     await _apiService.post('previous-work/$id?_method=PUT', data: formData);
  //   } catch (e) {
  //     debugPrint('❌ خطأ في قراءة الكاش: $e');
  //     throw ApiErrorHandler.handle(e);
  //   }
  // }
  // 🚀 تعديل عمل سابق - النسخة النهائية المستقرة
  // Future<void> updateWork({
  //   required int id,
  //   required String title,
  //   required String desc,
  //   File? image,
  // }) async {
  //   try {
  //     Map<String, dynamic> map = {
  //       '_method': 'PUT', // 👈 لارافل سيعتمد على هذه لتحديد نوع الطلب
  //       'title': title,
  //       'description': desc,
  //     };

  //     if (image != null) {
  //       map['image'] = await MultipartFile.fromFile(
  //         image.path,
  //         filename: image.path.split('/').last,
  //       );
  //     }

  //     FormData formData = FormData.fromMap(map);

  //     // ✅ الرابط أصبح نظيفاً تماماً بدون علامات استفهام
  //     await _apiService.post('previous-work/$id', data: formData);
  //   } catch (e) {
  //     debugPrint('❌ خطأ في التحديث: $e');
  //     throw ApiErrorHandler.handle(e);
  //   }
  // }

  Future<void> updateWork({
    required int id,
    required String title,
    required String desc,
    File? image,
  }) async {
    try {
      // 1. نجهز البيانات مع مفتاح التعديل الخاص بلارافل
      Map<String, dynamic> map = {
        '_method': 'PUT', // 🚀 هذه هي كلمة السر
        'title': title,
        'description': desc,
      };

      // 2. إضافة الصورة فقط إذا تم اختيارها
      if (image != null) {
        map['image'] = await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(map);

      // 3. نرسل الطلب POST لرابط "نظيف" بدون علامات استفهام
      // ✅ لاحظ الرابط: لا يوجد به ?_method=PUT
      await _apiService.post('previous-work/$id', data: formData);
    } catch (e) {
      debugPrint('❌ خطأ في التعديل: $e');
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 حذف عمل سابق
  Future<void> deleteWork(int id) async {
    try {
      await _apiService.delete('previous-work/$id');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // ========================================================
  // 📞 عمليات إدارة أرقام التواصل (Phones)
  // ========================================================

  Future<List<PhoneModel>> getPhones() async {
    var box = Hive.box(HiveKeys.phonesBox);
    try {
      final response = await _apiService.get('profile-phones');
      debugPrint(
        '📞 Phones GET Response: ${response.data}',
      ); // للطباعة بناءً على طلبك

      final data = ApiErrorHandler.handleResponse(response);
      List<dynamic> list = [];

      if (data is Map) {
        // البحث عن المفتاح الذي يحتوي القائمة لأن الباك إند قد يستخدم مسميات مختلفة
        list =
            data['data'] ??
            data['phones'] ??
            data['profile_phones'] ??
            data['profilePhones'] ??
            [];
      } else if (data is List) {
        list = data;
      }

      List<PhoneModel> phones = list
          .map((e) => PhoneModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // حفظ البيانات في Hive للعمل بدون إنترنت
      await box.put('cached_phones', list);
      return phones;
    } catch (e) {
      debugPrint('❌ خطأ في جلب أرقام الهواتف: $e');

      // جلب من التخزين المحلي في حال فشل السيرفر
      final cached = box.get('cached_phones');
      if (cached != null) {
        debugPrint('🌐 تم عرض أرقام الهواتف من (Hive)');
        return (cached as List)
            .map((e) => PhoneModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      throw ApiErrorHandler.handle(e);
    }
  }

  // 📥 جلب النسخة المخزنة محلياً من أرقام التواصل فوراً وبدون انتظار
  List<PhoneModel> getCachedPhones() {
    try {
      var box = Hive.box(HiveKeys.phonesBox);
      final cached = box.get('cached_phones');
      if (cached != null) {
        return (cached as List)
            .map((e) => PhoneModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('❌ Error reading cached phones: $e');
    }
    return [];
  }

  // .. (other phone methods are intact)

  Future<void> addPhone({
    required String phone,
    required String countryCode,
    String? type,
    bool isPrimary = false,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'phone': phone,
        'country_code': countryCode,
        if (type != null) 'type': type,
        'is_primary': isPrimary ? 1 : 0, // Laravel API boolean standard
      });

      final response = await _apiService.post('profile-phones', data: formData);
      debugPrint('📞 Phones POST Response: ${response.data}');
    } catch (e) {
      debugPrint('❌ خطأ في إضافة رقم هاتف: $e');
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> updatePhone({
    required int id,
    required String phone,
    required String countryCode,
    String? type,
    bool isPrimary = false,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        '_method': 'PUT',
        'phone': phone,
        'country_code': countryCode,
        if (type != null) 'type': type,
        'is_primary': isPrimary ? 1 : 0,
      });

      final response = await _apiService.post(
        'profile-phones/$id',
        data: formData,
      );
      debugPrint('📞 Phones PUT Response: ${response.data}');
    } catch (e) {
      debugPrint('❌ خطأ في تحديث رقم الهاتف: $e');
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> deletePhone(int id) async {
    try {
      await _apiService.delete('profile-phones/$id');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // ========================================================
  // 🏦 عمليات إدارة الحسابات البنكية (Banks)
  // ========================================================

  Future<List<SystemBankModel>> getSystemBanks() async {
    try {
      final response = await _apiService.get('banks');
      debugPrint('🏦 System Banks (5.1) GET Response: ${response.data}');
      if (response.statusCode == 200) {
        final data = ApiErrorHandler.handleResponse(response);
        List<dynamic> list = [];
        if (data is Map) {
          list = data['data'] ?? data['banks'] ?? [];
        } else if (data is List) {
          list = data;
        }
        return list
            .map((e) => SystemBankModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ خطأ في جلب البنوك الأساسية 5.1: $e');
      return [];
    }
  }

  Future<List<BankModel>> getBanks() async {
    var box = Hive.box(HiveKeys.banksBox);
    try {
      final response = await _apiService.get('user-bank');
      debugPrint('🏦 Banks GET Response STATUS: ${response.statusCode}');
      debugPrint('🏦 Banks GET Response DATA: ${response.data}');

      final data = ApiErrorHandler.handleResponse(response);
      debugPrint('🏦 Banks parsed data type: ${data.runtimeType}');
      debugPrint('🏦 Banks parsed data: $data');

      List<dynamic> list = [];

      if (data is Map) {
        debugPrint('🏦 Banks MAP keys: ${data.keys.toList()}');

        // استخراج القائمة بطريقة صريحة لتجنب مشاكل الـ type casting
        final rawList =
            data['userBanks'] ??
            data['data'] ??
            data['banks'] ??
            data['bank'] ??
            data['user_bank'] ??
            data['userBank'] ??
            data['user_banks'];

        debugPrint('🏦 rawList type: ${rawList?.runtimeType}, value: $rawList');

        if (rawList is List) {
          list = rawList;
        }
      } else if (data is List) {
        list = data;
      }

      debugPrint('🏦 Banks list count: ${list.length}');
      if (list.isNotEmpty) {
        debugPrint('🏦 First bank raw: ${list.first}');
      }

      List<BankModel> banks = list
          .map((e) => BankModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      debugPrint('🏦 Banks parsed count: ${banks.length}');

      // حفظ البيانات في Hive
      await box.put('cached_bank', list);
      return banks;
    } catch (e) {
      debugPrint('❌ خطأ في جلب البنوك: $e');

      final cached = box.get('cached_bank');
      if (cached != null) {
        debugPrint('🌐 تم عرض الحسابات البنكية من (Hive)');
        return (cached as List)
            .map((e) => BankModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      throw ApiErrorHandler.handle(e);
    }
  }

  // 📥 جلب النسخة المخزنة محلياً من الحسابات البنكية فوراً وبدون انتظار
  List<BankModel> getCachedBanks() {
    try {
      var box = Hive.box(HiveKeys.banksBox);
      final cached = box.get('cached_bank');
      if (cached != null) {
        return (cached as List)
            .map((e) => BankModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('❌ Error reading cached banks: $e');
    }
    return [];
  }

  Future<void> addBank({
    required int bankId,
    required String bankAccount,
    bool isActive = true,
  }) async {
    try {
      final response = await _apiService.post(
        'user-bank',
        data: {
          'bank_id': bankId,
          'bank_account': bankAccount,
          'is_active': isActive ? 1 : 0,
        },
      );
      debugPrint('🏦 Banks POST Response: ${response.data}');
    } catch (e) {
      debugPrint('❌ خطأ في إضافة بنك: $e');
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> updateBank({
    required int id, // id السجل في user_banks (لاستخدامه في الـ URL)
    required int bankId, // id البنك في جدول banks
    required String bankAccount,
    required bool isActive,
  }) async {
    try {
      final response = await _apiService.put(
        'user-bank/$id',
        data: {
          'bank_id': bankId,
          'bank_account': bankAccount,
          'is_active': isActive ? 1 : 0,
        },
      );
      debugPrint('🏦 Banks PUT Response: ${response.data}');
    } catch (e) {
      debugPrint('❌ خطأ في تحديث البنك: $e');
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> deleteBank(int id) async {
    try {
      // Laravel يرفض DELETE مباشر (405)، نستخدم POST مع _method=DELETE
      await _apiService.post('user-bank/$id', data: {'_method': 'DELETE'});
    } catch (e) {
      debugPrint('❌ خطأ في حذف البنك: $e');
      throw ApiErrorHandler.handle(e);
    }
  }
}
