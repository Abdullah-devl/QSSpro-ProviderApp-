import 'package:flutter/material.dart';
import '../models/phone_model.dart';
import '../viewmodels/contact_info_viewmodel.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/dialog_helper.dart';

class AddEditPhoneDialog extends StatefulWidget {
  final ContactInfoViewModel vm;
  final PhoneModel? phone;

  const AddEditPhoneDialog({super.key, required this.vm, this.phone});

  @override
  State<AddEditPhoneDialog> createState() => _AddEditPhoneDialogState();
}

class _AddEditPhoneDialogState extends State<AddEditPhoneDialog> {
  final _phoneController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '');
  String _type = 'mobile';
  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    if (widget.phone != null) {
      _phoneController.text = widget.phone!.phone;
      _countryCodeController.text = widget.phone!.countryCode;
      _type = widget.phone!.type.isNotEmpty ? widget.phone!.type : 'mobile';
      _isPrimary = widget.phone!.isPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.phone == null ? context.tr('auto_tr_68') : context.tr('auto_tr_33')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: context.tr('auto_tr_61'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _countryCodeController,
              decoration: InputDecoration(
                labelText: context.tr('auto_tr_72'),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _type,
              items: [
                DropdownMenuItem(value: 'mobile', child: Text(context.tr('auto_tr_81'))),
                DropdownMenuItem(value: 'whatsapp', child: Text(context.tr('auto_tr_27'))),
                DropdownMenuItem(value: 'both', child: Text(context.tr('auto_tr_89'))),
              ],
              onChanged: (val) => setState(() => _type = val ?? 'mobile'),
              decoration: InputDecoration(labelText: context.tr('auto_tr_56')),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: Text(context.tr('auto_tr_8')),
              value: _isPrimary,
              onChanged: (val) => setState(() => _isPrimary = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
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
            final phoneText = _phoneController.text.trim();
            final country = _countryCodeController.text.trim();
            if (phoneText.isEmpty || country.isEmpty) {
              DialogHelper.showErrorDialog(
                context,
                context.tr('auto_tr_20'),
              );
              return;
            }

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );

            bool success;
            if (widget.phone == null) {
              success = await widget.vm.addPhone(
                phone: phoneText,
                countryCode: country,
                type: _type,
                isPrimary: _isPrimary,
              );
            } else {
              success = await widget.vm.updatePhone(
                id: widget.phone!.id,
                phone: phoneText,
                countryCode: country,
                type: _type,
                isPrimary: _isPrimary,
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
