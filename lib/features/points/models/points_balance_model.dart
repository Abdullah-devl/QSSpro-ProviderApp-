// مسار الملف: lib/features/points/models/points_balance_model.dart

class PointsBalanceModel {
  final double bonusPoints; // رصيد نقاط المكافأة (Wallet)
  final double paidPoints; // رصيد الأرباح القابلة للسحب (Earnings)
  final double remainingBalance; // العمولة المتبقية (Due)

  PointsBalanceModel({
    required this.bonusPoints,
    required this.paidPoints,
    this.remainingBalance = 0.0,
  });

  factory PointsBalanceModel.fromJson(Map<String, dynamic> json) {
    // 🚀 قراءة البيانات سواء كانت مباشرة أو داخل summary
    final summary = json['summary'] ?? {};
    
    return PointsBalanceModel(
      bonusPoints: double.tryParse((json['bonus_points'] ?? summary['bonus_points'] ?? '0').toString()) ?? 0.0,
      paidPoints: double.tryParse((json['paid_points'] ?? summary['paid_points'] ?? '0').toString()) ?? 0.0,
      remainingBalance: double.tryParse((json['remaining_balance'] ?? summary['remaining_balance'] ?? '0').toString()) ?? 0.0,
    );
  }
}
