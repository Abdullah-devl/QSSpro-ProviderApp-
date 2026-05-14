import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../Models/order_model.dart';
import '../ViewModels/orders_viewmodel.dart';
import '../../../core/utils/dialog_helper.dart';

class ReadOnlyOrderDetailView extends StatefulWidget {
  final OrderModel order;

  const ReadOnlyOrderDetailView({super.key, required this.order});

  @override
  State<ReadOnlyOrderDetailView> createState() => _ReadOnlyOrderDetailViewState();
}

class _ReadOnlyOrderDetailViewState extends State<ReadOnlyOrderDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<OrdersViewModel>(context, listen: false)
            .refreshOrderDetail(widget.order.id);
      }
    });
  }

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
                      _buildReceiptsList(currentOrder, viewModel),
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

  Widget _buildReceiptsList(OrderModel order, OrdersViewModel viewModel) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: order.bonds.length,
        itemBuilder: (context, index) {
          final bond = order.bonds[index];
          return GestureDetector(
            onTap: () => _showBondDetailsDialog(context, bond, order, viewModel),
            child: Container(
              width: 110,
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
                      child: bond.imageUrl.isNotEmpty
                          ? Image.network(
                              bond.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: context.qsColors.textSub),
                            )
                          : Icon(Icons.receipt_long, color: context.qsColors.textSub, size: 40),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      bond.bondNumber.isNotEmpty && bond.bondNumber != 'null' ? bond.bondNumber : '---',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: context.qsColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showBondDetailsDialog(
    BuildContext context,
    OrderBond bond,
    OrderModel order,
    OrdersViewModel viewModel,
  ) {
    final colors = context.qsColors;
    String statusKey = bond.status.toLowerCase().trim();

    Color badgeBgColor;
    Color badgeTextColor;
    String statusText = bond.status;

    if (statusKey == 'approved' || statusKey == 'accepted' || statusKey == 'completed') {
      badgeBgColor = const Color(0xFFE8F5E9);
      badgeTextColor = const Color(0xFF388E3C);
      statusText = 'مقبول';
    } else if (statusKey == 'rejected' || statusKey == 'cancelled') {
      badgeBgColor = const Color(0xFFFFEBEE);
      badgeTextColor = const Color(0xFFC62828);
      statusText = 'مرفوض';
    } else {
      badgeBgColor = const Color(0xFFE1F5FE);
      badgeTextColor = const Color(0xFF0288D1);
      statusText = 'قيد الانتظار';
    }

    final bool isPending = statusKey == 'pending' || statusKey == 'waiting';

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: colors.card,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 📄 Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.receipt_long_rounded, color: colors.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تفاصيل السند',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                            if (bond.createdAt != null && bond.createdAt!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                bond.createdAt!,
                                style: TextStyle(fontSize: 12, color: colors.textSub),
                                textDirection: TextDirection.ltr,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: colors.textSub.withValues(alpha: 0.1)),
                  ),

                  // 💰 Amount & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('المبلغ:', style: TextStyle(fontSize: 14, color: colors.textSub)),
                      Text(
                        '${bond.amount.toStringAsFixed(2)} ${context.tr("currency_sar")}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (bond.bondNumber.isNotEmpty && bond.bondNumber != 'null') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('رقم السند:', style: TextStyle(fontSize: 14, color: colors.textSub)),
                        Text(
                          bond.bondNumber,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (bond.description != null && bond.description!.isNotEmpty) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الوصف:', style: TextStyle(fontSize: 14, color: colors.textSub)),
                        const SizedBox(height: 4),
                        Text(
                          bond.description!,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 🖼️ Image
                  if (bond.imageUrl.isNotEmpty) ...[
                    Text('صورة السند:', style: TextStyle(fontSize: 14, color: colors.textSub)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (imgDialogCtx) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(10),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                InteractiveViewer(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(bond.imageUrl, fit: BoxFit.contain),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                    onPressed: () => Navigator.pop(imgDialogCtx),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          color: colors.background,
                          child: Image.network(
                            bond.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: colors.textSub, size: 40),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 🔘 Status Indicator OR Action Buttons
                  if (!isPending)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'الحالة: $statusText',
                        style: TextStyle(color: badgeTextColor, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            onPressed: () => _confirmBondAction(context, ctx, bond, order, viewModel, isApprove: true),
                            child: const Text('قبول', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.error,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            onPressed: () => _confirmBondAction(context, ctx, bond, order, viewModel, isApprove: false),
                            child: const Text('رفض', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('إغلاق', style: TextStyle(color: colors.textSub, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmBondAction(
    BuildContext context,
    BuildContext parentDialogContext,
    OrderBond bond,
    OrderModel order,
    OrdersViewModel viewModel, {
    required bool isApprove,
  }) async {
    final colors = context.qsColors;
    final title = isApprove ? 'تأكيد قبول السند' : 'تأكيد رفض السند';
    final content = isApprove ? 'هل أنت متأكد من قبول هذا السند؟' : 'هل أنت متأكد من رفض هذا السند؟';
    final successMsg = isApprove ? 'تم قبول السند بنجاح' : 'تم رفض السند بنجاح';

    final bool confirmed = await DialogHelper.showConfirmationDialog(
      context,
      title: title,
      message: content,
      confirmText: isApprove ? 'نعم، قبول' : 'نعم، رفض',
    );

    if (!confirmed) return;

    if (!context.mounted) return;

    // Show temporary loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator(color: colors.primary)),
    );

    final success = isApprove
        ? await viewModel.approveBond(order.id, bond.id)
        : await viewModel.rejectBond(order.id, bond.id);

    if (context.mounted) {
      Navigator.pop(context); // Pop loading indicator
    }

    if (success) {
      if (parentDialogContext.mounted) {
        Navigator.pop(parentDialogContext); // Close details dialog
      }
      if (context.mounted) {
        await DialogHelper.showSuccessDialog(context, successMsg);
      }
    } else {
      if (context.mounted) {
        DialogHelper.showErrorDialog(
          context,
          viewModel.errorMessage ?? 'تعذر إتمام الإجراء، يرجى المحاولة لاحقاً',
        );
      }
    }
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
          InkWell(
            onTap: () => _showSeekerProfile(context, order),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: Padding(
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
                                fontSize: 16,
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
                ],
              ),
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
                  _cleanDescription(order.description),
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

  String _cleanDescription(String? desc) {
    if (desc == null || desc.isEmpty) return '---';

    if (desc.contains('ملاحظات:')) {
      final parts = desc.split('ملاحظات:');
      if (parts.length > 1) {
        final notes = parts.sublist(1).join('ملاحظات:').trim();
        return notes.isEmpty ? '---' : notes;
      }
    }

    final lines = desc.split(RegExp(r'\r?\n'));
    final cleanedLines = lines.where((line) {
      final trimmed = line.trim();
      if (trimmed.startsWith('الاسم:') || trimmed.startsWith('الهاتف:')) {
        return false;
      }
      return true;
    }).toList();

    final result = cleanedLines.join('\n').trim();
    return result.isEmpty ? '---' : result;
  }

  Future<void> _showSeekerProfile(BuildContext context, OrderModel order) async {
    if (order.customerId.isEmpty) {
      DialogHelper.showErrorDialog(context, 'بيانات العميل غير متوفرة');
      return;
    }

    final viewModel = Provider.of<OrdersViewModel>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator(color: context.qsColors.primary)),
    );

    final profileData = await viewModel.getUserProfile(order.customerId);

    if (context.mounted) {
      Navigator.pop(context); // إغلاق مؤشر التحميل
    }

    if (profileData == null || profileData.isEmpty) {
      if (context.mounted) {
        DialogHelper.showErrorDialog(context, viewModel.errorMessage ?? 'تعذر جلب بيانات الملف الشخصي');
      }
      return;
    }

    final profileObj = profileData['profile'] ?? profileData;
    final userObj = profileObj['user'] ?? profileObj;

    final name = userObj['name'] ?? order.customerName;

    // إعداد قائمة بجميع أرقام الهواتف (الأساسي + الإضافية)
    List<String> allPhones = [];
    final defaultPhone = userObj['phone'] ?? userObj['mobile'] ?? order.customerPhone;
    if (defaultPhone.toString().isNotEmpty && defaultPhone.toString() != 'null') {
      allPhones.add(defaultPhone.toString());
    }

    final List? phonesList = profileObj['profile_phones'] as List?;
    if (phonesList != null && phonesList.isNotEmpty) {
      for (var p in phonesList) {
        if (p is Map) {
          final ph = p['phone']?.toString() ?? p['number']?.toString() ?? '';
          if (ph.isNotEmpty && ph != 'null' && !allPhones.contains(ph)) {
            allPhones.add(ph);
          }
        } else {
          final ph = p.toString();
          if (ph.isNotEmpty && ph != 'null' && !allPhones.contains(ph)) {
            allPhones.add(ph);
          }
        }
      }
    }

    if (allPhones.isEmpty) {
      allPhones.add('---');
    }

    final email = userObj['email'] ?? '---';
    final avatar = profileObj['image_url'] ?? profileObj['image_path'] ?? userObj['avatar'] ?? order.customerImage;
    final rating = double.tryParse(userObj['rating_avg']?.toString() ?? '0') ?? 0.0;
    final isVerified = userObj['is_verified'] == 1 || userObj['is_verified'] == true || order.isVerified;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (profileCtx) {
        final colors = profileCtx.qsColors;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: colors.background,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: colors.card,
                      backgroundImage: avatar.toString().isNotEmpty && avatar.toString().startsWith('http')
                          ? NetworkImage(avatar)
                          : null,
                      child: avatar.toString().isEmpty || !avatar.toString().startsWith('http')
                          ? Icon(Icons.person, size: 45, color: colors.textSub)
                          : null,
                    ),
                    if (isVerified)
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.background, width: 2),
                        ),
                        child: const Icon(Icons.verified, color: Colors.white, size: 18),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber.shade500, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.text),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: colors.card, thickness: 1),
                const SizedBox(height: 16),
                ...allPhones.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ph = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildProfileInfoRow(
                      context,
                      Icons.phone_rounded,
                      index == 0 ? 'رقم الهاتف' : 'هاتف إضافي ${index + 1}',
                      ph,
                    ),
                  );
                }),
                _buildProfileInfoRow(context, Icons.email_rounded, 'البريد الإلكتروني', email),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(profileCtx),
                    child: const Text(
                      'إغلاق',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileInfoRow(BuildContext context, IconData icon, String label, String val) {
    final colors = context.qsColors;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: colors.textSub, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                val.isNotEmpty ? val : '---',
                style: TextStyle(fontSize: 14, color: colors.text, fontWeight: FontWeight.bold),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ],
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
