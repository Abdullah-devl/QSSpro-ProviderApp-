import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../viewmodels/special_services_viewmodel.dart';
import '../widgets/special_service_card_widget.dart';
import '../repositories/manage_services_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import 'custom_service_details_view.dart';
import 'meeting_service_details_view.dart';

class SpecialServicesView extends StatelessWidget {
  const SpecialServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final tokenStorage = TokenStorage();
        final apiService = ApiService(tokenStorage);
        final repository = ManageServicesRepository(apiService);
        final profileRepository = ProfileRepository(apiService);
        return SpecialServicesViewModel(repository, profileRepository);
      },
      child: const _SpecialServicesBody(),
    );
  }
}

class _SpecialServicesBody extends StatelessWidget {
  const _SpecialServicesBody();

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            context.tr('special_services_and_attendance'),
            style: TextStyle(
              color: colors.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: colors.text, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            labelColor: colors.primary,
            unselectedLabelColor: colors.textSub,
            indicatorColor: colors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: [
              Tab(text: context.tr('custom_services')),
              Tab(text: context.tr('attendance_services')),
            ],
          ),
        ),
        body: Consumer<SpecialServicesViewModel>(
          builder: (context, viewModel, child) {
            return TabBarView(
              children: [
                // التبويب الأول: المخصصة
                _buildList(
                  context,
                  isLoading: viewModel.isCustomLoading,
                  error: viewModel.customError,
                  services: viewModel.customServices,
                  onRefresh: viewModel.loadCustomServices,
                  emptyMessage: context.tr('no_custom_services_available'),
                  isCustomType: true,
                ),
                // التبويب الثاني: الحضور
                _buildList(
                  context,
                  isLoading: viewModel.isMeetingLoading,
                  error: viewModel.meetingError,
                  services: viewModel.meetingServices,
                  onRefresh: viewModel.loadMeetingServices,
                  emptyMessage: context.tr('no_attendance_services_available'),
                  isCustomType: false,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context, {
    required bool isLoading,
    required String? error,
    required List services,
    required Future<void> Function() onRefresh,
    required String emptyMessage,
    required bool isCustomType,
  }) {
    final colors = context.qsColors;
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: colors.primary));
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error, style: TextStyle(color: colors.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.card,
              ),
              child: Text(context.tr('retry')),
            ),
          ],
        ),
      );
    }

    if (services.isEmpty) {
      return RefreshIndicator(
        color: colors.primary,
        backgroundColor: colors.card,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Center(
              child: Text(
                emptyMessage,
                style: TextStyle(color: colors.textSub, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.card,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return SpecialServiceCardWidget(
            service: service,
            isCustomType: isCustomType,
            onToggleStatus: (s) {
              final vm = Provider.of<SpecialServicesViewModel>(context, listen: false);
              vm.toggleServiceStatus(s);
            },
            onTapOverride: () async {
              if (isCustomType) {
                return await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CustomServiceDetailsView(serviceId: service.id)),
                );
              } else {
                return await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MeetingServiceDetailsView(serviceId: service.id)),
                );
              }
            },
          );
        },
      ),
    );
  }
}
