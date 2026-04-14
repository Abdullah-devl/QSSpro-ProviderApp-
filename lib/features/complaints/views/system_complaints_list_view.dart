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
    final bgColor = const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(context.tr('system_complaints')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubmitSystemComplaintView()),
          );
        },
        backgroundColor: const Color(0xFF5CA4B8),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          context.tr('add_complaint'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: Colors.grey, // السهم باللون الرمادي
        backgroundColor: Colors.white, // الدائرة باللون الأبيض
        onRefresh: () => viewModel.fetchComplaints(),
        child: _buildBody(context, viewModel),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SystemComplaintsViewModel viewModel) {
    if (viewModel.isLoading && viewModel.complaints.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF5CA4B8)));
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
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
                Icon(Icons.speaker_notes_off_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  context.tr('no_system_complaints'),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.category_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                context.tr(complaint.type),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
        color = Colors.green;
        label = context.tr('status_resolved');
        break;
      case 'closed':
        color = Colors.grey;
        label = context.tr('status_closed');
        break;
      default:
        color = Colors.orange;
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
