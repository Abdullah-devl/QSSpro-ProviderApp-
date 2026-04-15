// مسار الملف: lib/features/packages/views/verification_packages_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';

import '../models/package_model.dart';
import '../viewmodels/packages_viewmodel.dart';

class VerificationPackagesView extends StatelessWidget {
  const VerificationPackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<PackagesViewModel>();
    
    // لون خلفية الصفحة الأساسي بناءً على التصميم
    final Color bgColor = Theme.of(context).brightness == Brightness.dark 
        ? colors.background 
        : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('packages_title'),
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: const SizedBox.shrink(), // لإخفاء الزر الافتراضي
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: colors.text, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        // 🚀 إضافة كلمة QuickServe في الجهة المقابلة للسهم
        flexibleSpace: SafeArea(
          child: Align(
            alignment: AlignmentDirectional.centerStart, // يدعم RTL و LTR
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                context.tr('quick_serve'),
                style: const TextStyle(
                  color: Color(0xFF0F4A8A),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Cairo', // للحفاظ على نفس هوية الخط
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: Colors.grey,
        backgroundColor: Colors.white,
        onRefresh: () async => await vm.fetchPackages(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // 🛡️ الهيدر العُلوي
              _buildHeader(context, colors),
              const SizedBox(height: 32),

              // 📦 حالة التحميل أو الأخطاء أو قائمة الباقات
              if (vm.isLoading && vm.packages.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF1CB0F6))),
                )
              else if (vm.errorMessage != null && vm.packages.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Center(
                    child: Text(
                      context.tr(vm.errorMessage!),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else if (vm.packages.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Center(
                    child: Text(
                      context.tr('no_packages_available'),
                      style: TextStyle(color: colors.textSub),
                    ),
                  ),
                )
              else
                ...vm.packages.map((package) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _buildPackageCard(context, package, colors),
                  );
                }),

              const SizedBox(height: 24),

              // ❓ قسم "لماذا يجب عليك التوثيق؟"
              _buildWhyVerifySection(context, colors),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // 🧩 المكونات الداخلية (Widgets)
  // =========================================================

  Widget _buildHeader(BuildContext context, dynamic colors) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFE4F3F8), // أزرق فاتح جداً للأيقونة
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified_rounded,
            color: Color(0xFF5CA4B8),
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.tr('verify_account_now'),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('verify_account_desc'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: colors.textSub,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(BuildContext context, PackageModel package, dynamic colors) {
    // 🎨 توحيد الألوان لتكون بيضاء (White Theme) لجميع الكروت
    final bool isBlue = package.isPopular; // نحتفظ بها لتمييز "الأكثر طلباً" فقط في الشارة
    
    final Color cardColor = Colors.white;
    final Color textColor = colors.text;
    final Color subTextColor = colors.textSub;
    final Color buttonColor = isBlue ? const Color(0xFF5CA4B8) : const Color(0xFFF3F4F6);
    final Color buttonTextColor = isBlue ? Colors.white : colors.text;
    
    // تحديد الأيقونات العلوية ديناميكياً (نجمة برونزية، أو وسام أزرق، أو كأس ذهبي)
    IconData topIcon = Icons.star_rounded;
    Color topIconBg = const Color(0xFFFFF3E0); // خلفية برتقالية فاتحة
    Color topIconColor = const Color(0xFFE65100); // برتقالي

    if (package.id == 2 || isBlue) {
      topIcon = Icons.workspace_premium_rounded;
      topIconBg = Colors.white.withOpacity(0.2);
      topIconColor = Colors.white;
    } else if (package.id == 3 || (package.price > 250)) {
      topIcon = Icons.emoji_events_rounded;
      topIconBg = const Color(0xFFFFF8E1); // أصفر فاتح
      topIconColor = const Color(0xFFFFB300); // ذهبي
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32), // حواف دائرية كبيرة كما في التصميم
        boxShadow: [
          if (!isBlue)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          if (isBlue)
            BoxShadow(
              color: const Color(0xFF5CA4B8).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏷️ الشارة (Badge) والأيقونة العلوية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (package.badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isBlue ? const Color(0xFF5CA4B8).withOpacity(0.1) : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      package.badgeText!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isBlue ? const Color(0xFF5CA4B8) : const Color(0xFFE65100),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isBlue ? const Color(0xFF5CA4B8).withOpacity(0.1) : topIconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(topIcon, color: isBlue ? const Color(0xFF5CA4B8) : topIconColor, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 📝 عنوان الباقة ووصفها
            Center(
              child: Text(
                package.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                package.duration,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: subTextColor, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            // 💰 السعر
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    package.price.toInt().toString(),
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: isBlue ? Colors.white : const Color(0xFF5CA4B8),
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      context.tr('currency_rs'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isBlue ? Colors.white : const Color(0xFF5CA4B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ✅ المميزات (Features)
            ...package.features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isBlue ? Colors.white : const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: isBlue ? const Color(0xFF5CA4B8) : Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // 🔘 الزر (Button)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  context.read<PackagesViewModel>().selectPackage(context, package.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  context.tr('choose_package'),
                  style: TextStyle(
                    color: buttonTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyVerifySection(BuildContext context, dynamic colors) {
    return Column(
      children: [
        Text(
          context.tr('why_verify'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWhyItem(Icons.trending_up_rounded, context.tr('increase_orders'), colors),
            const SizedBox(width: 60), // مسافة بين العنصرين كما في التصميم
            _buildWhyItem(Icons.shield_rounded, context.tr('customer_trust'), colors),
          ],
        ),
      ],
    );
  }

  Widget _buildWhyItem(IconData icon, String text, dynamic colors) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF5CA4B8), size: 28),
        const SizedBox(height: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
      ],
    );
  }
}