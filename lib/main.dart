import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:service_provider_app/core/network/api_client.dart';
import 'package:service_provider_app/features/services/repositories/manage_services_repository.dart';
import 'package:service_provider_app/features/services/viewmodels/manage_services_viewmodel.dart';
import 'features/commissions/repositories/commissions_repository.dart';
import 'features/commissions/repositories/payments_history_repository.dart';
import 'features/commissions/viewmodels/commissions_viewmodel.dart';
import 'features/commissions/viewmodels/commissions_stats_viewmodel.dart';
import 'features/commissions/viewmodels/payments_history_viewmodel.dart';
import 'features/commissions/viewmodels/pay_commissions_viewmodel.dart';
import 'features/commissions/viewmodels/pay_with_points_viewmodel.dart';
import 'features/profile/repositories/profile_repository.dart';
import 'features/profile/viewmodels/profile_viewmodel.dart';
import 'package:service_provider_app/features/withdraw/repositories/withdraw_repository.dart';
import 'package:service_provider_app/features/withdraw/viewmodels/withdraw_viewmodel.dart';
import 'package:service_provider_app/features/points/repositories/points_repository.dart';
import 'package:service_provider_app/features/points/viewmodels/convert_points_viewmodel.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
// 1. استدعاء ملفات الشبكة والتخزين (التي نسيناها) 🌐
import 'core/storage/token_storage.dart';
import 'core/network/navigation_service.dart'; // 🌍 استدعاء مفتاح التنقل
import 'features/home/repositories/home_repository.dart';
import 'features/auth/views/login_view.dart'; // 🚪 شاشة تسجيل الدخول


// 2. استدعاء الـ ViewModels 🧠
import 'features/settings/viewmodels/settings_provider.dart';
import 'features/home/viewmodels/main_viewmodel.dart';
import 'features/orders/Repository/orders_repository.dart';
import 'features/orders/ViewModels/orders_viewmodel.dart';
import 'features/complaints/repositories/complaints_repository.dart';
import 'features/complaints/viewmodels/submit_complaint_viewmodel.dart';
import 'features/complaints/viewmodels/system_complaints_viewmodel.dart';

// 3. استدعاء الثيم، الترجمة، وشاشة البداية 🎨
import 'core/storage/hive_helper.dart';
import 'core/theme/app_theme.dart';
// import 'core/theme/qs_color_extension.dart'; // إذا كنت تستخدمها في main
import 'core/localization/app_localizations.dart';
import 'features/splash/views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة قاعدة البيانات المحلية
  await HiveHelper.init();

  // ========================================================
  // 🚀 👇 التعديل الجوهري هنا: تجهيز الاعتماديات (API & Repository)
  // ========================================================
  final tokenStorage = TokenStorage();
  final apiService = ApiService(tokenStorage);
  final homeRepository = HomeRepository(apiService);
  final manageServicesRepository = ManageServicesRepository(apiService);
  final commissionsRepository = CommissionsRepository(apiService);
  final paymentsHistoryRepository = PaymentsHistoryRepository(apiService);
  final profileRepository = ProfileRepository(apiService);
  final withdrawRepository = WithdrawRepository(apiService);
  final pointsRepository = PointsRepository(apiService);
  final ordersRepository = OrdersRepository(apiService);
  final authRepository = AuthRepository(apiService, tokenStorage);
  final complaintsRepository = ComplaintsRepository(apiService);

  runApp(
    MultiProvider(
      providers: [
        // 💉 حقن الخدمات الأساسية لتكون متاحة عبر context
        Provider<TokenStorage>.value(value: tokenStorage),
        Provider<ApiService>.value(value: apiService),
        Provider<PointsRepository>.value(value: pointsRepository),
        Provider<ProfileRepository>.value(value: profileRepository),
        Provider<PaymentsHistoryRepository>.value(value: paymentsHistoryRepository),
        Provider<AuthRepository>.value(value: authRepository),

        // ⚙️ 👇 التعديل هنا: أضفنا SettingsProvider لكي لا يتعطل التطبيق!
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        
        // 🔐 ViewModel الخاص بالمصادقة (تسجيل الخروج)
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepository)),

        // 📱 ViewModel الخاص بشريط التنقل السفلي
        ChangeNotifierProvider(create: (_) => MainViewModel()),
        
        // 🏠 ViewModel الخاص بالشاشة الرئيسية (مررنا له الـ Repository)
        ChangeNotifierProvider(create: (_) => HomeViewModel(homeRepository)),

        //لادارة الخدمات
        ChangeNotifierProvider(create: (_) => ManageServicesViewModel(manageServicesRepository)),

        // العمولات
        ChangeNotifierProvider(
          create: (_) => CommissionsViewModel(commissionsRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CommissionsStatsViewModel(
            commissionsRepository,
            pointsRepository,
            profileRepository,
          ),
        ),
        ChangeNotifierProvider(create: (_) => PayCommissionsViewModel(commissionsRepository)),
        ChangeNotifierProvider(create: (_) => PayWithPointsViewModel(commissionsRepository)),

        // 🔥 الملف الشخصي
        ChangeNotifierProvider(create: (_) => ProfileViewModel(profileRepository)),
        
        // 💰 سحب الأرباح
        ChangeNotifierProvider(create: (_) => WithdrawViewModel(withdrawRepository)),

        // 📊 سجل المدفوعات والعمليات المطور
        ChangeNotifierProvider(create: (_) => PaymentsHistoryViewModel(paymentsHistoryRepository)),

        // 🔄 تحويل الأرباح لنقاط
        ChangeNotifierProvider(create: (_) => ConvertPointsViewModel(pointsRepository)),

        // 📦 الطلبات (Orders)
        ChangeNotifierProvider(create: (_) => OrdersViewModel(ordersRepository)),

        // 📝 الشكاوي (Complaints)
        ChangeNotifierProvider(create: (_) => SubmitComplaintViewModel(complaintsRepository)),
        ChangeNotifierProvider(create: (_) => SystemComplaintsViewModel(complaintsRepository)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Provider App',
      navigatorKey: navigatorKey, // ✅ ربط مفتاح التنقل بالعالم


      // 🎨 ربط الثيم والألوان
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsProvider.themeMode,

      // 🌍 إعدادات اللغة الأساسية
      locale: settingsProvider.locale,
      supportedLocales: const [Locale('ar'), Locale('en')],

      // 🌍 إعدادات الترجمة
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 🗺️ الطرق (Routes)
      routes: {
        '/login': (context) => const LoginView(),
      },

      home: const SplashView(),
    );
  }
}
