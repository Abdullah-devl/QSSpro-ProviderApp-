// مسار الملف: lib/features/points/models/points_balance_model.dart

class PointsBalanceModel {
  final double bonusPoints; // رصيد نقاط المكافأة (Wallet)
  final double paidPoints; // رصيد الأرباح القابلة للسحب (Earnings)

  PointsBalanceModel({required this.bonusPoints, required this.paidPoints});

  factory PointsBalanceModel.fromJson(Map<String, dynamic> json) {
    return PointsBalanceModel(
      bonusPoints:
          double.tryParse(json['bonus_points']?.toString() ?? '0') ?? 0.0,
      paidPoints:
          double.tryParse(json['paid_points']?.toString() ?? '0') ?? 0.0,
    );
  }
}
