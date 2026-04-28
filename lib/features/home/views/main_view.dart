// مسار الملف: lib/features/home/views/main_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/features/commissions/views/commissions_view.dart';
import 'package:service_provider_app/features/home/views/home_dashboard_view.dart';
import 'package:service_provider_app/features/orders/Views/orders_view.dart';
import 'package:service_provider_app/features/profile/views/profile_view.dart';
import 'package:service_provider_app/features/services/views/manage_services_view.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../viewmodels/main_viewmodel.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainViewModel(),
      child: const _MainViewBody(),
    );
  }
}

class _MainViewBody extends StatelessWidget {
  const _MainViewBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainViewModel>(context);

    final List<Widget> screens = [
      const HomeDashboardView(),
      const OrdersView(),
      const ManageServicesView(),
      const CommissionsView(),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: context.qsColors.background,
      extendBody: true, // مهم جداً لكي تمتد الشاشة خلف شريط التنقل العائم
      body: screens[viewModel.currentIndex],
      bottomNavigationBar: _CustomFloatingNavBar(
        currentIndex: viewModel.currentIndex,
        onTap: viewModel.changeTab,
      ),
    );
  }
}

class _CustomFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _CustomFloatingNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: colors.background.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.text.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(context, 0, Icons.home_filled, context.tr('nav_home')),
                  _buildNavItem(context, 1, Icons.assignment_outlined, context.tr('nav_orders')),
                  _buildNavItem(context, 2, Icons.category_outlined, context.tr('nav_services')),
                  _buildNavItem(context, 3, Icons.account_balance_wallet_outlined, context.tr('nav_commissions')),
                  _buildNavItem(context, 4, Icons.person, context.tr('nav_profile')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final bool isSelected = currentIndex == index;
    final colors = context.qsColors;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? colors.primary : colors.textSub,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? colors.primary : colors.textSub,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildCenterItem(BuildContext context, int index) {
  //   final colors = context.qsColors;
  //   final bool isSelected = currentIndex == index;

  //   return GestureDetector(
  //     onTap: () => onTap(index),
  //     child: AnimatedContainer(
  //       duration: const Duration(milliseconds: 200),
  //       width: 52,
  //       height: 52,
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //           colors: [
  //             colors.primary,
  //             colors.secondary,
  //           ],
  //         ),
  //         shape: BoxShape.circle,
  //         boxShadow: [
  //           BoxShadow(
  //             color: colors.primary.withValues(alpha: isSelected ? 0.5 : 0.3),
  //             blurRadius: isSelected ? 16 : 10,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Icon(
  //         Icons.category_outlined,
  //         color: context.qsColors.card,
  //         size: isSelected ? 30 : 26,
  //       ),
  //     ),
  //   );
  // }
}

