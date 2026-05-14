import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../../home/models/home_model.dart';
import '../viewmodels/unpaid_commissions_viewmodel.dart';
import 'pay_commissions_view.dart';

class UnpaidCommissionsView extends StatefulWidget {
  const UnpaidCommissionsView({super.key});

  @override
  State<UnpaidCommissionsView> createState() => _UnpaidCommissionsViewState();
}

class _UnpaidCommissionsViewState extends State<UnpaidCommissionsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UnpaidCommissionsViewModel>().fetchUnpaidCommissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UnpaidCommissionsViewModel>(context);
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('unpaid_requests_count'),
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded, color: colors.text, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        leading: const SizedBox.shrink(),
      ),
      body: RefreshIndicator(
        color: colors.primary,
        backgroundColor: colors.card,
        onRefresh: () => viewModel.fetchUnpaidCommissions(),
        child: viewModel.isLoading
            ? _buildSkeleton(context)
            : viewModel.errorMessage != null
                ? _buildErrorState(context, viewModel)
                : viewModel.unpaidRequests.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        itemCount: viewModel.unpaidRequests.length,
                        itemBuilder: (context, index) {
                          final item = viewModel.unpaidRequests[index];
                          return _buildRequestCard(context, item);
                        },
                      ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, UnpaidRequestModel item) {
    final colors = context.qsColors;
    final double amountToPay = item.remainingCommission > 0 ? item.remainingCommission : item.commissionAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.text.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: colors.error.withValues(alpha: 0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PayCommissionsView(
                  amount: amountToPay,
                  orderId: item.id.toString(),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: ID and Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${context.tr('request_id')} #${item.id}",
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (item.date.isNotEmpty)
                      Text(
                        item.date,
                        style: TextStyle(color: colors.textSub, fontSize: 11),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Customer Name
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, color: colors.textSub, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.customerName.isNotEmpty ? item.customerName : '---',
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: colors.textSub.withValues(alpha: 0.1)),
                const SizedBox(height: 12),

                // Financial details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('total_order_price'),
                          style: TextStyle(color: colors.textSub, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${item.totalPrice} ${context.tr('sar')}",
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          context.tr('due_commission'),
                          style: TextStyle(color: colors.error, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              amountToPay.toStringAsFixed(2),
                              style: TextStyle(
                                color: colors.error,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.tr('sar'),
                              style: TextStyle(color: colors.error, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                // Call to action bar
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.tr('pay_now'),
                        style: TextStyle(color: colors.error, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.arrow_forward_ios_rounded, color: colors.error, size: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final colors = context.qsColors;
    return Shimmer.fromColors(
      baseColor: colors.text.withValues(alpha: 0.08),
      highlightColor: colors.text.withValues(alpha: 0.02),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          height: 180,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, UnpaidCommissionsViewModel vm) {
    final colors = context.qsColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: colors.error, size: 60),
          const SizedBox(height: 16),
          Text(
            context.tr(vm.errorMessage ?? 'error_occurred'),
            style: TextStyle(color: colors.error, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => vm.fetchUnpaidCommissions(),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(context.tr('retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.qsColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: colors.success, size: 80),
          const SizedBox(height: 16),
          Text(
            context.tr('no_orders_yet'),
            style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
