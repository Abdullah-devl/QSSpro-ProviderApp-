


class HiveKeys {
  // اسم الصندوق الأساسي الذي سيحفظ إعدادات التطبيق العامة
  static const String settingsBox = 'settingsBox';
  static const String worksBox = 'worksBox'; // 💼 صندوق الأعمال السابقة
  static const String servicesBox = 'servicesBox'; // 🛠️ صندوق الخدمات
  static const String phonesBox = 'phonesBox'; // 📞 صندوق هواتف التواصل
  static const String banksBox = 'banksBox'; // 🏦 صندوق الحسابات البنكية
  static const String reviewsBox = 'reviewsBox'; // ⭐ صندوق التقييمات والمراجعات
  static const String ordersBox = 'orders_cache_box'; // 📦 صندوق الطلبات

  // مفاتيح القيم داخل الصندوق
  static const String themeKey = 'isDarkMode'; // لحفظ حالة الثيم (true/false)
  static const String langKey = 'languageCode'; // لحفظ كود اللغة ('ar' أو 'en')
  static const String tokenKey = 'userToken'; // لحفظ توكن الدخول لاحقاً
}
