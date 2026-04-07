// مسار الملف: lib/features/orders/views/order_detail_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/app_localizations.dart';
import '../Models/order_model.dart';

class OrderDetailView extends StatelessWidget {
  final OrderModel order;

  const OrderDetailView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // إحداثيات افتراضية في حال كانت null (مثلاً وسط الرياض)
    final double lat = order.latitude ?? 24.7136;
    final double lng = order.longitude ?? 46.6753;
    final bool hasCoordinates = order.latitude != null && order.longitude != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          context.tr('details'),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. بيانات طالب الخدمة
            _buildCustomerHeader(context),
            const SizedBox(height: 20),

            // 2. بيانات التواصل
            _buildContactCard(context),
            const SizedBox(height: 20),

            // 3. تفاصيل الخدمات والمبالغ
            _buildServiceDetailsCard(context),
            const SizedBox(height: 20),

            // 4. وصف العميل
            _buildInfoCard(
              context,
              titleKey: 'description_label',
              content: order.description ?? '---',
              icon: Icons.description_outlined,
            ),
            const SizedBox(height: 20),

            // 5. قسم الموقع المتطور (الخريطة والإحداثيات)
            _buildLocationSection(context, lat, lng, hasCoordinates),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBottomActions(context),
    );
  }

  // ... (keeping _buildCustomerHeader, _buildContactCard, _buildServiceDetailsCard, _buildPriceRow as they are)

  Widget _buildLocationSection(BuildContext context, double lat, double lng, bool hasCoordinates) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFFFF4757), size: 20),
                const SizedBox(width: 8),
                Text(
                  context.tr('location_label'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),

          // خريطة جوجل (أو صورة بديلة إذا لم تتوفر إحداثيات)
          Container(
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade100,
            ),
            clipBehavior: Clip.antiAlias,
            child: hasCoordinates
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(target: LatLng(lat, lng), zoom: 15),
                    markers: {
                      Marker(markerId: const MarkerId('client_loc'), position: LatLng(lat, lng)),
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        const Text('الإحداثيات غير متوفرة حالياً', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
          ),

          // تفاصيل العنوان والإحداثيات
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان النصي
                Text(
                  order.location,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
                ),
                const SizedBox(height: 16),
                
                // زر الفتح في خرائط جوجل الخارجية
                if (hasCoordinates)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFF1CB0F6)),
                      ),
                      icon: const Icon(Icons.map, size: 18, color: Color(0xFF1CB0F6)),
                      label: Text(
                        context.tr('open_in_google_maps'),
                        style: const TextStyle(color: Color(0xFF1CB0F6), fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        final String url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF1CB0F6).withOpacity(0.1),
                backgroundImage: order.customerImage.isNotEmpty ? NetworkImage(order.customerImage) : null,
                child: order.customerImage.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Color(0xFF1CB0F6))
                    : null,
              ),
              if (order.isVerified)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.verified, color: Color(0xFF1CB0F6), size: 24),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('customer_info'),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  order.customerName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF2ECC71).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.phone_iphone, color: Color(0xFF2ECC71)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('contact_number'),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                Text(
                  order.customerPhone.isNotEmpty ? order.customerPhone : '---',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                ),
              ],
            ),
          ),
          if (order.customerPhone.isNotEmpty)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.copy, size: 20, color: Colors.blueGrey),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: order.customerPhone));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('copy_success'))),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.room_service_outlined, color: Color(0xFF1CB0F6), size: 20),
              const SizedBox(width: 8),
              Text(
                context.tr('service_details_title'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // الخدمة الأساسية
          _buildPriceRow(context.tr('main_service_label'), order.serviceName, isMain: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          // الخدمات الفرعية
          if (order.subServices.isNotEmpty) ...[
            Text(
              context.tr('sub_services_label'),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...order.subServices.map((sub) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildPriceRow(sub.name, '${sub.price.toInt()} ${context.tr('currency_sar')}'),
            )),
            const Divider(height: 30),
          ],
          // الإجمالي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('total_amount'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              Text(
                '${order.price.toInt()} ${context.tr('currency_sar')}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1CB0F6)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isMain = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isMain ? 15 : 14,
              fontWeight: isMain ? FontWeight.w700 : FontWeight.w500,
              color: isMain ? Colors.black : Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isMain ? 15 : 14,
            fontWeight: isMain ? FontWeight.w800 : FontWeight.w600,
            color: isMain ? const Color(0xFF1CB0F6) : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String titleKey, required String content, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey.shade400, size: 20),
              const SizedBox(width: 8),
              Text(
                context.tr(titleKey),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    if (order.status != OrderStatus.newOrder) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () {},
              child: Text(context.tr('accept_order'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF4757),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFFF4757)),
                ),
              ),
              onPressed: () {},
              child: Text(context.tr('decline_order'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
