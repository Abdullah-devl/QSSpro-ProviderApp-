import 'package:flutter/material.dart';
import '../../../../core/theme/qs_color_extension.dart';
import '../models/manage_services_model.dart';
import '../../../core/localization/app_localizations.dart';

class SpecialServiceCardWidget extends StatelessWidget {
  final ServiceModel service;
  final Function(ServiceModel)? onToggleStatus;
  final Future<bool?> Function()? onTapOverride;
  final bool isCustomType;

  const SpecialServiceCardWidget({
    super.key,
    required this.service,
    this.onToggleStatus,
    this.onTapOverride,
    this.isCustomType = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = service.isActive;
    final statusColor = isActive ? context.qsColors.success : context.qsColors.error;
    final statusBgColor = isActive ? context.qsColors.success.withValues(alpha: 0.1) : context.qsColors.error.withValues(alpha: 0.1);

    return GestureDetector(
      onTap: () async {
        if (onTapOverride != null) {
          await onTapOverride!();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? context.qsColors.card : context.qsColors.error.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.qsColors.textSub.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: context.qsColors.text.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              service.status,
                              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (onToggleStatus != null)
                            Transform.scale(
                              scale: 0.8,
                              child: Switch.adaptive(
                                value: service.isActive,
                                onChanged: (_) => onToggleStatus!(service),
                                activeColor: context.qsColors.success,
                                inactiveThumbColor: context.qsColors.error,
                                inactiveTrackColor: context.qsColors.error.withValues(alpha: 0.2),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isCustomType ? context.tr('auto_tr_54') : context.tr('auto_tr_71'),
                        style: TextStyle(color: context.qsColors.text, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (!isCustomType)
                        Text(service.priceText, style: TextStyle(color: context.qsColors.textSub, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: service.imageUrl.isNotEmpty
                      ? Image.network(
                          service.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(context),
                        )
                      : _buildPlaceholderIcon(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: context.qsColors.textSub.withOpacity(0.1), height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailsButton(context),
                Icon(Icons.arrow_forward_ios, color: context.qsColors.primary, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      color: context.qsColors.textSub.withValues(alpha: 0.1),
      child: Icon(
        isCustomType ? Icons.design_services : Icons.meeting_room,
        color: context.qsColors.textSub,
      ),
    );
  }

  Widget _buildDetailsButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: context.qsColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Text(context.tr('auto_tr_17'), style: TextStyle(color: context.qsColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Icon(Icons.visibility_rounded, color: context.qsColors.primary, size: 16),
        ],
      ),
    );
  }
}
