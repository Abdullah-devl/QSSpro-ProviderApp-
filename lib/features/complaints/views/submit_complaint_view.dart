import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/qs_color_extension.dart';
import '../viewmodels/submit_complaint_viewmodel.dart';

class SubmitComplaintView extends StatefulWidget {
  final String orderId;

  const SubmitComplaintView({super.key, required this.orderId});

  @override
  State<SubmitComplaintView> createState() => _SubmitComplaintViewState();
}

class _SubmitComplaintViewState extends State<SubmitComplaintView> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('confirm_submit_complaint')),
        content: Text(context.tr('confirm_submit_complaint_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submit();
            },
            child: Text(context.tr('confirm')),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final viewModel = context.read<SubmitComplaintViewModel>();
    final success = await viewModel.submit(
      widget.orderId,
      _subjectController.text,
      _messageController.text,
    );

    if (!mounted) return;

    if (success) {
      _showResultDialog(
        context.tr('success'),
        context.tr('complaint_sent_success'),
        true,
      );
    } else if (viewModel.errorMessage != null) {
      _showResultDialog(
        context.tr('error'),
        context.tr(viewModel.errorMessage!),
        false,
      );
    }
  }

  void _showResultDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (isSuccess) {
                Navigator.pop(context); // Go back to Order Details
              }
            },
            child: Text(context.tr('confirm')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SubmitComplaintViewModel>();
    final Color primaryColor = context.qsColors.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(context.tr('submit_complaint')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🏷️ نوع الشكوى (Dropdown)
            _buildFieldLabel(context.tr('complaint_type')),
            const SizedBox(height: 8),
            _buildDropdownField(context, viewModel),
            const SizedBox(height: 24),

            _buildFieldLabel(context.tr('complaint_subject')),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _subjectController,
              hintText: context.tr('complaint_subject_hint'),
              maxLines: 1,
            ),
            const SizedBox(height: 24),
            _buildFieldLabel(context.tr('complaint_message')),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _messageController,
              hintText: context.tr('complaint_message_hint'),
              maxLines: 6,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: viewModel.isLoading ? null : _showConfirmDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: viewModel.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      context.tr('submit_complaint'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildDropdownField(
    BuildContext context,
    SubmitComplaintViewModel viewModel,
  ) {
    final List<String> types = [
      'type_payment',
      'type_behavior',
      'type_requirements',
      'type_location',
      'type_no_show',
      'type_other',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: viewModel.selectedType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: types.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(
                context.tr(type),
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              viewModel.setSelectedType(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
      ),
    );
  }
}
