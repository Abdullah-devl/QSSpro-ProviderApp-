// مسار الملف: lib/features/commissions/views/commissions_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:service_provider_app/features/commissions/viewmodels/commissions_viewmodel.dart';
import 'package:service_provider_app/features/commissions/views/widgets/verification_banner_widget.dart';
import 'package:service_provider_app/features/commissions/views/widgets/buy_points_banner_widget.dart';
import 'package:service_provider_app/features/commissions/views/widgets/points_actions_banner_widget.dart';
import 'package:service_provider_app/features/commissions/views/widgets/commissions_stats_banner.dart';
// import 'package:service_provider_app/features/commissions/views/widgets/due_commission_card.dart';
import 'package:service_provider_app/features/commissions/views/widgets/payments_history_section.dart';
import 'package:service_provider_app/features/commissions/viewmodels/commissions_stats_viewmodel.dart';
import 'package:service_provider_app/features/commissions/viewmodels/payments_history_viewmodel.dart';

class CommissionsView extends StatelessWidget {
  const CommissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    // نفترض أن ViewModel تم توفيره عبر Provider (مثلاً في main.dart)
    Provider.of<CommissionsViewModel>(context);
    
    return Scaffold(
      backgroundColor: context.qsColors.background,
      appBar: AppBar(
        backgroundColor: context.qsColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('commissions_management'),
          style: TextStyle(
            color: context.qsColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: const SizedBox.shrink(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            // viewModel.fetchCommissionsData(), // تم إيقافه لتجنب 404
            context.read<CommissionsStatsViewModel>().fetchStatsData(),
            context.read<PaymentsHistoryViewModel>().fetchAllHistory(),
          ]);
        },
        backgroundColor: context.qsColors.card,
        color: context.qsColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. شريط توثيق الحساب (يظهر دائماً للوصول لخيارات التوثيق)
              const VerificationBannerWidget(),
              const SizedBox(height: 16),

              // 📊 مربع إحصائيات العمولات والنقاط (نقطة 5.8، 5.11، 5.2)
              const CommissionsStatsBanner(),
              const SizedBox(height: 24),

              // 📦 مربع شراء النقاط
              const BuyPointsBannerWidget(),
              const SizedBox(height: 16),

              // 🔄 مربع عمليات النقاط (تحويل وسحب)
              const PointsActionsBannerWidget(),
              const SizedBox(height: 24),

              // 2. بطاقة العمولة المستحقة
              // (في حالة الانتظار أو الخطأ، نظهر صفر أو لا شيء، ولكن بما أنه تصميم يجب إظهاره دائماً)
              // DueCommissionCard(
              //   amount: viewModel.commissionsData?.summary.dueAmount ?? 0.0,
              // ),
              const SizedBox(height: 32),

              // 📊 سجل المدفوعات والعمليات المطور (الكل، باقاتي، العمليات، السحوبات، السندات)
              const PaymentsHistorySection(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
