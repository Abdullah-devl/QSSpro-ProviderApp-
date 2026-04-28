// مسار الملف: lib/features/services/views/manage_services_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/features/services/views/add_service_view.dart';
import 'package:service_provider_app/features/services/widgets/service_card_widget.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../../../core/localization/app_localizations.dart';
import '../../home/viewmodels/main_viewmodel.dart';
import '../viewmodels/manage_services_viewmodel.dart';
import 'special_services_view.dart' as service_views;

class ManageServicesView extends StatelessWidget {
  const ManageServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ManageServicesViewModel>(context);
    Provider.of<MainViewModel>(context, listen: false);

    final filters = [
      context.tr('filter_all'),
      context.tr('filter_active'),
      context.tr('filter_inactive'),
    ];

    return SafeArea(
      child: Column(
        children: [
          // 1. الهيدر
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.tr('manage_my_services'),
                  style: TextStyle(
                    color: context.qsColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: context.qsColors.primary,
              backgroundColor: context.qsColors.card,
              onRefresh: () async => await viewModel.fetchServices(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // 2. شريط البحث
                    Container(
                      decoration: BoxDecoration(
                        color: context.qsColors.card,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: context.qsColors.text.withValues(alpha: 0.04),
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
                            color: context.qsColors.textSub.withOpacity(0.5),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: context.qsColors.textSub,
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AddServiceView()),
                              );
                            },
                            child: Container(
                              height: 55,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: context.qsColors.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: context.qsColors.card, size: 18),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        context.tr('add_service'),
                                        style: TextStyle(
                                          color: context.qsColors.card,
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const service_views.SpecialServicesView()),
                              );
                            },
                            child: Container(
                              height: 55,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: context.qsColors.primary.withOpacity(0.05),
                                border: Border.all(color: context.qsColors.primary.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.workspace_premium, color: context.qsColors.primary, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      context.tr('special_services_and_attendance'),
                                      style: TextStyle(
                                        color: context.qsColors.primary,
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
                                    ? context.qsColors.primary
                                    // ? context.qsColors.text
                                    : context.qsColors.card,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : context.qsColors.textSub.withOpacity(
                                          0.2,
                                        ),
                                ),
                              ),
                              child: Text(
                                filters[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? context.qsColors.card
                                      : context.qsColors.textSub,
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
                    if (viewModel.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: CircularProgressIndicator(color: context.qsColors.primary),
                      )
                    else if (viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text(
                          viewModel.errorMessage!,
                          style: TextStyle(color: context.qsColors.error),
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

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


