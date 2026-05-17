// // مسار الملف: lib/features/auth/views/login_view.dart

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../core/localization/app_localizations.dart';
// import '../../../core/theme/qs_color_extension.dart';
// import '../../../core/widgets/custom_button.dart';
// import '../../../core/widgets/custom_textfield.dart';
// import '../viewmodels/login_viewmodel.dart';

// class LoginView extends StatelessWidget {
//   const LoginView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // نغلف الشاشة بالـ Provider الخاص بها
//     return ChangeNotifierProvider(
//       create: (_) => LoginViewModel(),
//       child: const _LoginViewBody(),
//     );
//   }
// }

// class _LoginViewBody extends StatelessWidget {
//   const _LoginViewBody();

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<LoginViewModel>(context);

//     return Scaffold(
//       // خلفية الشاشة الأساسية
//       backgroundColor: context.qsColors.background,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 // لون البطاقة يتغير حسب الثيم (أبيض في الفاتح، رمادي غامق في الداكن)
//                 color: Theme.of(context).cardColor,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: context.qsColors.text.withOpacity(0.05),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // =====================================
//                   // 1. الشعار والكلمات الترحيبية
//                   // =====================================
//                   Container(
//                     width: 70,
//                     height: 70,
//                     decoration: BoxDecoration(
//                       color: context.qsColors.primary,
//                       borderRadius: BorderRadius.circular(18),
//                       boxShadow: [
//                         BoxShadow(
//                           color: context.qsColors.primary.withOpacity(0.3),
//                           blurRadius: 15,
//                           offset: const Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Icon(
//                       Icons.handshake_rounded,
//                       color: context.qsColors.card,
//                       size: 35,
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   Text(
//                     context.tr('app_name'),
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontSize: 26,
//                       fontWeight: FontWeight.w900,
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   // شارة "مقدم خدمة"
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: context.qsColors.primary.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       context.tr('service_provider'),
//                       style: TextStyle(
//                         color: context.qsColors.primary,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   Text(
//                     context.tr('welcome_partner'),
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: context.qsColors.text,
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   Text(
//                     context.tr('login_subtitle'),
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: context.qsColors.textSub,
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   // =====================================
//                   // 2. حقول الإدخال
//                   // =====================================
//                   CustomTextField(
//                     label: context.tr('email_label'),
//                     hint: context.tr('email_hint'),
//                     prefixIcon: Icons.email_outlined,
//                     controller: viewModel.emailController,
//                     keyboardType: TextInputType.emailAddress,
//                   ),
//                   const SizedBox(height: 16),

//                   CustomTextField(
//                     label: context.tr('password_label'),
//                     hint: context.tr('password_hint'),
//                     isPassword: viewModel.isObscure,
//                     controller: viewModel.passwordController,
//                     // زر العين لإظهار/إخفاء كلمة المرور
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         viewModel.isObscure
//                             ? Icons.visibility_off_outlined
//                             : Icons.visibility_outlined,
//                         color: context.qsColors.textSub.withOpacity(0.7),
//                       ),
//                       onPressed: viewModel.togglePasswordVisibility,
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   // =====================================
//                   // 3. نسيان كلمة المرور
//                   // =====================================
//                   Align(
//                     alignment: AlignmentDirectional.centerStart,
//                     child: TextButton(
//                       onPressed: () {},
//                       style: TextButton.styleFrom(
//                         padding: EdgeInsets.zero,
//                         minimumSize: const Size(0, 0),
//                       ),
//                       child: Text(
//                         context.tr('forgot_password'),
//                         style: TextStyle(
//                           color: context.qsColors.primary,
//                           fontSize: 13,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // =====================================
//                   // 4. الأزرار
//                   // =====================================
//                   viewModel.isLoading
//                       ? CircularProgressIndicator(
//                           color: context.qsColors.primary,
//                         )
//                       : CustomButton(
//                           text: context.tr('login'),
//                           // سهم يشير للاتجاه الصحيح حسب لغة التطبيق
//                           icon: Directionality.of(context) == TextDirection.rtl
//                               ? Icons.arrow_back
//                               : Icons.arrow_forward,
//                           isPrimary: true,
//                           onPressed: () => viewModel.login(context),
//                         ),

//                   const SizedBox(height: 20),

//                   // خط "أو"
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Divider(
//                           color: context.qsColors.textSub.withOpacity(0.2),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Text(
//                           context.tr('or'),
//                           style: TextStyle(color: context.qsColors.textSub),
//                         ),
//                       ),
//                       Expanded(
//                         child: Divider(
//                           color: context.qsColors.textSub.withOpacity(0.2),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),

//                   CustomButton(
//                     text: context.tr('create_account'),
//                     icon: Icons
//                         .person_add_alt_1_outlined, // أيقونة بدون تعبئة (Outlined)
//                     isPrimary: false,
//                     onPressed: () {},
//                   ),
//                   const SizedBox(height: 30),

//                   // =====================================
//                   // 5. الإصدار
//                   // =====================================
//                   Text(
//                     context.tr('version'),
//                     style: TextStyle(
//                       color: context.qsColors.textSub,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// مسار الملف: lib/features/auth/views/login_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/network/api_client.dart';

import '../../../core/storage/token_storage.dart';
import '../repositories/auth_repository.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. تجهيز الاعتماديات (Dependency Injection) قبل تشغيل الصفحة
    final tokenStorage = TokenStorage();
    final apiService = ApiService(tokenStorage);
    final authRepository = AuthRepository(apiService, tokenStorage);

    // 2. نغلف الشاشة بالـ Provider ونمرر له الـ authRepository
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(authRepository), // <-- تم حل الخطأ هنا ✅
      child: const _LoginViewBody(),
    );
  }
}

