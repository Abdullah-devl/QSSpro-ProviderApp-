import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../Models/order_model.dart';
import '../ViewModels/orders_viewmodel.dart';

class ReadOnlyOrderDetailView extends StatefulWidget {
  final OrderModel order;

  const ReadOnlyOrderDetailView({super.key, required this.order});

  @override
  State<ReadOnlyOrderDetailView> createState() => _ReadOnlyOrderDetailViewState();
}

class _ReadOnlyOrderDetailViewState extends State<ReadOnlyOrderDetailView> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OrdersViewModel>(context);
    final currentOrder = viewModel.allOrders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.qsColors.background,
        appBar: AppBar(
          backgroundColor: context.qsColors.card,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_forward, color: context.qsColors.text),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            context.tr('details'),
            style: TextStyle(
              color: context.qsColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        body: RefreshIndicator(
          color: context.qsColors.textSub,
          backgroundColor: context.qsColors.card,
          onRefresh: () => viewModel.refreshOrderDetail(currentOrder.id),
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUnifiedRequestCard(context, currentOrder),
                    const SizedBox(height: 32),

                    if (currentOrder.bonds.isNotEmpty) ...[
                      _buildSectionHeader(context, 'order_bonds'),
                      const SizedBox(height: 12),
                      _buildReceiptsList(currentOrder),
                      const SizedBox(height: 32),
                    ],

                    const SizedBox(height: 16),
                    _buildTotalPriceSection(context, currentOrder),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
              if (viewModel.isLoading)
                Container(
                  color: context.qsColors.text.withValues(alpha: 0.05),
                  child: Center(
                    child: CircularProgressIndicator(color: context.qsColors.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-widgets ---

  Widget _buildSectionHeader(BuildContext context, String titleKey) {
    return Text(
      context.tr(titleKey),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: context.qsColors.text,
      ),
    );
  }

  Widget _buildReceiptsList(OrderModel order) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: order.bonds.length,
        itemBuilder: (context, index) {
          final bond = order.bonds[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: context.qsColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.qsColors.text.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: bond.imagePath.isNotEmpty
                        ? Image.network(bond.imagePath, fit: BoxFit.cover, width: double.infinity)
                        : Icon(Icons.receipt_long, color: context.qsColors.textSub),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    bond.bondNumber,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: context.qsColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnifiedRequestCard(BuildContext context, OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        color: context.qsColors.card,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: context.qsColors.text.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👨‍💼 1. رأس البطاقة: بيانات العميل
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: context.qsColors.background,
                        image: order.customerImage.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(order.customerImage),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: order.customerImage.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 40,
                              color: context.qsColors.textSub,
                            )
                          : null,
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: context.qsColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.qsColors.card, width: 3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            order.customerName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: context.qsColors.text,
                            ),
                          ),
                          if (order.isVerified) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.verified,
                              color: context.qsColors.primary,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.customerPhone.isNotEmpty ? order.customerPhone : '---',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.qsColors.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildActionIcon(
                  Icons.chat_bubble_outline,
                  context.qsColors.primary.withOpacity(0.1),
                  context.qsColors.primary,
                ),
              ],
            ),
          ),

          Divider(height: 1, color: context.qsColors.background),

          // 📝 2. وصف الطلب
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInlineSectionTitle(context, 'description_label'),
                const SizedBox(height: 8),
                Text(
                  order.description ?? '---',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: context.qsColors.text,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: context.qsColors.background),

          // 🛠️ 3. تفاصيل الخدمة (المفصلة برؤية المستخدم)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInlineSectionTitle(context, 'service_details_title'),
                const SizedBox(height: 16),

                // الخدمة الأساسية
                _buildServiceRow(
                  context,
                  order.serviceName,
                  order.price -
                      order.subServices.fold(
                        0.0,
                        (sum, sub) => sum + sub.price,
                      ),
                  isMain: true,
                ),

                if (order.subServices.isNotEmpty) ...[
                  Divider(color: context.qsColors.background, thickness: 0.5),
                  ...order.subServices.map(
                    (sub) => _buildServiceRow(context, sub.name, sub.price),
                  ),
                ],
              ],
            ),
          ),

          Divider(height: 1, color: context.qsColors.background),

          // 📍 4. الموقع المرسل مع الطلب
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInlineSectionTitle(context, 'location_label'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.qsColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: context.qsColors.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.location,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: context.qsColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('click_to_open_google_maps'),
                            style: TextStyle(
                              fontSize: 12,
                              color: context.qsColors.textSub,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final url = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${order.latitude},${order.longitude}',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: _buildActionIcon(
                        Icons.near_me_outlined,
                        context.qsColors.primary.withOpacity(0.1),
                        context.qsColors.primary,
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

  Widget _buildServiceRow(
    BuildContext context,
    String name,
    double price, {
    bool isMain = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  isMain ? Icons.star_rounded : Icons.add_circle_outline,
                  size: 18,
                  color: isMain ? context.qsColors.warning : context.qsColors.primary,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isMain ? FontWeight.w800 : FontWeight.w600,
                      color: isMain ? context.qsColors.text : context.qsColors.textSub,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${price.toInt()} ${context.tr('currency_sar')}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isMain ? context.qsColors.primary : context.qsColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineSectionTitle(BuildContext context, String titleKey) {
    return Text(
      context.tr(titleKey),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: context.qsColors.textSub,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color bg, Color iconColor) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  Widget _buildTotalPriceSection(BuildContext context, OrderModel order) {
    return Column(
      children: [
        Text(
          context.tr('total_order_price'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.qsColors.textSub,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${order.price.toInt()}',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: context.qsColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('currency_sar'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: context.qsColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
