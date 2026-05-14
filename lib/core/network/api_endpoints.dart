// مسار الملف: lib/core/network/api_endpoints.dart

/// 📂 اسم الملف: api_endpoints.dart
/// 📝 الوصف: يحتوي على جميع الروابط (URLs) الخاصة بالـ API.
library;


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
  // static String get domain => "http://11.11.37.9:8000";
  // static String get domain => "http://192.168.137.59:8000";

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
  static const String dashboard = "provider/dashboard";
  static const String advertisements = "advertisements";
  static String adView(int id) => "advertisements/$id/view";
  static String adClick(int id) => "advertisements/$id/click";
  static const String categories = "categories";
  static const String popularServices = "popular-services";
  static const String beProvider = "provider-requests";
  static const String providerPolicy = "policies/provider";

  // 📂 الدوال التي تتطلب تمرير متغير (مثل الـ ID الخاص بالتصنيف)
  static String categoryDetails(int id) => "categories/$id";

  // رابط جلب وإدارة الخدمات الخاصة بمقدم الخدمة
  static const String myServices = "services";

  // رابط جلب الفئات الرئيسية
  static const String mainCategories = "categories";

  // رابط إضافة خدمة فرعية
  // static const String childServices = "services/child";
  static const String childServices = "services/children";
  static String updateChildService(int id) => "services/children/$id";

  static const String getOrders = "requests/provider"; // مسار جلب الطلبات
  // static const String getOrders = "requests"; // مسار جلب الطلبات

  // رابط العمولات
  static const String commissions = "commissions";
  static const String unpaidCommissions = "requests/unpaid-commissions";

  // رابط تقديم سند دفع العمولة عبر إيصال
  static const String requestCommissionBonds = "request-commission-bonds";

  // حسابات المنصة البنكية الرسمية
  static const String platformBankAccounts = "platform-bank-accounts";

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
  static String approveBond(String bondId) => "request-bonds/$bondId/approve";
  static String rejectBond(String bondId) => "request-bonds/$bondId/reject";
  static String getUserProfile(String userId) => "user-profile/$userId";
  static const String complaints = "request-complaints";
  static const String systemComplaints = "system-complaints";

  // 🛠️ روابط الخدمات التلقائية (اللقاء والمخصصة)
  static String getCustomService(dynamic userId) => "services-custom/$userId";
  static String getMeetingService(dynamic userId) => "services-meeting/$userId";

  static const String updateCustomService = "services-custom";
  static const String updateMeetingService = "services-meeting";

  // 🔔 روابط الإشعارات
  static const String notifications = "notifications";
  static const String storeToken = "store-token";
  static const String removeToken = "remove-token";
  static String markNotificationAsRead(String id) => "notifications/$id/read";
  static const String markAllNotificationsAsRead = "notifications/read-all";
}
