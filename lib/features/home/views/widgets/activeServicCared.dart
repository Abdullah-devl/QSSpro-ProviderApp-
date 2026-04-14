import 'package:flutter/material.dart';
import '../../../../core/theme/qs_color_extension.dart';
import '../../../../core/localization/app_localizations.dart';

// 4. كارت الخدمة النشطة
class ActiveServiceCard extends StatelessWidget {
  const ActiveServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.amber.shade400, width: 6)), // الخط الأصفر الجانبي
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text(context.tr('in_progress'), style: TextStyle(color: Colors.amber.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Text('سباكة - إصلاح تسريب', style: TextStyle(color: context.qsColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 14, color: context.qsColors.textSub),
                            const SizedBox(width: 4),
                            Text('${context.tr('client')} فهد العتيبي', style: TextStyle(color: context.qsColors.textSub, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.engineering_outlined, color: Colors.amber.shade600, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: context.qsColors.textSub.withOpacity(0.1)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('تم البدء منذ 45 دقيقة', style: TextStyle(color: context.qsColors.textSub, fontSize: 12)),
                  Row(
                    children: [
                      Text(context.tr('view_details'), style: TextStyle(color: context.qsColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_back, color: context.qsColors.primary, size: 16),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}