class _LoginViewBody extends StatelessWidget {
  const _LoginViewBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      backgroundColor: context.qsColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.qsColors.card,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: context.qsColors.text.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // =====================================
                  // 1. الشعار والكلمات الترحيبية
                  // =====================================
                  const AppLogo(size: 160),
                  const SizedBox(height: 16),

                  Text(
                    context.tr('app_name'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.qsColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.tr('service_provider'),
                      style: TextStyle(
                        color: context.qsColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    context.tr('welcome_partner'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.qsColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    context.tr('login_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.qsColors.textSub,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // =====================================
                  // 2. حقول الإدخال
                  // =====================================
                  CustomTextField(
                    label: context.tr('email_label'),
                    hint: context.tr('email_hint'),
                    prefixIcon: Icons.email_outlined,
                    controller: viewModel.emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: context.tr('password_label'),
                    hint: context.tr('password_hint'),
                    isPassword: viewModel.isObscure,
                    controller: viewModel.passwordController,
                    suffixIcon: IconButton(
                      icon: Icon(
                        viewModel.isObscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: context.qsColors.textSub.withValues(alpha: 0.7),
                      ),
                      onPressed: viewModel.togglePasswordVisibility,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // =====================================
                  // 3. نسيان كلمة المرور
                  // =====================================
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                      ),
                      child: Text(
                        context.tr('forgot_password'),
                        style: TextStyle(
                          color: context.qsColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // =====================================
                  // 4. الأزرار
                  // =====================================
                  viewModel.isLoading
                      ? CircularProgressIndicator(
                          color: context.qsColors.primary,
                        )
                      : CustomButton(
                          text: context.tr('login'),
                          icon: Directionality.of(context) == TextDirection.rtl
                              ? Icons.arrow_back
                              : Icons.arrow_forward,
                          isPrimary: true,
                          onPressed: () => viewModel.login(context),
                        ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: context.qsColors.textSub.withValues(alpha: 0.2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          context.tr('or'),
                          style: TextStyle(color: context.qsColors.textSub),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: context.qsColors.textSub.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 🌐 زر الدخول بجوجل
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: context.qsColors.textSub.withValues(alpha: 0.2),
                        ),
                      ),
                      onPressed: viewModel.isLoading
                          ? null
                          : () => viewModel.loginWithGoogle(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // شعار Google G بدون شبكة
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(shape: BoxShape.circle),
                            child: const Text(
                              'G',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4285F4),
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            context.tr('continue_with_google'),
                            style: TextStyle(
                              color: context.qsColors.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // =====================================
                  // 5. الإصدار
                  // =====================================
                  Text(
                    context.tr('version'),
                    style: TextStyle(
                      color: context.qsColors.textSub,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


