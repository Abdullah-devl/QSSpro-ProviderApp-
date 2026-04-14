import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../Models/order_model.dart';
import '../ViewModels/orders_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../commissions/views/pay_commissions_view.dart';

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

    // إحداثيات الطلب
    final double lat = currentOrder.latitude ?? 24.7136;
    final double lng = currentOrder.longitude ?? 46.6753;
    final bool hasCoordinates =
        currentOrder.latitude != null && currentOrder.longitude != null;

    // 🕵️ طباعة بيانات التشخيص عند بناء الصفحة
    debugPrint(
      '🔍 [VIEW] Displaying OrderDetailView for ID: ${currentOrder.id}',
    );
    if (currentOrder.rawJson != null) {
      debugPrint('📦 [VIEW] Raw JSON for this Order: ${currentOrder.rawJson}');
    }

    // حساب العمولة في بداية الـ build لتكون متاحة لكل الأجزاء
    final double commissionAmount =
        double.tryParse(currentOrder.rawJson?['order_commission']?.toString() ?? '') ??
        (currentOrder.price * 0.10);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            context.tr('details'),
            style: const TextStyle(
              color: Color(0xFF1D2126),
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        body: RefreshIndicator(
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

                    // 💰 قسم إدارة الدفع والحالة (تتبع الحالة والمبالغ)
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

                    // 🏆 قسم العمولة (يظهر فقط عند اكتمال الطلب)
                    if (currentOrder.status == 'completed' || currentOrder.status == 'finished') ...[
                      _buildCommissionCard(context, currentOrder, commissionAmount),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA502),
                          foregroundColor: Colors.white,
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

                    _buildLocationSectionHeader(context, currentOrder),
                    const SizedBox(height: 12),
                    _buildLocationMapCard(
                      context,
                      lat,
                      lng,
                      hasCoordinates,
                      currentOrder,
                    ),
                    const SizedBox(height: 48),

                    _buildTotalPriceSection(context, currentOrder),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
              if (viewModel.isLoading)
                Container(
                  color: Colors.black26.withOpacity(0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
        //تبع زر الاكمال 
        // bottomNavigationBar: _buildBottomActions(context, viewModel, currentOrder, commissionAmount),
      ),
    );
  }

  // --- المكونات الفرعية (Sub-widgets) ---

  Widget _buildSectionHeader(BuildContext context, String titleKey) {
    return Text(
      context.tr(titleKey),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: Color(0xFF6E7C87),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                        : const Icon(Icons.receipt_long, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    bond.bondNumber,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          // 1. بطاقات الإحصاءات (Cards Row)
          Row(
            children: [
              _buildSummaryCard(
                context,
                context.tr('paid_currently'),
                '${order.paidAmount}',
                const Color(0xFFE8F6FF),
                const Color(0xFF1CB0F6),
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                context,
                 '${((order.paidAmount / order.price) * 100).toStringAsFixed(0)}%', // The label is actually the amount label above it? Wait, line 294 code says "'المدفوع حالياً', // Actual Paid %"
                '${((order.paidAmount / order.price) * 100).toStringAsFixed(0)}%',
                const Color(0xFFE8F5E9),
                const Color(0xFF2ECC71),
                hasBorder: true,
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                context,
                context.tr('remaining_amount'),
                '${order.remainingAmount}',
                const Color(0xFFFFF1F1),
                const Color(0xFFFF5252),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // عرض النسبة المطلوبة (التعميد) بشكل منفصل وأنيق
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('required_percentage_to_start', args: {'percentage': order.requiredPartialPercentage.toString()}),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. شيبس تتبع الحالة (Status Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip(
                  'pending',
                  context.tr('pending_status'),
                  order.status,
                  const Color(0xFFFF9800),
                  const Color(0xFFFFF3E0),
                ),
                _buildStatusChip(
                  'accepted_initial',
                  context.tr('accepted_status'),
                  order.status,
                  const Color(0xFF1E88E5),
                  const Color(0xFFE3F2FD),
                ),
                _buildStatusChip(
                  'accepted_partial_paid',
                  context.tr('working_status'),
                  order.status,
                  const Color(0xFF673AB7),
                  const Color(0xFFEDE7F6),
                ),
                _buildStatusChip(
                  'completed',
                  context.tr('completed_status'),
                  order.status,
                  const Color(0xFF43A047),
                  const Color(0xFFE8F5E9),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. حقل إدخال المبلغ وزر الإرسال
          if (!isCompleted)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 70, // تكبير المربع
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF1CB0F6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1CB0F6).withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2126),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.0',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Text(
                            context.tr('currency_sar'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
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
          border: hasBorder ? Border.all(color: const Color(0xFFE8F6FF)) : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF90A4AE),
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
            : (isPast ? bgColor.withOpacity(0.4) : const Color(0xFFF9FAFB)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? color
              : (isPast ? color.withOpacity(0.5) : const Color(0xFFF1F5F9)),
          width: isActive ? 2.5 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
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
                  ? color.withOpacity(0.9)
                  : (isPast ? color.withOpacity(0.7) : const Color(0xFF94A3B8)),
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
    // 🚦 التحقق من الحالة: لا يمكن إضافة مبلغ إذا كان الطلب لا يزال "في الانتظار"
    final bool canPay = currentStatusIndex(order.status) > 0;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: canPay
            ? const Color(0xFF1CB0F6)
            : Colors.grey.shade400,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: viewModel.isLoading ? 0 : 0,
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
              debugPrint(
                '🎯 [VIEW] User clicked Add Amount for Order ID: ${order.id}',
              );
              final success = await viewModel.addPaidAmount(order.id, amount);
              if (success) {
                _amountController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('amount_updated_successfully'))),
                );
              }
            },
      icon: viewModel.isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                        color: const Color(0xFFF1F5F9),
                        image: order.customerImage.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(order.customerImage),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: order.customerImage.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xFF90A4AE),
                            )
                          : null,
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
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
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1D2126),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.customerPhone.isNotEmpty
                            ? order.customerPhone
                            : '---',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF90A4AE),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildActionIcon(
                  Icons.chat_bubble_outline,
                  const Color(0xFFE8F6FF),
                  const Color(0xFF1CB0F6),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

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
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5A6B7A),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 🛠️ 3. تفاصيل الخدمة
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInlineSectionTitle(context, 'service_details_title'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.ac_unit,
                        color: Color(0xFF1CB0F6),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        order.serviceName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1D2126),
                        ),
                      ),
                    ),
                    Text(
                      '${order.price.toInt()} ${context.tr('currency_sar')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1CB0F6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...order.subServices.map(
                  (sub) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sub.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6E7C87),
                          ),
                        ),
                        Text(
                          '${sub.price.toInt()} ${context.tr('currency_sar')}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1D2126),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineSectionTitle(BuildContext context, String titleKey) {
    return Text(
      context.tr(titleKey),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: Color(0xFF90A4AE),
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

  Widget _buildLocationSectionHeader(BuildContext context, OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionHeader(context, 'location_label'),
        Row(
          children: [
            const Icon(Icons.near_me, color: Color(0xFF1CB0F6), size: 16),
            const SizedBox(width: 6),
            Text(
              context.tr('distance_away', args: {'distance': order.distance}),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1CB0F6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationMapCard(
    BuildContext context,
    double lat,
    double lng,
    bool hasCoordinates,
    OrderModel order,
  ) {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
        );
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.tr('error_open_google_maps'))),
            );
          }
        }
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(32),
          image: DecorationImage(
            image: NetworkImage(
              'https://api.mapbox.com/styles/v1/mapbox/light-v10/static/pin-s+ff4d4d($lng,$lat)/$lng,$lat,13/600x400?access_token=pk.placeholder',
            ),
            fit: BoxFit.cover,
            opacity: 0.8,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Color(0xFFFF4D4D), size: 40),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Text(
                  order.location,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1D2126),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('click_to_open_google_maps'),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderFinishAction(
    BuildContext context,
    OrdersViewModel viewModel,
    OrderModel order,
  ) {
    // الشروط: حالة الدفع جزئي أو كلي، ولم يسبق تأكيد الانتهاء
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
          gradient: const LinearGradient(
            colors: [Color(0xFF1CB0F6), Color(0xFF1976D2)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1CB0F6).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.celebration, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr('finish_work_question'),
                    style: const TextStyle(
                      color: Colors.white,
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
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1CB0F6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: viewModel.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF90A4AE),
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
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1CB0F6),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('currency_sar'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1CB0F6),
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
    final bool isPending = order.status == 'pending';
    final bool isCompleted = order.status == 'completed';
    final bool isPaidInFull =
        order.paidAmount >= order.price && order.price > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                      backgroundColor: const Color(0xFF1CB0F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: viewModel.isLoading ? 0 : 0,
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
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
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
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: const Color(0xFF5A6B7A),
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
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFF5A6B7A),
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
                    backgroundColor: const Color(0xFFFFA502),
                    foregroundColor: Colors.white,
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
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: viewModel.isLoading ? 0 : 8,
                shadowColor: const Color(0xFF2ECC71).withOpacity(0.4),
              ),
              onPressed: viewModel.isLoading
                  ? null
                  : () {
                      // 🚀 تم تعطيل طلب الباك اند بناءً على طلب المستخدم
                      // await viewModel.updateStatus(order.id, 'completed');

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'سيتم تفعيل هذا الزر قريباً مع اللوجك الجديد',
                          ),
                          backgroundColor: Color(0xFF2ECC71),
                        ),
                      );
                    },
              icon: viewModel.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
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

  Widget _buildCommissionCard(BuildContext context, OrderModel order, double commissionAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF9DB), Color(0xFFFFF4D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFA502).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA502).withOpacity(0.1),
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
                  color: const Color(0xFFFFA502),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr('total_due_commission'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5E00),
                  ),
                ),
              ),
              Text(
                '${commissionAmount.toInt()} ${context.tr('currency_sar')}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD48100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFFFA502), thickness: 0.5),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي قيمة الطلب: ${order.price.toInt()} ر.س',
                style: const TextStyle(fontSize: 11, color: Color(0xFF8B5E00)),
              ),
              const Text(
                'نسبة العمولة: 10%',
                style: TextStyle(fontSize: 11, color: Color(0xFF8B5E00)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
