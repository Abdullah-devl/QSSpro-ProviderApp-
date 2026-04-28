
import 'package:flutter/material.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import '../models/bank_model.dart';
import '../viewmodels/contact_info_viewmodel.dart';

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
      title: Text(widget.bank == null ? 'إضافة حساب بنكي' : 'تعديل الحساب البنكي'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasBanks)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text('جاري جلب قائمة البنوك أو لا توجد بنوك متاحة...', style: TextStyle(color: context.qsColors.error, fontSize: 12)),
              ),
            DropdownButtonFormField<int>(
              value: _selectedBankId,
              decoration: const InputDecoration(
                labelText: 'البنك',
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
              decoration: const InputDecoration(
                labelText: 'رقم الحساب أو الآيبان',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // 🔘 حالة النشاط
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'حالة الحساب',
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
                    title: const Text('نشط', style: TextStyle(fontSize: 14)),
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
                    title: const Text('غير نشط', style: TextStyle(fontSize: 14)),
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
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            FocusScope.of(context).unfocus();
            final bankAccount = _bankAccountController.text.trim();

            if (_selectedBankId == null || bankAccount.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('الرجاء اختيار البنك وإدخال رقم الحساب')),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(widget.vm.errorMessage ?? 'حدث خطأ')),
              );
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

