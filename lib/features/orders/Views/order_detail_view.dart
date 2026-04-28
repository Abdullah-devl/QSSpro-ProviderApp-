import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../Models/order_model.dart';
import '../ViewModels/orders_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../commissions/views/pay_commissions_view.dart';
import '../../complaints/views/submit_complaint_view.dart';

class OrderDetailView extends StatefulWidget {
  final OrderModel order;

  const OrderDetailView({super.key, required this.order});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OrdersViewModel>(context);
    // البحث عن أحدث نسخة من الطلب في القائمة الكلية لضمان تحديث البيانات
    final currentOrder = viewModel.allOrders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    // حساب العمولة
    final double commissionAmount =
        double.tryParse(
          currentOrder.rawJson?['order_commission']?.toString() ?? '',
        ) ??
        (currentOrder.price * 0.10);

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
          color: context.qsColors.primary,
          backgroundColor: context.qsColors.card,
          onRefresh: () => viewModel.refreshOrderDetail(currentOrder.id),
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUnifiedRequestCard(context, currentOrder),
                    const SizedBox(height: 32),

                    // 📂 قسم السندات (Receipts)
                    if (currentOrder.bonds.isNotEmpty) ...[
                      _buildSectionHeader(context, 'order_bonds'),
                      const SizedBox(height: 12),
                      _buildReceiptsList(currentOrder),
                      const SizedBox(height: 32),
                    ],

