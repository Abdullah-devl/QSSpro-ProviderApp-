// مسار الملف: lib/features/orders/views/orders_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../ViewModels/orders_viewmodel.dart';
import '../Models/order_model.dart';
import 'order_detail_view.dart';
import 'package:shimmer/shimmer.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  @override
  void initState() {
    super.initState();
    // جلب الطلبات عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🚀 📦 OrdersView: استدعاء fetchOrders...');
      context.read<OrdersViewModel>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _OrdersBody();
  }
}

class _OrdersBody extends StatelessWidget {
  const _OrdersBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OrdersViewModel>(context);

    return Scaffold(
      backgroundColor: context.qsColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('incoming_orders'),
          style: TextStyle(
            color: context.qsColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.arrow_forward_ios, color: context.qsColors.text),
        //     onPressed: () => Navigator.pop(context),
        //   ),
        // ],
        // leading: IconButton(
        //   icon: Icon(Icons.filter_list_rounded, color: context.qsColors.text),
        //   onPressed: () {},
        // ),
      ),
      body: viewModel.isLoading
          ? _buildLoadingSkeleton(context)
          : Column(
              children: [
                _buildTabs(context, viewModel),
                Divider(height: 1, thickness: 1, color: context.qsColors.textSub.withValues(alpha: 0.1)),
                Expanded(
                  child: viewModel.errorMessage != null
                      ? _buildErrorWidget(context, viewModel)
                      : RefreshIndicator(
                          color: context.qsColors.primary,
                          backgroundColor: context.qsColors.card,
                          onRefresh: () => viewModel.fetchOrders(),
                          child: viewModel.filteredOrders.isEmpty
                              ? _buildEmptyState(context)
                              : ListView.builder(
                                  padding: const EdgeInsets.only(top: 8, bottom: 110),
                                  itemCount: viewModel.filteredOrders.length,
                                  itemBuilder: (context, index) {
                                    return _OrderCardWidget(
                                      order: viewModel.filteredOrders[index],
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final colors = context.qsColors;
    return Shimmer.fromColors(
      baseColor: colors.text.withValues(alpha: 0.08),
      highlightColor: colors.text.withValues(alpha: 0.02),
      child: Column(
        children: [
          // Tabs skeleton
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 110),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 45,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(width: 64, height: 64, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(height: 18, width: 140, color: Colors.white),
                                      const SizedBox(height: 8),
                                      Container(height: 14, width: 80, color: Colors.white),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(height: 14, width: 100, color: Colors.white),
                                Container(height: 24, width: 80, color: Colors.white),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(height: 48, width: double.infinity, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, OrdersViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: context.qsColors.error),
          const SizedBox(height: 16),
          Text(
            context.tr('error_loading_orders'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => viewModel.fetchOrders(),
            child: Text(context.tr('retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: context.qsColors.textSub.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('no_orders_yet'),
            style: TextStyle(fontSize: 18, color: context.qsColors.textSub),
          ),
        ],
      ),
    );
  }


  Widget _buildTabs(BuildContext context, OrdersViewModel viewModel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(viewModel.tabs.length, (index) {
          final isSelected = viewModel.selectedTabIndex == index;
          return GestureDetector(
            onTap: () => viewModel.changeTab(index),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? context.qsColors.primary : context.qsColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? Colors.transparent : context.qsColors.textSub.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                context.tr(viewModel.tabs[index]),
                style: TextStyle(
                  color: isSelected ? context.qsColors.card : context.qsColors.textSub,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _OrderCardWidget extends StatelessWidget {
  final OrderModel order;
  const _OrderCardWidget({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.qsColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.qsColors.text.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Status and Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(context, order.status),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: context.qsColors.textSub,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.formattedDate,
                      style: TextStyle(
                        color: context.qsColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Client and Service Info
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: context.qsColors.background,
                          backgroundImage: order.customerImage.isNotEmpty
                              ? NetworkImage(order.customerImage)
                              : null,
                          child: order.customerImage.isEmpty
                              ? Icon(
                                  Icons.person_outline,
                                  color: context.qsColors.textSub,
                                  size: 36,
                                )
                              : null,
                        ),
                        if (order.isVerified)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: context.qsColors.card,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.verified,
                                color: context.qsColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: context.qsColors.background,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              order.serviceName,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.qsColors.text,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Price and Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: context.qsColors.textSub,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              order.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.qsColors.textSub,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          context.tr('total_price_label'),
                          style: TextStyle(
                            fontSize: 11,
                            color: context.qsColors.textSub,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${order.price.toInt()}',
                                style: TextStyle(
                                  color: context.qsColors.text,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              TextSpan(
                                text: ' ${context.tr('currency_sar')}',
                                style: TextStyle(
                                  color: context.qsColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 24),

                // 4. Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: context.qsColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: context.qsColors.textSub.withValues(alpha: 0.2)),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailView(order: order,),
                            ),
                          );
                        },
                        child: Text(
                          context.tr('details'),
                          style: TextStyle(
                            color: context.qsColors.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const SizedBox(width: 14),
                    if (order.status != 'canceled' &&
                        order.status != 'completed')
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.qsColors.error,
                            foregroundColor: context.qsColors.card,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            context.tr('cancel_order'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'new':
      case 'new_order':
      case 'accepted_initial': // Waiting
        return context.qsColors.primary;
      case 'accepted':
      case 'in_progress':
      case 'accepted_partial_paid':
      case 'accepted_full_paid':
        return context.qsColors.warning;
      case 'completed':
      case 'finished':
        return context.qsColors.success;
      case 'canceled':
      case 'rejected':
        return context.qsColors.error;
      default:
        return context.qsColors.primary;
    }
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    String textKey;
    switch (status.toLowerCase()) {
      case 'pending':
      case 'new':
      case 'new_order':
        textKey = 'status_pending';
        break;
      case 'accepted_initial':
        textKey = 'status_accepted_initial';
        break;
      case 'in_progress':
      case 'accepted_partial_paid':
      case 'accepted_full_paid':
        textKey = 'status_$status';
        break;
      case 'completed':
      case 'finished':
        textKey = 'status_completed';
        break;
      case 'canceled':
      case 'rejected':
        textKey = 'status_$status';
        break;
      default:
        textKey = 'status_$status';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(context, status),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        context.tr(textKey).toUpperCase(),
        style: TextStyle(
          color: context.qsColors.card,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}


