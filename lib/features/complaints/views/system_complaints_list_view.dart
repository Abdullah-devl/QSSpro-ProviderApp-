import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/qs_color_extension.dart';
import '../viewmodels/system_complaints_viewmodel.dart';
import 'submit_system_complaint_view.dart';

class SystemComplaintsListView extends StatefulWidget {
  const SystemComplaintsListView({super.key});

  @override
  State<SystemComplaintsListView> createState() => _SystemComplaintsListViewState();
}

class _SystemComplaintsListViewState extends State<SystemComplaintsListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemComplaintsViewModel>().fetchComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SystemComplaintsViewModel>();
    final bgColor = context.qsColors.background;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(context.tr('system_complaints')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: context.qsColors.card,
        foregroundColor: context.qsColors.text,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubmitSystemComplaintView()),
          );
        },
        backgroundColor: context.qsColors.primary,
        icon: Icon(Icons.add, color: context.qsColors.card),
        label: Text(
          context.tr('add_complaint'),
          style: TextStyle(color: context.qsColors.card, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: context.qsColors.textSub, // السهم باللون الرمادي
        backgroundColor: context.qsColors.card, // الدائرة باللون الأبيض
        onRefresh: () => viewModel.fetchComplaints(),
        child: _buildBody(context, viewModel),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SystemComplaintsViewModel viewModel) {
    if (viewModel.isLoading && viewModel.complaints.isEmpty) {
      return Center(child: CircularProgressIndicator(color: context.qsColors.primary));
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: context.qsColors.error),
            const SizedBox(height: 16),
            Text(viewModel.errorMessage!),
            TextButton(
              onPressed: () => viewModel.fetchComplaints(),
              child: Text(context.tr('retry')),
            ),
          ],
        ),
      );
    }

    if (viewModel.complaints.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.speaker_notes_off_outlined, size: 64, color: context.qsColors.textSub),
                const SizedBox(height: 16),
                Text(
                  context.tr('no_system_complaints'),
                  style: TextStyle(color: context.qsColors.textSub, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.complaints.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final complaint = viewModel.complaints[index];
        return _buildComplaintCard(context, complaint);
      },
    );
  }

  Widget _buildComplaintCard(BuildContext context, dynamic complaint) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.qsColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.qsColors.text.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  complaint.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusBadge(context, complaint.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            complaint.content,
            style: TextStyle(fontSize: 14, color: context.qsColors.textSub, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.category_outlined, size: 14, color: context.qsColors.textSub),
              const SizedBox(width: 4),
              Text(
                context.tr(complaint.type),
                style: TextStyle(fontSize: 12, color: context.qsColors.textSub),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    String label;

    switch (status) {
      case 'resolved':
        color = context.qsColors.success;
        label = context.tr('status_resolved');
        break;
      case 'closed':
        color = context.qsColors.textSub;
        label = context.tr('status_closed');
        break;
      default:
        color = context.qsColors.warning;
        label = context.tr('status_pending');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