                    // 💰 قسم إدارة الدفع والحالة
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: currentStatusIndex(currentOrder.status) >= 1
                          ? Column(
                              key: ValueKey(
                                'payment_section_${currentOrder.status}',
                              ),
                              children: [
                                _buildPaymentManagerSection(
                                  context,
                                  viewModel,
                                  currentOrder,
                                ),
                                const SizedBox(height: 32),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),

                    // 🏆 قسم العمولة
                    if (currentOrder.status == 'completed' ||
                        currentOrder.status == 'finished') ...[
                      _buildCommissionCard(
                        context,
                        currentOrder,
                        commissionAmount,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.qsColors.warning,
                          foregroundColor: context.qsColors.card,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PayCommissionsView(
                                amount: commissionAmount,
                                orderId: currentOrder.id,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          context.tr('pay_commission'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // ✅ زر اكتمال العمل لمزود الخدمة
                    _buildProviderFinishAction(
                      context,
                      viewModel,
                      currentOrder,
                    ),

                    // 🚩 زر إرسال شكوى
                    if (currentOrder.status == 'accepted_partial_paid' ||
                        currentOrder.status == 'accepted_full_paid' ||
                        currentOrder.status == 'processing') ...[
                      const SizedBox(height: 16),
                      _buildComplaintButton(context, currentOrder.id),
                    ],

                    const SizedBox(height: 48),

                    _buildTotalPriceSection(context, currentOrder),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
              if (viewModel.isLoading)
                Container(
                  color: context.qsColors.text.withValues(alpha: 0.05),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomActions(
          context,
          viewModel,
          currentOrder,
          commissionAmount,
        ),
      ),
    );
  }

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

  Widget _buildComplaintButton(BuildContext context, String orderId) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: context.qsColors.error,
        side: BorderSide(color: context.qsColors.error, width: 2),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubmitComplaintView(orderId: orderId),
          ),
        );
      },
      icon: const Icon(Icons.report_problem_outlined),
      label: Text(
        context.tr('submit_complaint'),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: bond.imagePath.isNotEmpty
                        ? Image.network(
                            bond.imagePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
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

  Widget _buildPaymentManagerSection(
    BuildContext context,
    OrdersViewModel viewModel,
    OrderModel order,
  ) {
    final bool isCompleted = order.status == 'completed';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.qsColors.card,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: context.qsColors.text.withValues(alpha: 0.04), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildSummaryCard(
                context,
                context.tr('paid_currently'),
                '${order.paidAmount}',
                context.qsColors.primary.withValues(alpha: 0.1),
                context.qsColors.primary,
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                context,
                '${((order.paidAmount / order.price) * 100).toStringAsFixed(0)}%',
                '${((order.paidAmount / order.price) * 100).toStringAsFixed(0)}%',
                context.qsColors.success.withValues(alpha: 0.1),
                context.qsColors.success,
                hasBorder: true,
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                context,
                context.tr('remaining_amount'),
                '${order.remainingAmount}',
                context.qsColors.error.withValues(alpha: 0.1),
                context.qsColors.error,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: context.qsColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: context.qsColors.textSub,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr(
                    'required_percentage_to_start',
                    args: {
                      'percentage': order.requiredPartialPercentage.toString(),
                    },
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: context.qsColors.textSub,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip(
                  'pending',
                  context.tr('pending_status'),
                  order.status,
                  context.qsColors.info,
                  context.qsColors.info.withValues(alpha: 0.1),
                ),
                _buildStatusChip(
                  'accepted_initial',
                  context.tr('accepted_status'),
                  order.status,
                  context.qsColors.info,
                  context.qsColors.info.withValues(alpha: 0.1),
                ),
                _buildStatusChip(
                  'accepted_partial_paid',
                  context.tr('working_status'),
                  order.status,
                  context.qsColors.warning,
                  context.qsColors.warning.withValues(alpha: 0.1),
                ),
                _buildStatusChip(
                  'completed',
                  context.tr('completed_status'),
                  order.status,
                  context.qsColors.success,
                  context.qsColors.success.withValues(alpha: 0.1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (!isCompleted)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: context.qsColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.qsColors.primary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.qsColors.primary.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: context.qsColors.text,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.0',
                        hintStyle: TextStyle(color: context.qsColors.textSub),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Text(
                            context.tr('currency_sar'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: context.qsColors.textSub,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildSendButton(context, viewModel, order),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    Color bg,
    Color textColor, {
    bool hasBorder = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: hasBorder ? Border.all(color: context.qsColors.primary.withValues(alpha: 0.1)) : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.qsColors.textSub,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            if (!label.contains('%'))
              Text(
                context.tr('currency_sar'),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  int currentStatusIndex(String status) {
    switch (status) {
      case 'pending':
      case 'new':
        return 0;
      case 'accepted':
      case 'accepted_initial':
        return 1;
      case 'in_progress':
      case 'accepted_partial_paid':
      case 'accepted_full_paid':
        return 2;
      case 'completed':
      case 'finished':
        return 3;
      default:
        return 0;
    }
  }

  Widget _buildStatusChip(
    String code,
    String label,
    String currentStatus,
    Color color,
    Color bgColor,
  ) {
    bool isActive = false;
    bool isPast = false;

    int currentIndex = currentStatusIndex(currentStatus);
    int chipIndex = currentStatusIndex(code);

    if (currentIndex == chipIndex) isActive = true;
    if (currentIndex > chipIndex) isPast = true;

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? bgColor
            : (isPast ? bgColor.withValues(alpha: 0.4) : context.qsColors.background),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? color
              : (isPast ? color.withValues(alpha: 0.5) : context.qsColors.background),
          width: isActive ? 2.5 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(Icons.stars, color: color, size: 16),
            ),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? color.withValues(alpha: 0.9)
                  : (isPast ? color.withValues(alpha: 0.7) : context.qsColors.textSub),
              fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
              fontSize: isActive ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton(
    BuildContext context,
    OrdersViewModel viewModel,
    OrderModel order,
  ) {
    final bool canPay = currentStatusIndex(order.status) > 0;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: canPay
            ? context.qsColors.primary
            : context.qsColors.textSub,
        foregroundColor: context.qsColors.card,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      onPressed: (viewModel.isLoading || !canPay)
          ? null
          : () async {
              final amount = double.tryParse(_amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('enter_valid_amount'))),
                );
                return;
              }
              final success = await viewModel.addPaidAmount(order.id, amount);
              if (success) {
                _amountController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('amount_updated_successfully')),
                  ),
                );
              }
            },
      icon: viewModel.isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: context.qsColors.card,
                strokeWidth: 2,
              ),
            )
          : Icon(canPay ? Icons.send_rounded : Icons.lock_outline, size: 20),
      label: Text(
        viewModel.isLoading
            ? context.tr('loading')
            : (canPay ? context.tr('send_amount') : context.tr('accept_first')),
        style: const TextStyle(fontWeight: FontWeight.bold),
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
                        order.customerPhone.isNotEmpty
                            ? order.customerPhone
                            : '---',
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
                  context.qsColors.primary.withValues(alpha: 0.1),
                  context.qsColors.primary,
                ),
              ],
            ),
          ),

          Divider(height: 1, color: context.qsColors.background),

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

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInlineSectionTitle(context, 'service_details_title'),
                const SizedBox(height: 16),

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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: context.qsColors.background, thickness: 0.5),
                  ),
                  ...order.subServices.map(
                    (sub) => _buildServiceRow(context, sub.name, sub.price),
                  ),
                ],
              ],
            ),
          ),

          Divider(height: 1, color: context.qsColors.background),

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
                        color: context.qsColors.error.withValues(alpha: 0.1),
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
                        context.qsColors.primary.withValues(alpha: 0.1),
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
                  color: isMain
                      ? context.qsColors.warning
                      : context.qsColors.primary,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isMain ? FontWeight.w800 : FontWeight.w600,
                      color: isMain
                          ? context.qsColors.text
                          : context.qsColors.textSub,
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

  Widget _buildProviderFinishAction(
    BuildContext context,
    OrdersViewModel viewModel,
    OrderModel order,
  ) {
    final bool canFinish =
        (order.status == 'accepted_partial_paid' ||
            order.status == 'accepted_full_paid') &&
        !order.providerFinished;

    if (!canFinish) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.qsColors.primary, context.qsColors.primary.withValues(alpha: 0.8)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.qsColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.celebration, color: context.qsColors.card, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr('finish_work_question'),
                    style: TextStyle(
                      color: context.qsColors.card,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final success = await viewModel.finishOrder(order.id);
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.tr('work_completed_successfully'),
                              ),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.qsColors.card,
                  foregroundColor: context.qsColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: viewModel.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: context.qsColors.primary,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        context.tr('confirm_finish_work'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildBottomActions(
    BuildContext context,
    OrdersViewModel viewModel,
    OrderModel order,
    double commissionAmount,
  ) {
    final bool isPending = order.status == 'pending' || order.status == 'new';
    final bool isCompleted = order.status == 'completed';
    final bool isPaidInFull =
        order.paidAmount >= order.price && order.price > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: context.qsColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: context.qsColors.text.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: isPending
          ? Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.qsColors.primary,
                      foregroundColor: context.qsColors.card,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            final success = await viewModel.updateStatus(
                              order.id,
                              'accepted_initial',
                            );
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.tr('order_accepted_success'),
                                  ),
                                ),
                              );
                            }
                          },
                    icon: viewModel.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: context.qsColors.card,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline, size: 24),
                    label: Text(
                      viewModel.isLoading
                          ? context.tr('loading')
                          : context.tr('accept_order'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.qsColors.background,
                      foregroundColor: context.qsColors.textSub,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            final success = await viewModel.updateStatus(
                              order.id,
                              'canceled',
                            );
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.tr('order_canceled_success'),
                                  ),
                                ),
                              );
                            }
                          },
                    icon: viewModel.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: context.qsColors.textSub,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.cancel_outlined, size: 24),
                    label: Text(
                      viewModel.isLoading
                          ? context.tr('loading')
                          : context.tr('reject'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : (isCompleted || isPaidInFull)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCommissionCard(context, order, commissionAmount),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.qsColors.warning,
                    foregroundColor: context.qsColors.card,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PayCommissionsView(
                          amount: commissionAmount,
                          orderId: order.id,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    context.tr('pay_commission'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            )
          : (order.status == 'accepted_partial_paid' ||
                order.status == 'accepted_full_paid' ||
                order.status == 'in_progress')
          ? ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.qsColors.success,
                foregroundColor: context.qsColors.card,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
                shadowColor: context.qsColors.success.withValues(alpha: 0.4),
              ),
              onPressed: viewModel.isLoading
                  ? null
                    : () async {
                       await viewModel.updateStatus(order.id, 'completed');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.tr('commission_note')),
                          backgroundColor: context.qsColors.success,
                        ),
                      );
                    },
              icon: viewModel.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: context.qsColors.card,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle, size: 24),
              label: Text(
                viewModel.isLoading
                    ? context.tr('loading')
                    : context.tr('complete_order'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildCommissionCard(
    BuildContext context,
    OrderModel order,
    double commissionAmount,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.qsColors.warning.withValues(alpha: 0.1), context.qsColors.warning.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.qsColors.warning.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: context.qsColors.warning.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.qsColors.warning,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: context.qsColors.card,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr('total_due_commission'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.qsColors.text,
                  ),
                ),
              ),
              Text(
                '${commissionAmount.toInt()} ${context.tr('currency_sar')}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: context.qsColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: context.qsColors.warning.withValues(alpha: 0.3), thickness: 0.5),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('total_order_price_value', args: {'price': order.price.toInt().toString()}),
                style: TextStyle(fontSize: 11, color: context.qsColors.textSub),
              ),
              Text(
                context.tr('commission_percentage_value', args: {'percentage': '10'}),
                style: TextStyle(fontSize: 11, color: context.qsColors.textSub),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
