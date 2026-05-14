import 'package:hive_flutter/hive_flutter.dart';
import 'hive_keys.dart';

class HiveHelper {
  //سنستدعيها أول شيء عند تشغيل التطبيق لتهيئة قاعدة البيانات
  static Future<void> init() async {
    await Hive.initFlutter();
    // تهيئة Hive للعمل مع فلاتر
    await Hive.openBox(HiveKeys.settingsBox);
    await Hive.openBox(HiveKeys.worksBox); // 💼 فتح صندوق الأعمال
    await Hive.openBox(HiveKeys.servicesBox); // 🛠️ فتح صندوق الخدمات
    await Hive.openBox(HiveKeys.phonesBox); // 📞 صندوق الهواتف
    await Hive.openBox(HiveKeys.banksBox); // 🏦 صندوق البنوك
    await Hive.openBox(HiveKeys.reviewsBox); // ⭐ صندوق التقييمات
    await Hive.openBox(HiveKeys.ordersBox); // 📦 صندوق الطلبات
  }

  // دالة مساعدة لتنظيف البيانات عند تسجيل الخروج (سنستخدمها لاحقاً)
  static Future<void> clareAllData() async {
    // ⚠️ لا نمسح الـ settingsBox بالكامل لأنه يحتوي على التوكن، اللغة، والسمة (Theme)
    final settingsBox = Hive.box(HiveKeys.settingsBox);
    // فقط نحذف المفاتيح المتعلقة بالمستخدم إذا لزم الأمر
    await settingsBox.delete('my_profile');
    await settingsBox.delete('provider_policy_agreed');
    
    // مسح باقي الصناديق التي تحتوي على بيانات للمستخدم القديم
    await Hive.box(HiveKeys.worksBox).clear();
    await Hive.box(HiveKeys.servicesBox).clear();
    await Hive.box(HiveKeys.phonesBox).clear();
    await Hive.box(HiveKeys.banksBox).clear();
    await Hive.box(HiveKeys.reviewsBox).clear();
    await Hive.box(HiveKeys.ordersBox).clear();
  }
}
