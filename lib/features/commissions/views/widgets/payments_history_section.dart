import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:service_provider_app/features/commissions/viewmodels/payments_history_viewmodel.dart';
import 'package:service_provider_app/features/commissions/views/widgets/history_list_item.dart';

class PaymentsHistorySection extends StatelessWidget {
  const PaymentsHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentsHistoryViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان الرئيسي
            Text(
              context.tr('payments_history'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.qsColors.text,
              ),
            ),
            const SizedBox(height: 16),

            // التبويبات الـ 5 (الكل، باقاتي، العمليات، السحوبات، السندات)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(viewModel.tabKeys.length, (index) {
                  bool isSelected = viewModel.selectedTabIndex == index;
                  return GestureDetector(
                    onTap: () => viewModel.changeTab(index),
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? context.qsColors.primary : context.qsColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : context.qsColors.textSub.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        context.tr(viewModel.tabKeys[index]),
                        style: TextStyle(
                          color: isSelected ? context.qsColors.card : context.qsColors.textSub,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // قائمة سجل العمليات
            if (viewModel.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (viewModel.errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(context.tr(viewModel.errorMessage!)),
                ),
              )
            else if (viewModel.filteredHistory.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      Icon(Icons.history_rounded, size: 48, color: context.qsColors.textSub.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text(
                        context.tr('no_transactions_currently'),
                        style: TextStyle(color: context.qsColors.textSub),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.filteredHistory.length,
                itemBuilder: (context, index) {
                  return HistoryListItem(item: viewModel.filteredHistory[index]);
                },
              ),
          ],
        );
      },
    );
  }
}

