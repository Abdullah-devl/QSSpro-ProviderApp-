// مسار الملف: lib/features/services/views/manage_services_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/features/services/views/add_service_view.dart';
import 'package:service_provider_app/features/services/widgets/service_card_widget.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../../../core/localization/app_localizations.dart';
import '../viewmodels/manage_services_viewmodel.dart';
import 'special_services_view.dart' as service_views;
import 'package:shimmer/shimmer.dart';
import 'package:service_provider_app/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:service_provider_app/core/utils/dialog_helper.dart';

class ManageServicesView extends StatelessWidget {
  const ManageServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ManageServicesViewModel>(context);
    final colors = context.qsColors;

    final filters = [
      context.tr('filter_all'),
      context.tr('filter_active'),
      context.tr('filter_inactive'),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          context.tr('manage_my_services'),
          style: TextStyle(
            color: colors.text,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: viewModel.isLoading
          ? _buildFullPageSkeleton(colors)
          : RefreshIndicator(
              color: colors.primary,
              backgroundColor: colors.card,
              onRefresh: () async => await viewModel.fetchServices(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // 2. شريط البحث
                    Container(
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colors.text.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: context.tr('search_service_hint'),
                          hintStyle: TextStyle(
                            color: colors.textSub.withOpacity(0.5),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: colors.textSub,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // أزرار إضافة خدمة + الخدمات المخصصة والحضور
                    Row(
                      children: [
                        // زر إضافة خدمة
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
                              if (profileVM.profile?.isSuspendedForCommissions == true) {
                                DialogHelper.showErrorDialog(
                                  context,
                                  profileVM.profile?.suspendedMessage ??
                                      context.tr('suspended_commissions_default_msg'),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AddServiceView()),
                              );
                            },
                            child: Container(
                              height: 55,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: colors.card, size: 18),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        context.tr('add_service'),
                                        style: TextStyle(
                                          color: colors.card,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // زر الخدمات المخصصة والحضور
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () {
                              final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
                              if (profileVM.profile?.isSuspendedForCommissions == true) {
                                DialogHelper.showErrorDialog(
                                  context,
                                  profileVM.profile?.suspendedMessage ??
                                      context.tr('suspended_commissions_default_msg'),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const service_views.SpecialServicesView()),
                              );
                            },
                            child: Container(
                              height: 55,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(0.05),
                                border: Border.all(color: colors.primary.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.workspace_premium, color: colors.primary, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      context.tr('special_services_and_attendance'),
                                      style: TextStyle(
                                        color: colors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. أزرار الفلترة
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Row(
                        children: List.generate(filters.length, (index) {
                          final isSelected =
                              viewModel.selectedFilterIndex == index;
                          return GestureDetector(
                            onTap: () => viewModel.changeFilter(index),
                            child: Container(
                              margin: const EdgeInsets.only(left: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primary
                                    : colors.card,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : colors.textSub.withOpacity(
                                          0.2,
                                        ),
                                ),
                              ),
                              child: Text(
                                filters[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? colors.card
                                      : colors.textSub,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. الحالات (تحميل، خطأ، أو عرض البيانات)
                    if (viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text(
                          viewModel.errorMessage!,
                          style: TextStyle(color: colors.error),
                        ),
                      )
                    else if (viewModel.filteredServices.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text(context.tr('no_services_available')),
                      )
                    else
                      ...viewModel.filteredServices.map(
                        (service) => ServiceCardWidget(service: service),
                      ),

                    const SizedBox(height: 100), // مساحة للناف بار
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFullPageSkeleton(dynamic colors) {
    return Shimmer.fromColors(
      baseColor: colors.text.withValues(alpha: 0.08),
      highlightColor: colors.text.withValues(alpha: 0.02),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            // Search bar skeleton
            Container(height: 55, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 16),
            // Action buttons skeleton
            Row(
              children: [
                Expanded(flex: 1, child: Container(height: 55, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: Container(height: 55, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
              ],
            ),
            const SizedBox(height: 20),
            // Filters skeleton
            Row(
              children: List.generate(3, (index) => Expanded(
                child: Container(height: 40, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
              )),
            ),
            const SizedBox(height: 24),
            // Cards skeleton
            Column(
              children: List.generate(4, (index) => Container(
                height: 130,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(width: 100, height: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(height: 18, width: 150, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(height: 14, width: 100, color: Colors.white),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(height: 16, width: 60, color: Colors.white),
                              Container(height: 20, width: 40, color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}


