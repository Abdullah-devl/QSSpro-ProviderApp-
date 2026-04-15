import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.qsColors.background,
        appBar: AppBar(
          backgroundColor: context.qsColors.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'الطلبات الخاصة والحضور',
            style: TextStyle(
              color: context.qsColors.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: context.qsColors.text, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            labelColor: context.qsColors.primary,
            unselectedLabelColor: context.qsColors.textSub,
            indicatorColor: context.qsColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: const [
              Tab(text: 'الخدمات المخصصة'),
              Tab(text: 'خدمات الحضور'),
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
                  emptyMessage: 'لا توجد خدمات مخصصة حالياً.',
                  isCustomType: true,
                ),
                // التبويب الثاني: الحضور
                _buildList(
                  context,
                  isLoading: viewModel.isMeetingLoading,
                  error: viewModel.meetingError,
                  services: viewModel.meetingServices,
                  onRefresh: viewModel.loadMeetingServices,
                  emptyMessage: 'لا توجد خدمات حضور حالياً.',
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (services.isEmpty) {
      return RefreshIndicator(
        color: Colors.grey,
        backgroundColor: Colors.white,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Center(
              child: Text(
                emptyMessage,
                style: TextStyle(color: context.qsColors.textSub, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.grey,
      backgroundColor: Colors.white,
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
