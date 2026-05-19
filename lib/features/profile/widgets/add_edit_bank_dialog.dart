
import 'package:flutter/material.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import '../models/bank_model.dart';
import '../viewmodels/contact_info_viewmodel.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/dialog_helper.dart';

class AddEditBankDialog extends StatefulWidget {
  final ContactInfoViewModel vm;
  final BankModel? bank;

  const AddEditBankDialog({super.key, required this.vm, this.bank});

  @override
  State<AddEditBankDialog> createState() => _AddEditBankDialogState();
}

class _AddEditBankDialogState extends State<AddEditBankDialog> {
  final _bankAccountController = TextEditingController();
  int? _selectedBankId;
  bool _isActive = true; // الحالة الافتراضية: نشط

  @override
  void initState() {
    super.initState();
    if (widget.bank != null) {
      _bankAccountController.text = widget.bank!.accountNumber;
      _isActive = widget.bank!.isActive; // تعبئة الحالة الحالية
      // محاولة المطابقة مع قائمة البنوك إذا كان البنك موجودًا
      if (widget.bank!.bankId != 0 && widget.vm.systemBanks.any((b) => b.id == widget.bank!.bankId)) {
        _selectedBankId = widget.bank!.bankId;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasBanks = widget.vm.systemBanks.isNotEmpty;

    return AlertDialog(
      title: Text(widget.bank == null ? context.tr('auto_tr_49') : context.tr('auto_tr_87')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasBanks)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(context.tr('auto_tr_35'), style: TextStyle(color: context.qsColors.error, fontSize: 12)),
              ),
            DropdownButtonFormField<int>(
              initialValue: _selectedBankId,
              decoration: InputDecoration(
                labelText: context.tr('auto_tr_7'),
                border: OutlineInputBorder(),
              ),
              items: widget.vm.systemBanks.map((bank) {
                return DropdownMenuItem<int>(
                  value: bank.id,
                  child: Text(bank.name),
                );
              }).toList(),
              onChanged: hasBanks ? (val) {
                setState(() => _selectedBankId = val);
              } : null,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bankAccountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.tr('auto_tr_70'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // 🔘 حالة النشاط
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                context.tr('auto_tr_90'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: context.qsColors.text,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(context.tr('auto_tr_21'), style: TextStyle(fontSize: 14)),
                    value: true,
                    groupValue: _isActive,
                    activeColor: const Color(0xFF5CA4B8),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (val) => setState(() => _isActive = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(context.tr('auto_tr_15'), style: TextStyle(fontSize: 14)),
                    value: false,
                    groupValue: _isActive,
                    activeColor: context.qsColors.error,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (val) => setState(() => _isActive = val!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('auto_tr_51')),
        ),
        ElevatedButton(
          onPressed: () async {
            FocusScope.of(context).unfocus();
            final bankAccount = _bankAccountController.text.trim();

            if (_selectedBankId == null || bankAccount.isEmpty) {
              DialogHelper.showErrorDialog(
                context,
                context.tr('auto_tr_5'),
              );
              return;
            }

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );

            bool success;
            if (widget.bank == null) {
              success = await widget.vm.addBank(
                bankId: _selectedBankId!,
                bankAccount: bankAccount,
                isActive: _isActive,
              );
            } else {
              success = await widget.vm.updateBank(
                id: widget.bank!.id,
                bankId: _selectedBankId!,
                bankAccount: bankAccount,
                isActive: _isActive,
              );
            }

            Navigator.pop(context); // Close loading
            if (success) {
              Navigator.pop(context); // Close dialog
            } else {
              DialogHelper.showErrorDialog(
                context,
                widget.vm.errorMessage != null
                    ? context.tr(widget.vm.errorMessage!)
                    : context.tr('auto_tr_64'),
              );
            }
          },
          child: Text(context.tr('auto_tr_77')),
        ),
      ],
    );
  }
}

