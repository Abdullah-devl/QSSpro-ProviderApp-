import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import 'package:service_provider_app/core/network/api_client.dart';
import 'package:service_provider_app/core/storage/token_storage.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:service_provider_app/core/widgets/app_logo.dart';
import 'package:service_provider_app/core/widgets/custom_button.dart';
import 'package:service_provider_app/features/auth/repositories/auth_repository.dart';
import 'package:service_provider_app/features/auth/viewmodels/register_viewmodel.dart';
import 'package:service_provider_app/features/auth/views/login_view.dart';
import 'package:service_provider_app/features/auth/views/register_view.dart';
import 'package:service_provider_app/features/settings/viewmodels/settings_provider.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // //زر تغير الثيم
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: IconButton(
              //     onPressed: () => settingsProvider.toggleDarkMode(),
              //     icon: Icon(
              //       settingsProvider.isDarkMode
              //           ? Icons.light_mode
              //           : Icons.dark_mode,
              //       color: context.qsColors.text,
              //     ),
              //     style: IconButton.styleFrom(
              //       backgroundColor: context.qsColors.text.withOpacity(0.05),
              //       padding: const EdgeInsets.all(12),
              //     ),
              //   ),
              // ),
              // ========================================================
              // الأزرار العلوية (الثيم + اللغة)
              // ========================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. زر تغيير الثيم
                  IconButton(
                    onPressed: () => settingsProvider.toggleDarkMode(),
                    icon: Icon(
                      settingsProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: context.qsColors.text,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: context.qsColors.text.withValues(
                        alpha: 0.05,
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),

                  // 2. زر تغيير اللغة (الجديد)
                  TextButton.icon(
                    onPressed: () {
                      final newLang = settingsProvider.languageCode == 'ar'
                          ? 'en'
                          : 'ar';
                      settingsProvider.changeLanguage(newLang);
                    },
                    icon: Icon(
                      Icons.language,
                      color: context.qsColors.text,
                      size: 20,
                    ),
                    label: Text(
                      settingsProvider.languageCode == 'ar'
                          ? 'English'
                          : context.tr('auto_tr_22'),
                      style: TextStyle(
                        color: context.qsColors.text,
                        fontWeight: FontWeight.bold,
                        fontFamily:
                            'Cairo', // لضمان ظهور كلمة context.tr('auto_tr_22') بخط كايرو دائماً
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: context.qsColors.text.withValues(
                        alpha: 0.05,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          50,
                        ), // حواف دائرية تتطابق مع زر الثيم
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(flex: 2),
              // الشعار والنصوص
              AppLogo(),
              SizedBox(height: 30),
              Text(
                context.tr('app_name'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 5),
              Text(
                context.tr('welcome_subtitle'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: context.qsColors.textSub.withValues(alpha: 0.7),
                ),
              ),
              Spacer(flex: 3),
              // زر البدء
              CustomButton(
                text: context.tr('login'),
                icon: Icons.login_rounded,
                isPrimary: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginView()),
                  );
                },
              ),

              const SizedBox(height: 16),
              CustomButton(
                text: context.tr('create_account'),
                icon: Icons.person_add_alt_1_rounded,
                isPrimary: false,
                onPressed: () {
                  final tokenStorage = TokenStorage();
                  final apiService = ApiService(tokenStorage);
                  final authRepository = AuthRepository(apiService, tokenStorage);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => RegisterViewModel(authRepository),
                        child: const RegisterView(),
                      ),
                    ),
                  );
                },
              ),

              // SizedBox(height: 30),

              // نص الشروط والسياسات
              // RichText(
              //   textAlign: TextAlign.center,
              //   text: TextSpan(
              //     style: TextStyle(
              //       color: context.qsColors.textSub,
              //       fontSize: 12,
              //       fontFamily: 'Cairo', // تأكيد الخط
              //     ),
              //     children: [
              //       TextSpan(text: context.tr('terms_agreement')),
              //       TextSpan(
              //         text: context.tr('terms_of_service'),
              //         style: TextStyle(
              //           color: context.qsColors.primary,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //       TextSpan(text: context.tr('and')),
              //       TextSpan(
              //         text: context.tr('privacy_policy'),
              //         style: TextStyle(
              //           color: context.qsColors.primary,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
