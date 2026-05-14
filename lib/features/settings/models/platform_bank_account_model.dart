// مسار الملف: lib/features/settings/models/platform_bank_account_model.dart

import '../../../core/network/api_endpoints.dart';

class PlatformBankAccountModel {
  final int id;
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String bankLogo;

  PlatformBankAccountModel({
    required this.id,
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.bankLogo,
  });

  String get logoUrl {
    if (bankLogo.isEmpty) return '';
    return bankLogo.startsWith('http')
        ? bankLogo
        : '${ApiEndpoints.storageBaseUrl}$bankLogo';
  }

  factory PlatformBankAccountModel.fromJson(Map<String, dynamic> json) {
    return PlatformBankAccountModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      accountName: json['account_name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? '',
      bankLogo: json['bank_logo']?.toString() ?? '',
    );
  }
}
