import 'package:flutter/material.dart';
import '../../../../core/theme/qs_color_extension.dart';
import '../../../../core/localization/app_localizations.dart';
// 3. كارت الطلب الجديد
class NewRequestCard extends StatelessWidget {
  final String title;
  final String location;
  final String distance;
  final String price;
  final String imageUrl;

  const NewRequestCard({
    super.key, required this.title, required this.location, required this.distance, required this.price, required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // التفاصيل
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: context.qsColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(location, style: TextStyle(color: context.qsColors.textSub, fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildTag(context, Icons.location_on_outlined, distance),
                        const SizedBox(width: 8),
                        _buildTag(context, Icons.payments_outlined, price),
                      ],
                    ),
                  ],
                ),
              ),
              // الصورة
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // الأزرار
          Row(
            children: [
              Container(
                decoration: BoxDecoration(border: Border.all(color: context.qsColors.textSub.withOpacity(0.2)), borderRadius: BorderRadius.circular(12)),
                child: IconButton(icon: Icon(Icons.close, color: context.qsColors.textSub), onPressed: () {}),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.qsColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: Text(context.tr('accept_request'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade700, size: 14),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}