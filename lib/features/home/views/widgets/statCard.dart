import 'package:flutter/material.dart';
import '../../../../core/theme/qs_color_extension.dart';
// 1. كارت الإحصائيات (أرباح الأسبوع / التقييم)
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isPrimary ? context.qsColors.primary : context.qsColors.card;
    final textColor = isPrimary ? context.qsColors.card : context.qsColors.text;
    final subTextColor = isPrimary ? context.qsColors.card.withValues(alpha: 0.8) : context.qsColors.textSub;
    final iconBgColor = isPrimary ? context.qsColors.card.withValues(alpha: 0.2) : context.qsColors.warning.withValues(alpha: 0.1);
    final iconColor = isPrimary ? context.qsColors.card : context.qsColors.warning;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isPrimary ? context.qsColors.primary.withValues(alpha: 0.3) : context.qsColors.text.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(width: 4),
                Text(subtitle, style: TextStyle(color: subTextColor, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
