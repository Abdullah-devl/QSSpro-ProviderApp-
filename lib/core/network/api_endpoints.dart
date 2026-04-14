// مسار الملف: lib/core/network/api_endpoints.dart

/// 📂 اسم الملف: api_endpoints.dart
/// 📝 الوصف: يحتوي على جميع الروابط (URLs) الخاصة بالـ API.

class ApiEndpoints {
  // ⛔ منع إنشاء كائن من هذا الكلاس
  ApiEndpoints._();

  // ===========================================================================
  // 🌐 إعدادات النطاق الأساسي (Domain & Base URL)
  // ===========================================================================

  // 🎯 قم بتفعيل السطر المناسب لبيئة العمل الخاصة بك (وعطّل الباقي):

  /// 1. للمحاكي (Android Emulator):
  // static String get domain => "http://10.0.2.2:8000";

  /// 2. للهاتف الحقيقي (تأكد من وضع الـ IP الخاص بجهازك وأنك متصل بنفس الشبكة):
  // static String get domain => "http://192.168.43.245:8000";
  static String get domain => "http://127.0.0.1:8000";

  /// 3. للسيرفر المرفوع على الإنترنت (Live):
  // static String get domain => "https://your-api-domain.com";

  // ---------------------------------------------------------------------------

  /// الرابط الأساسي للـ API (سيتم استخدامه تلقائياً في ApiService)
  /// أضفنا شرطة مائلة (/) في النهاية لتجنب أخطاء الدمج في Dio
  static String get baseUrl => "$domain/api/";

  /// رابط التخزين (لجلب الصور والملفات لاحقاً)
  static String get storageBaseUrl => "$domain/storage/";

  // ===========================================================================
  // 🔗 روابط الـ Endpoints (المسارات الفرعية)
  // ملاحظة: لا نكتب baseUrl هنا لأن Dio يقوم بدمجه تلقائياً في ApiService!
  // ===========================================================================

  // 🔐 روابط المصادقة
  static const String login = "login";
  static const String register = "register";
  static const String logout = "logout";
  static const String verifyEmail = "verify-email-code";
  static const String resendVerificationCode = "resend-verification-code";

  // 🏠 روابط مقدم الخدمة والصفحة الرئيسية
  static const String providerProfile = "provider/profile";
  static const String getHomeData = "home";
  static const String categories = "categories";
  static const String popularServices = "popular-services";
  static const String beProvider = "provider-requests";

  // 📂 الدوال التي تتطلب تمرير متغير (مثل الـ ID الخاص بالتصنيف)
  static String categoryDetails(int id) => "categories/$id";

  // رابط جلب وإدارة الخدمات الخاصة بمقدم الخدمة
  static const String myServices = "services";

  // رابط جلب الفئات الرئيسية
  static const String mainCategories = "categories";

  // رابط إضافة خدمة فرعية
  // static const String childServices = "services/child";
  static const String childServices = "services/children";

  static const String getOrders = "/requests/provider"; // مسار جلب الطلبات
  // static const String getOrders = "requests"; // مسار جلب الطلبات

  // رابط العمولات
  static const String commissions = "commissions";

  // رابط تقديم سند دفع العمولة عبر إيصال
  static const String requestCommissionBonds = "request-commission-bonds";

  // ===========================================================================
  // 💰 Withdrawals & Points Packages (السحوبات وباقات النقاط)
  // ===========================================================================

  // 📥 طلب سحب الأرباح
  static const String withdrawRequest = 'withdraw-request';

  // 🚀 شراء باقة نقاط
  static const String subscribePointsPackage = 'subscribe-points-package';

  // 📦 جلب باقات النقاط المتاحة
  static const String availablePointsPackages = 'verification-packages';
  static const String getPointsPackages = 'available-points-packages';
  static const String userVerificationPackages = 'user-verification-packages';
  static const String verificationRequests = "verification-requests";

  static const String myProfile = "my-profile";
  static const String providerCommissionSummary = "provider-commission-summary";
  static const String pointsBalance = "points/balance";
  static const String pointTransactions = "points/transactions";
  static const String myWithdrawRequests = "my-withdraw-requests";
  static const String providerRequestBonds = "provider-request-bonds";
  static const String myPointsPackages = "my-points-packages";
  static const String convertPoints = "points/convert";

  // 📝 روابط الطلبات (تحديث الحالة وإضافة المبلغ)
  static String getOrderDetail(String id) => "requests/$id";
  static String updateStatus(String id) => "requests/$id/status";
  static String addAmount(String id) => "requests/$id/addAmountToMoneyPaid";
  static String finishRequest(String id) => "requests/$id/finish";
  static String payCommission(String id) => "requests/$id/pay-commission";
  static const String complaints = "request-complaints";
  static const String systemComplaints = "system-complaints";
}
