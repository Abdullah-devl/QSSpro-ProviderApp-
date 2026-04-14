import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/qs_color_extension.dart';
import '../viewmodels/system_complaints_viewmodel.dart';

class SubmitSystemComplaintView extends StatefulWidget {
  const SubmitSystemComplaintView({super.key});

  @override
  State<SubmitSystemComplaintView> createState() => _SubmitSystemComplaintViewState();
}

class _SubmitSystemComplaintViewState extends State<SubmitSystemComplaintView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5CA4B8)),
            child: Text(context.tr('confirm'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    // ⏳ إظهار نافذة التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF5CA4B8)),
      ),
    );

    final viewModel = context.read<SystemComplaintsViewModel>();
    final success = await viewModel.submitComplaint(
      _titleController.text,
      _contentController.text,
    );

    if (!mounted) return;
    Navigator.pop(context); // 닫기 loading dialog

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
                Navigator.pop(context); // Go back to List
              } else {
                context.read<SystemComplaintsViewModel>().clearError();
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
    final viewModel = context.watch<SystemComplaintsViewModel>();
    final Color primaryColor = const Color(0xFF5CA4B8);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(context.tr('report_system_issue')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🏷️ نوع المشكلة (Dropdown)
            _buildFieldLabel(context.tr('complaint_type')),
            const SizedBox(height: 8),
            _buildDropdownField(context, viewModel),
            const SizedBox(height: 24),

            // 🏷️ العنوان
            _buildFieldLabel(context.tr('complaint_subject')),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _titleController,
              hintText: context.tr('complaint_subject_hint'),
              maxLines: 1,
            ),
            const SizedBox(height: 24),

            // 🏷️ التفاصيل
            _buildFieldLabel(context.tr('complaint_message')),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _contentController,
              hintText: context.tr('complaint_message_hint'),
              maxLines: 6,
            ),
            const SizedBox(height: 48),

            ElevatedButton(
              onPressed: viewModel.isSubmitting ? null : _showConfirmDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: viewModel.isSubmitting
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
    SystemComplaintsViewModel viewModel,
  ) {
    final List<String> types = [
      'type_technical',
      'type_account',
      'type_financial_system',
      'type_suggestion',
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
