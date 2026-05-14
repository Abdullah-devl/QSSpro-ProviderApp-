// مسار الملف: lib/features/verification/packages/views/verification_packages_view.dart

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
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        color: colors.primary,
        backgroundColor: colors.card,
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Center(child: CircularProgressIndicator(color: colors.primary)),
                )
              else if (vm.errorMessage != null && vm.packages.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Center(
                    child: Text(
                      context.tr(vm.errorMessage!),
                      style: TextStyle(color: colors.error),
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

  Widget _buildHeader(BuildContext context, dynamic colors) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.verified_rounded,
            color: colors.primary,
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
    final bool isBlue = package.isPopular;
    
    final Color cardColor = colors.card;
    final Color textColor = colors.text;
    final Color subTextColor = colors.textSub;
    final Color primaryColor = colors.primary;
    
    final Color buttonColor = isBlue ? primaryColor : colors.background;
    final Color buttonTextColor = isBlue ? colors.card : colors.text;
    
    IconData topIcon = Icons.star_rounded;
    Color topIconBg = colors.warning.withValues(alpha: 0.1);
    Color topIconColor = colors.warning;

    if (package.id == 2 || isBlue) {
      topIcon = Icons.workspace_premium_rounded;
      topIconBg = primaryColor.withValues(alpha: 0.1);
      topIconColor = primaryColor;
    } else if (package.id == 3 || (package.price > 250)) {
      topIcon = Icons.emoji_events_rounded;
      topIconBg = colors.warning.withValues(alpha: 0.1);
      topIconColor = colors.warning;
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isBlue ? primaryColor.withValues(alpha: 0.2) : colors.textSub.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.text.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
          if (isBlue)
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.1),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (package.badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isBlue ? primaryColor.withValues(alpha: 0.1) : colors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      package.badgeText!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isBlue ? primaryColor : colors.warning,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: topIconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(topIcon, color: topIconColor, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 20),

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
                      color: primaryColor,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      context.tr('sar'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            ...package.features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colors.success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: colors.success,
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
            }),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  context.read<PackagesViewModel>().selectPackage(context, package.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: buttonTextColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: isBlue ? null : BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  context.tr('choose_package'),
                  style: TextStyle(
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
            _buildWhyItem(context, Icons.trending_up_rounded, context.tr('increase_orders'), colors),
            const SizedBox(width: 60),
            _buildWhyItem(context, Icons.shield_rounded, context.tr('customer_trust'), colors),
          ],
        ),
      ],
    );
  }

  Widget _buildWhyItem(BuildContext context, IconData icon, String text, dynamic colors) {
    return Column(
      children: [
        Icon(icon, color: colors.primary, size: 28),
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
