// مسار الملف: lib/features/settings/views/platform_bank_accounts_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../../../core/network/api_client.dart';
import '../repositories/settings_repository.dart';
import '../viewmodels/platform_bank_accounts_viewmodel.dart';

class PlatformBankAccountsView extends StatelessWidget {
  const PlatformBankAccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    // نغلف الشاشة بمزود الحالة الخاص بها لضمان عملها بشكل فوري ومستقل
    // وتجنب أخطاء الـ ProviderNotFoundError عند عمل Hot Reload بدون Hot Restart
    return ChangeNotifierProvider(
      create: (ctx) => PlatformBankAccountsViewModel(
        SettingsRepository(ctx.read<ApiService>()),
      ),
      child: const _PlatformBankAccountsViewContent(),
    );
  }
}

class _PlatformBankAccountsViewContent extends StatefulWidget {
  const _PlatformBankAccountsViewContent();

  @override
  State<_PlatformBankAccountsViewContent> createState() => _PlatformBankAccountsViewContentState();
}

class _PlatformBankAccountsViewContentState extends State<_PlatformBankAccountsViewContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlatformBankAccountsViewModel>().fetchAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('platform_bank_accounts'),
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer<PlatformBankAccountsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: colors.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: colors.text, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.fetchAccounts(),
                      style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
                      child: Text(context.tr('retry'), style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          final accounts = viewModel.accounts;

          return RefreshIndicator(
            color: colors.primary,
            onRefresh: () => viewModel.fetchAccounts(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 💡 Header Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: colors.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.tr('platform_bank_accounts_desc'),
                          style: TextStyle(
                            color: colors.textSub,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (accounts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.account_balance_outlined, size: 60, color: colors.textSub.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text(
                            context.tr('no_platform_bank_accounts'),
                            style: TextStyle(color: colors.textSub, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...accounts.map((account) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colors.text.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🏦 Bank Header (Logo + Name)
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: colors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: colors.textSub.withValues(alpha: 0.1)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: account.logoUrl.isNotEmpty
                                        ? Image.network(
                                            account.logoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Icon(Icons.account_balance, color: colors.primary, size: 24),
                                          )
                                        : Icon(Icons.account_balance, color: colors.primary, size: 24),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        account.bankName.isNotEmpty ? account.bankName : context.tr('bank_name'),
                                        style: TextStyle(
                                          color: colors.text,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        account.accountName,
                                        style: TextStyle(
                                          color: colors.primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(height: 1),
                            ),
                            // 📋 Account Number / IBAN + Copy Action
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.tr('account_number'),
                                        style: TextStyle(
                                          color: colors.textSub,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        account.accountNumber,
                                        style: TextStyle(
                                          color: colors.text,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          letterSpacing: 0.5,
                                        ),
                                        textDirection: TextDirection.ltr,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: account.accountNumber));
                                    DialogHelper.showSuccessDialog(
                                      context,
                                      context.tr('copy_success'),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: colors.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.copy, color: colors.primary, size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          context.tr('copy'),
                                          style: TextStyle(
                                            color: colors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (account.note.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline, size: 18, color: colors.textSub),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      account.note,
                                      style: TextStyle(
                                        color: colors.textSub,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
