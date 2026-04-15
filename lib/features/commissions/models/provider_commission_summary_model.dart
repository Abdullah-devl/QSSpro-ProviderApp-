// مسار الملف: lib/features/commissions/models/provider_commission_summary_model.dart

class ProviderCommissionSummaryModel {
  final double totalDueCommission; // إجمالي مبالغ العمولات المطلوبة
  final double totalPaidAlready;    // المبالغ المدفوعة سلفاً
  final double currentBalance;      // الرصيد المتبقي (المديونية)

  ProviderCommissionSummaryModel({
    required this.totalDueCommission,
    required this.totalPaidAlready,
    required this.currentBalance,
  });

  factory ProviderCommissionSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] ?? json;
    return ProviderCommissionSummaryModel(
      totalDueCommission: double.tryParse((summary['total_commission_due'] ?? '0.0').toString()) ?? 0.0,
      totalPaidAlready: double.tryParse((summary['total_commission_paid'] ?? '0.0').toString()) ?? 0.0,
      currentBalance: double.tryParse((summary['remaining_balance'] ?? '0.0').toString()) ?? 0.0,
    );
  }
}
