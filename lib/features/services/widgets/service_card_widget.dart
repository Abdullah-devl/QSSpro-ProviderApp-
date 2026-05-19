// مسار الملف: lib/features/services/views/widgets/service_card_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/features/services/models/manage_services_model.dart';
import 'package:service_provider_app/features/services/viewmodels/manage_services_viewmodel.dart';
import 'package:service_provider_app/features/services/views/service_details_view.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/qs_color_extension.dart';
import 'package:service_provider_app/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:service_provider_app/core/utils/dialog_helper.dart';

class ServiceCardWidget extends StatelessWidget {
  final ServiceModel service;
  final Function(ServiceModel)? onToggleStatus;
  final Future<bool?> Function()? onTapOverride;

  const ServiceCardWidget({
    super.key, 
    required this.service,
    this.onToggleStatus,
    this.onTapOverride,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ManageServicesViewModel>(context, listen: false);
    final colors = context.qsColors;
    
    // Check both status string and isActive bool
    final isActive = service.isActive;
    final statusColor = isActive ? colors.success : colors.error;
    final statusBgColor = isActive ? colors.success.withValues(alpha: 0.1) : colors.error.withValues(alpha: 0.1);

    return GestureDetector(
      onTap: () async {
        if (onTapOverride != null) {
          final shouldRefresh = await onTapOverride!();
          if (shouldRefresh == true) {
             Provider.of<ManageServicesViewModel>(context, listen: false).fetchServices();
          }
          return;
        }

        final shouldRefresh = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ServiceDetailsView(serviceId: service.id)),
        );

        if (shouldRefresh == true) {
           Provider.of<ManageServicesViewModel>(context, listen: false).fetchServices();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.textSub.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.text.withValues(alpha: 0.04),
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
                Icon(Icons.more_horiz, color: colors.textSub),
                const Spacer(),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Transform.scale(
                            scale: 0.8,
                              child: Switch.adaptive(
                                value: service.isActive,
                                 onChanged: (_) {
                                  final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
                                  if (profileVM.profile?.isSuspendedForCommissions == true) {
                                    DialogHelper.showErrorDialog(
                                      context,
                                      profileVM.profile?.suspendedMessage ??
                                          context.tr('suspended_commissions_default_msg'),
                                    );
                                    return;
                                  }
                                  if (onToggleStatus != null) {
                                    onToggleStatus!(service);
                                  } else {
                                    viewModel.toggleServiceStatus(service);
                                  }
                                },
                                activeColor: colors.success,
                                inactiveThumbColor: colors.error,
                                inactiveTrackColor: colors.error.withValues(alpha: 0.2),
                              ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              service.status,
                              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.title, 
                        style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.priceText, 
                        style: TextStyle(color: colors.textSub, fontSize: 13),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    service.imageUrl.isNotEmpty ? service.imageUrl : 'https://via.placeholder.com/80',
                    width: 80, height: 80, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80, 
                      height: 80, 
                      color: colors.textSub.withValues(alpha: 0.1),
                      child: Icon(Icons.image_not_supported_outlined, color: colors.textSub),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: colors.textSub.withValues(alpha: 0.1), height: 1),
            const SizedBox(height: 16),
            if (service.isExpanded && service.quickServices.isNotEmpty) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  context.tr('quick_sub_services'), 
                  style: TextStyle(color: colors.textSub, fontSize: 12, fontWeight: FontWeight.bold)
                ),
              ),
              const SizedBox(height: 8),
              ...service.quickServices.map((sub) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Text(sub.price, style: TextStyle(color: colors.textSub, fontSize: 13)),
                        const Spacer(),
                        Text(sub.name, style: TextStyle(color: colors.text, fontSize: 14)),
                        const SizedBox(width: 8),
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: colors.success, shape: BoxShape.circle)),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildEditButton(context),
                  Row(
                    children: [
                      Icon(Icons.arrow_back, color: colors.primary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('manage_all'), 
                        style: TextStyle(color: colors.primary, fontSize: 13, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildEditButton(context),
                  Row(
                    children: [
                      Text(
                        context.tr('sub_services_count', args: {'count': service.subServicesCount.toString()}), 
                        style: TextStyle(color: colors.textSub, fontSize: 13)
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.list_alt_rounded, color: colors.textSub, size: 20),
                    ],
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    final colors = context.qsColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Text(context.tr('edit'), style: TextStyle(color: colors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Icon(Icons.edit, color: colors.primary, size: 14),
        ],
      ),
    );
  }
}