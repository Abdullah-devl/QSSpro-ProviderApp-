import 'package:flutter/material.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/profile_model.dart';
import '../models/phone_model.dart';
import '../models/bank_model.dart';
import '../viewmodels/contact_info_viewmodel.dart';
import '../widgets/add_edit_phone_dialog.dart';
import '../widgets/add_edit_bank_dialog.dart';

class ContactInfoView extends StatelessWidget {
  final ProfileModel profile;

  const ContactInfoView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ContactInfoViewModel>();

    if (vm.isLoading && vm.phones.isEmpty && vm.banks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 📞 أرقام التواصل
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context, 'أرقام التواصل'),
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: Color.fromARGB(255, 97, 130, 139),
              ),
              onPressed: () => _showPhoneDialog(context, vm, null),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (vm.phones.isEmpty)
          const Center(child: Text('لا توجد أرقام تواصل مضافة'))
        else
          ...vm.phones.map((phone) => _buildPhoneCard(context, vm, phone)),

        const SizedBox(height: 24),

        // 🏦 الحسابات البنكية
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context, 'الحسابات البنكية'),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF5CA4B8)),
              onPressed: () => _showBankDialog(context, vm, null),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (vm.banks.isEmpty)
          const Center(child: Text('لا توجد حسابات بنكية مضافة'))
        else
          ...vm.banks.map((bank) => _buildBankCard(context, vm, bank)),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: context.qsColors.text,
      ),
    );
  }

  // بطاقة رقم الهاتف
  Widget _buildPhoneCard(
    BuildContext context,
    ContactInfoViewModel vm,
    PhoneModel phone,
  ) {
    IconData iconData = Icons.phone_android_rounded;
    Color iconColor = const Color.fromARGB(255, 116, 134, 165);
    String typeText = 'جوال';

    if (phone.type == 'whatsapp') {
      iconData = Icons.chat_bubble_outline_rounded;
      iconColor = context.qsColors.success;
      typeText = 'واتساب';
    } else if (phone.type == 'both') {
      iconData = Icons.phone_in_talk_rounded;
      iconColor = Colors.teal;
      typeText = 'جوال وواتساب';
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.qsColors.textSub),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withOpacity(0.1),
                  child: Icon(iconData, color: iconColor, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          '${phone.countryCode}${phone.phone}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phone.isPrimary ? '$typeText أساسي' : typeText,
                        style: TextStyle(
                          color: phone.isPrimary
                              ? const Color(0xFF5CA4B8)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // لترتيب الأزرار في أقصى اليسار
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.content_copy_rounded,
                    color: Color.fromARGB(255, 63, 61, 61),
                    size: 20,
                  ),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: '${phone.countryCode}${phone.phone}'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ الرقم بنجاح')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color.fromARGB(255, 71, 71, 71),
                    size: 20,
                  ),
                  onPressed: () => _showPhoneDialog(context, vm, phone),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: context.qsColors.error,
                    size: 20,
                  ),
                  onPressed: () => _confirmDeletePhone(context, vm, phone.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankCard(
    BuildContext context,
    ContactInfoViewModel vm,
    BankModel bank,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.qsColors.textSub),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(
                          0xFF5CA4B8,
                        ).withOpacity(0.1),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          color: Color(0xFF5CA4B8),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          bank.bankName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // شارة حالة النشاط
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: bank.isActive
                            ? context.qsColors.success.withOpacity(0.1)
                            : context.qsColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        bank.isActive ? 'نشط' : 'غير نشط',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: bank.isActive
                              ? context.qsColors.success
                              : context.qsColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: context.qsColors.textSub,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showBankDialog(context, vm, bank),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: context.qsColors.error,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _confirmDeleteBank(context, vm, bank.id),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'رقم الحساب / الآيبان: ${bank.accountNumber}',
              style: TextStyle(color: context.qsColors.text),
            ),
          ],
        ),
      ),
    );
  }

  // نوافذ التعديل والإضافة والحذف
  void _showPhoneDialog(
    BuildContext context,
    ContactInfoViewModel vm,
    PhoneModel? phone,
  ) {
    showDialog(
      context: context,
      builder: (_) => AddEditPhoneDialog(vm: vm, phone: phone),
    );
  }

  void _showBankDialog(
    BuildContext context,
    ContactInfoViewModel vm,
    BankModel? bank,
  ) {
    showDialog(
      context: context,
      builder: (_) => AddEditBankDialog(vm: vm, bank: bank),
    );
  }

  void _confirmDeletePhone(
    BuildContext context,
    ContactInfoViewModel vm,
    int id,
  ) {
    _showDeleteDialog(context, () async {
      await vm.deletePhone(id);
    });
  }

  void _confirmDeleteBank(
    BuildContext context,
    ContactInfoViewModel vm,
    int id,
  ) {
    _showDeleteDialog(context, () async {
      await vm.deleteBank(id);
    });
  }

  void _showDeleteDialog(
    BuildContext context,
    Future<void> Function() onDelete,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا العنصر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: context.qsColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );
              await onDelete();
              Navigator.pop(context); // Close loading indicator
            },
            child: Text('حذف', style: TextStyle(color: context.qsColors.card)),
          ),
        ],
      ),
    );
  }
}



