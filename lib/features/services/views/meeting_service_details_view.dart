import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/network/api_client.dart';
import 'package:service_provider_app/core/storage/token_storage.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../repositories/manage_services_repository.dart';
import '../viewmodels/meeting_service_viewmodel.dart';
import 'edit_meeting_service_view.dart';

class MeetingServiceDetailsView extends StatelessWidget {
  final int serviceId;

  const MeetingServiceDetailsView({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final api = ApiService(TokenStorage());
        final repo = ManageServicesRepository(api);
        return MeetingServiceViewModel(repo, serviceId);
      },
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MeetingServiceViewModel>(context);
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          context.tr('attendance_service_details'),
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.text, size: 20),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          if (viewModel.service != null)
            IconButton(
              icon: Icon(Icons.edit, color: colors.primary),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) {
                    return ChangeNotifierProvider.value(
                      value: viewModel,
                      child: const EditMeetingServiceView(),
                    );
                  }),
                );
                if (result == true) {
                  viewModel.fetchDetails();
                }
              },
            ),
        ],
      ),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : viewModel.errorMessage != null
              ? Center(child: Text(viewModel.errorMessage!, style: TextStyle(color: colors.error)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الحالة
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.textSub.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr('status_label', args: {'status': viewModel.service!.status}),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: viewModel.service!.isActive ? colors.success : colors.textSub,
                              ),
                            ),
                            Icon(
                              viewModel.service!.isActive ? Icons.check_circle : Icons.cancel,
                              color: viewModel.service!.isActive ? colors.success : colors.textSub,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // السعر الأساسي وسعر الكيلو
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              title: context.tr('service_price'),
                              value: viewModel.service!.priceText,
                              icon: Icons.attach_money,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              title: context.tr('price_per_km_label'),
                              value: '${viewModel.service!.pricePerKm} ${context.tr('sar')}',
                              icon: Icons.directions_car,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // الوصف
                      Text(
                        context.tr('service_description'),
                        style: TextStyle(color: colors.primary, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.textSub.withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          viewModel.service!.description.isNotEmpty ? viewModel.service!.description : context.tr('no_description_available'),
                          style: TextStyle(color: colors.text, fontSize: 15, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required String value, required IconData icon}) {
    final colors = context.qsColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.textSub.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary, size: 24),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: colors.textSub, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
