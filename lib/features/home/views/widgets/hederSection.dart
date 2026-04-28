import 'package:flutter/material.dart';
import '../../../../core/theme/qs_color_extension.dart';
// 2. هيدر الأقسام (الطلبات الجديدة / الخدمات النشطة)
class SectionHeader extends StatelessWidget {
  final String title;
  final int? badgeCount;
  final String? actionText;
  final VoidCallback? onActionTap;

  const SectionHeader({super.key, required this.title, this.badgeCount, this.actionText, this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(title, style: TextStyle(color: context.qsColors.text, fontSize: 18, fontWeight: FontWeight.bold)),
            if (badgeCount != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: context.qsColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text('$badgeCount', style: TextStyle(color: context.qsColors.error, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ]
          ],
        ),
        if (actionText != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(actionText!, style: TextStyle(color: context.qsColors.primary, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
