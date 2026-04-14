// مسار الملف: lib/features/commissions/models/commission_model.dart

class CommissionSummaryModel {
  final double dueAmount;
  final bool isVerified;
  final int availablePoints; // رصيد النقاط المشحون
  final int bonusPoints; // رصيد نقاط المكافأة (Wallet)
  final int paidPoints; // الرصيد القابل للسحب (الأرباح)
  final int pointsConversionFactor; // كم نقطة لكل 1 ريال

  CommissionSummaryModel({
    required this.dueAmount,
    required this.isVerified,
    required this.availablePoints,
    required this.bonusPoints,
    required this.paidPoints,
    required this.pointsConversionFactor,
  });

  factory CommissionSummaryModel.fromJson(Map<String, dynamic> json) {
    return CommissionSummaryModel(
      dueAmount: (json['due_amount'] ?? 0.0).toDouble(),
      isVerified: json['is_verified'] ?? false,
      availablePoints: (json['available_points'] ?? 0).toInt(),
      bonusPoints: (json['bonus_points'] ?? json['available_points'] ?? 0).toInt(),
      paidPoints: (json['paid_points'] ?? 0).toInt(),
      pointsConversionFactor: (json['points_conversion_factor'] ?? 100).toInt(),
    );
  }
}

class CommissionTransactionModel {
  final String id;
  final String title;
  final String date;
  final double amount;
  final String status; // 'completed', 'pending', 'archived', 'processing'

  CommissionTransactionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
  });

  factory CommissionTransactionModel.fromJson(Map<String, dynamic> json) {
    return CommissionTransactionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
    );
  }
}

class CommissionDataModel {
  final CommissionSummaryModel summary;
  final List<CommissionTransactionModel> transactions;

  CommissionDataModel({
    required this.summary,
    required this.transactions,
  });

  factory CommissionDataModel.fromJson(Map<String, dynamic> json) {
    return CommissionDataModel(
      summary: CommissionSummaryModel.fromJson(json['summary'] ?? {}),
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => CommissionTransactionModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
