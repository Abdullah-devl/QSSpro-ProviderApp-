// مسار الملف: lib/features/services/views/service_details_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/network/api_client.dart';
import 'package:service_provider_app/features/services/viewmodels/service_details_viewmodel.dart';
import 'package:service_provider_app/features/services/viewmodels/service_schedule_viewmodel.dart';
import 'package:service_provider_app/features/services/models/service_schedule_model.dart';
import 'package:service_provider_app/features/services/views/edit_service_view.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../../../core/storage/token_storage.dart';
import '../repositories/manage_services_repository.dart';
import '../models/service_details_model.dart';
import 'edit_service_schedule_view.dart';

class ServiceDetailsView extends StatelessWidget {
  final int serviceId;

  const ServiceDetailsView({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final tokenStorage = TokenStorage();
    final apiService = ApiService(tokenStorage);
    final repository = ManageServicesRepository(apiService);

    return ChangeNotifierProvider(
      create: (_) =>
          ServiceDetailsViewModel(serviceId: serviceId, repository: repository),
      child: const _ServiceDetailsBody(),
    );
  }
}

class _ServiceDetailsBody extends StatelessWidget {
  const _ServiceDetailsBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ServiceDetailsViewModel>(context);
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('service_details'),
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colors.text,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: colors.text),
            onPressed: () {},
          ),
        ],
      ),
      body: viewModel.isLoading
          ? Center(
              child: CircularProgressIndicator(color: colors.primary),
            )
          : viewModel.errorMessage != null
          ? Center(
              child: Text(
                viewModel.errorMessage!,
                style: TextStyle(color: colors.error),
              ),
            )
          : viewModel.serviceDetails == null
          ? Center(child: Text(context.tr('service_not_available')))
          : _buildContent(context, viewModel.serviceDetails!, viewModel),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ServiceDetailsModel service,
    ServiceDetailsViewModel viewModel,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. الصورة العلوية
          _buildHeroImage(context, service),
          const SizedBox(height: 20),

          // 2. كارت التفاصيل الأساسية
          _buildDetailsCard(context, service, viewModel),
          const SizedBox(height: 30),

          // 3. قسم الخدمات الفرعية
          _buildSubServicesSection(context, service, viewModel),
          const SizedBox(height: 30),

          // 4. قسم الجدول الزمني (المواعيد)
          _buildScheduleSection(context, service, viewModel),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, ServiceDetailsModel service) {
    final colors = context.qsColors;
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(
            service.imageUrl.isNotEmpty
                ? service.imageUrl
                : 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=400&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [colors.text.withValues(alpha: 0.9), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: colors.success,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                service.status,
                style: TextStyle(
                  color: colors.card,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service.title,
              style: TextStyle(
                color: colors.card,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(
    BuildContext context,
    ServiceDetailsModel service,
    ServiceDetailsViewModel viewModel,
  ) {
    final colors = context.qsColors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.text.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            context,
            Icons.widgets_outlined,
            context.tr('category'),
            service.categoryName,
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            context,
            Icons.payments_outlined,
            context.tr('base_price'),
            '${service.priceText} / ${context.tr('hour')}',
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            context,
            Icons.description_outlined,
            context.tr('service_description'),
            service.description,
            isParagraph: true,
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.error,
                    foregroundColor: colors.card,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: Text(
                    context.tr('delete_service'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: () =>
                      _showDeleteConfirmationDialog(context, viewModel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.card,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.edit, size: 20),
                  label: Text(
                    context.tr('edit_data'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: () async {
                    final shouldRefresh = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditServiceView(service: service),
                      ),
                    );

                    if (shouldRefresh == true) {
                      viewModel.fetchServiceDetails();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String title,
    String value, {
    bool isParagraph = false,
  }) {
    final colors = context.qsColors;
    return Row(
      crossAxisAlignment: isParagraph
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colors.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: colors.textSub, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 14,
                  fontWeight: isParagraph ? FontWeight.normal : FontWeight.bold,
                  height: isParagraph ? 1.6 : 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubServicesSection(
    BuildContext context,
    ServiceDetailsModel service,
    ServiceDetailsViewModel viewModel,
  ) {
    final colors = context.qsColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('sub_services'),
              style: TextStyle(
                color: colors.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.textSub.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${service.subServices.length} ${context.tr('services')}',
                style: TextStyle(
                  color: colors.textSub,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ...service.subServices.map(
          (sub) => _buildSubServiceItem(context, sub, viewModel),
        ),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: () => _showAddSubServiceDialog(context, viewModel),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle,
                  color: colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('add_sub_service'),
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubServiceItem(
    BuildContext context,
    SubServiceDetailModel sub,
    ServiceDetailsViewModel viewModel,
  ) {
    final colors = context.qsColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.textSub.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: colors.text.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.name,
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (sub.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    sub.description,
                    style: TextStyle(
                      color: colors.textSub,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              sub.priceText,
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.edit, color: colors.primary, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showAddSubServiceDialog(context, viewModel, subToEdit: sub),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(Icons.delete_outline, color: colors.error, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () =>
                _showDeleteSubServiceDialog(context, sub.id, viewModel),
          ),
        ],
      ),
    );
  }

  void _showAddSubServiceDialog(
    BuildContext context,
    ServiceDetailsViewModel viewModel, {
    SubServiceDetailModel? subToEdit,
  }) {
    final colors = context.qsColors;
    final isEditing = subToEdit != null;

    if (isEditing) {
      viewModel.subNameController.text = subToEdit.name;
      viewModel.subPriceController.text = subToEdit.price > 0 
          ? subToEdit.price.toString() 
          : subToEdit.priceText.replaceAll(RegExp(r'[^0-9.]'), '');
      viewModel.subDescriptionController.text = subToEdit.description;
    } else {
      viewModel.subNameController.clear();
      viewModel.subPriceController.clear();
      viewModel.subDescriptionController.clear();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: colors.card,
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEditing ? context.tr('edit_data') : context.tr('add_sub_service'),
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('add_sub_service_subtitle'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.textSub,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          context.tr('sub_service_name'),
                          style: TextStyle(
                            color: colors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDialogTextField(
                        context,
                        controller: viewModel.subNameController,
                        hint: context.tr('sub_service_name_hint'),
                      ),

                      const SizedBox(height: 16),

                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          context.tr('price_sar'),
                          style: TextStyle(
                            color: colors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDialogTextField(
                        context,
                        controller: viewModel.subPriceController,
                        hint: '0.00',
                        isNumber: true,
                        suffix: context.tr('sar'),
                      ),

                      const SizedBox(height: 16),

                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          context.tr('service_description'),
                          style: TextStyle(
                            color: colors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDialogTextField(
                        context,
                        controller: viewModel.subDescriptionController,
                        hint: context.tr('service_description'),
                      ),

                      const SizedBox(height: 30),

                      ChangeNotifierProvider.value(
                        value: viewModel,
                        child: Consumer<ServiceDetailsViewModel>(
                          builder: (context, vm, _) {
                            return Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: vm.isAddingSubService
                                        ? null
                                        : () async {
                                            bool success = isEditing
                                                ? await vm.updateSubService(context, subToEdit.id)
                                                : await vm.addSubService(context);
                                            if (success &&
                                                dialogContext.mounted) {
                                              Navigator.pop(
                                                dialogContext,
                                              );
                                            }
                                          },
                                    child: vm.isAddingSubService
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: colors.card,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            context.tr('save'),
                                            style: TextStyle(
                                              color: colors.card,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () {
                                    vm.subNameController.clear();
                                    vm.subPriceController.clear();
                                    vm.subDescriptionController.clear();
                                    Navigator.pop(dialogContext);
                                  },
                                  child: Text(
                                    context.tr('cancel'),
                                    style: TextStyle(
                                      color: colors.textSub,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -30,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: colors.background,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: colors.primary.withValues(alpha: 0.1),
                    child: Icon(
                      isEditing ? Icons.edit : Icons.add,
                      color: colors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
    String? suffix,
  }) {
    final colors = context.qsColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.textSub.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: colors.text),
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: colors.textSub.withValues(alpha: 0.5),
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    suffix,
                    style: TextStyle(
                      color: colors.textSub,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    ServiceDetailsViewModel viewModel,
  ) {
    final colors = context.qsColors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colors.card,
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: colors.error,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('delete_confirm_title'),
              style: TextStyle(
                color: colors.text,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          context.tr('delete_confirm_msg'),
          style: TextStyle(color: colors.textSub, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.tr('cancel'),
              style: TextStyle(
                color: colors.textSub,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await viewModel.deleteService(context);
              if (success && context.mounted) {
                Navigator.pop(context, true);
              }
            },
            child: Text(
              context.tr('confirm'),
              style: TextStyle(
                color: colors.card,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteSubServiceDialog(
    BuildContext context,
    int subServiceId,
    ServiceDetailsViewModel viewModel,
  ) {
    final colors = context.qsColors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colors.card,
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: colors.error,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('delete_sub_service') ,
              style: TextStyle(
                color: colors.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          context.tr('delete_sub_service_confirm') ,
          style: TextStyle(color: colors.textSub, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.tr('cancel'),
              style: TextStyle(
                color: colors.textSub,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await viewModel.deleteSubService(context, subServiceId);
            },
            child: Text(
              context.tr('confirm') ,
              style: TextStyle(
                color: colors.card,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddEditSchedule(
    BuildContext context,
    ServiceDetailsModel service,
    ServiceDetailsViewModel viewModel, {
    ServiceScheduleModel? scheduleToEdit,
  }) async {
    final tokenStorage = TokenStorage();
    final apiService = ApiService(tokenStorage);
    final repository = ManageServicesRepository(apiService);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ServiceScheduleViewModel(
            repository, 
            service.id, 
            initialSchedule: scheduleToEdit,
          ),
          child: const EditServiceScheduleView(),
        ),
      ),
    );

    viewModel.fetchServiceDetails();
  }

  Widget _buildScheduleSection(
    BuildContext context,
    ServiceDetailsModel service,
    ServiceDetailsViewModel viewModel,
  ) {
    final colors = context.qsColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              context.tr('service_schedule'),
              style: TextStyle(
                color: colors.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _navigateToAddEditSchedule(context, service, viewModel),
              icon: Icon(Icons.add, size: 18, color: colors.primary),
              label: Text(
                context.tr('add_period'),
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: colors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (service.schedules.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                context.tr('no_schedule_message'),
                style: TextStyle(color: colors.textSub),
              ),
            ),
          )
        else
          ...service.schedules.map((schedule) {
            String sTime = schedule.startTime;
            String eTime = schedule.endTime;
            if (sTime.length > 5) sTime = sTime.substring(0, 5);
            if (eTime.length > 5) eTime = eTime.substring(0, 5);

            final formattedSTime = _formatTo12Hour(context, sTime);
            final formattedETime = _formatTo12Hour(context, eTime);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: schedule.isActive
                      ? colors.primary.withValues(alpha: 0.3)
                      : colors.textSub.withValues(alpha: 0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.text.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        schedule.isActive ? Icons.event_available : Icons.event_busy,
                        color: schedule.isActive ? colors.primary : colors.textSub,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (schedule.label != null && (schedule.label!.contains(context.tr('auto_tr_59')) || schedule.label!.contains(context.tr('auto_tr_1'))))
                              ? context.tr('available')
                              : (schedule.label ?? (schedule.isActive ? context.tr('available') : context.tr('not_available'))),
                          style: TextStyle(
                            color: schedule.isActive ? colors.text : colors.textSub,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: colors.primary, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _navigateToAddEditSchedule(context, service, viewModel, scheduleToEdit: schedule),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: colors.error, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          if (schedule.id != null) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: colors.card,
                                title: Text(context.tr('confirm_delete'), style: TextStyle(color: colors.text)),
                                content: Text(context.tr('confirm_delete_schedule'), style: TextStyle(color: colors.textSub)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(context.tr('cancel'), style: TextStyle(color: colors.textSub)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: colors.error),
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      await viewModel.deleteServiceSchedule(context, schedule.id!);
                                    },
                                    child: Text(context.tr('confirm') , style: TextStyle(color: colors.card)),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: colors.textSub, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '$formattedSTime - $formattedETime',
                        style: TextStyle(
                          color: colors.textSub,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (schedule.days.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: schedule.days.map((day) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.tr(day.toLowerCase()),
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }

  String _formatTo12Hour(BuildContext context, String timeStr) {
    if (timeStr.isEmpty) return timeStr;
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
        final periodStr = hour >= 12 
            ? (isArabic ? context.tr('auto_tr_79') : 'PM') 
            : (isArabic ? context.tr('auto_tr_92') : 'AM');
            
        int hour12 = hour % 12;
        if (hour12 == 0) hour12 = 12;
        final minuteStr = minute.toString().padLeft(2, '0');
        return '$hour12:$minuteStr $periodStr';
      }
    } catch (_) {}
    return timeStr;
  }
}
