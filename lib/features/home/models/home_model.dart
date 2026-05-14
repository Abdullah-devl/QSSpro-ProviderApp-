// مسار الملف: lib/features/home/models/home_model.dart

class HomeDataModel {
  final int totalServices;
  final int totalRequests;
  final int activeRequestsCount;
  final VerificationModel verification;
  final IncomeModel income;
  final CommissionsModel commissions;
  final ServicesPerformanceModel servicesPerformance;
  final List<NewDashboardRequestModel> newRequests;

  HomeDataModel({
    required this.totalServices,
    required this.totalRequests,
    required this.activeRequestsCount,
    required this.verification,
    required this.income,
    required this.commissions,
    required this.servicesPerformance,
    required this.newRequests,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      totalServices: int.tryParse(json['total_services']?.toString() ?? '0') ?? 0,
      totalRequests: int.tryParse(json['total_requests']?.toString() ?? '0') ?? 0,
      activeRequestsCount: int.tryParse(json['active_requests_count']?.toString() ?? '0') ?? 0,
      verification: VerificationModel.fromJson(json['verification'] ?? {}),
      income: IncomeModel.fromJson(json['income'] ?? {}),
      commissions: CommissionsModel.fromJson(json['commissions'] ?? {}),
      servicesPerformance: ServicesPerformanceModel.fromJson(json['services_performance'] ?? {}),
      newRequests: (json['new_requests'] as List?)
              ?.map((e) => NewDashboardRequestModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class VerificationModel {
  final String status;
  final dynamic daysLeft; // Can be int or String "unlimited"
  final String verifiedUntil;

  VerificationModel({
    required this.status,
    required this.daysLeft,
    required this.verifiedUntil,
  });

  factory VerificationModel.fromJson(Map<String, dynamic> json) {
    return VerificationModel(
      status: json['status'] ?? 'not_verified',
      daysLeft: json['days_left'] ?? 0,
      verifiedUntil: json['verified_until'] ?? '',
    );
  }
}

class IncomeModel {
  final double weekly;
  final double monthly;
  final double yearly;

  IncomeModel({
    required this.weekly,
    required this.monthly,
    required this.yearly,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      weekly: double.tryParse(json['weekly']?.toString() ?? '0') ?? 0.0,
      monthly: double.tryParse(json['monthly']?.toString() ?? '0') ?? 0.0,
      yearly: double.tryParse(json['yearly']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class CommissionsModel {
  final double totalOwed;
  final int unpaidRequestsCount;
  final List<UnpaidRequestModel> unpaidRequests;

  CommissionsModel({
    required this.totalOwed,
    required this.unpaidRequestsCount,
    required this.unpaidRequests,
  });

  factory CommissionsModel.fromJson(Map<String, dynamic> json) {
    return CommissionsModel(
      totalOwed: (json['total_owed'] ?? 0.0).toDouble(),
      unpaidRequestsCount: json['unpaid_requests_count'] ?? 0,
      unpaidRequests: (json['unpaid_requests'] as List?)
              ?.map((e) => UnpaidRequestModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class UnpaidRequestModel {
  final int id;
  final String customerName;
  final String totalPrice;
  final double commissionAmount;
  final double paidSoFar;
  final double remainingCommission;
  final String date;

  UnpaidRequestModel({
    required this.id,
    required this.customerName,
    required this.totalPrice,
    required this.commissionAmount,
    required this.paidSoFar,
    required this.remainingCommission,
    required this.date,
  });

  factory UnpaidRequestModel.fromJson(Map<String, dynamic> json) {
    final double commAmount = double.tryParse(json['commission_amount']?.toString() ?? '0') ?? 0.0;
    final double paidAmount = double.tryParse(json['paid_so_far']?.toString() ?? json['commission_amount_paid']?.toString() ?? '0') ?? 0.0;
    final double remainingComm = double.tryParse(json['remaining_commission']?.toString() ?? '0') ?? (commAmount - paidAmount);

    String custName = json['customer_name']?.toString() ?? '';
    if (custName.isEmpty && json['user'] is Map) {
      custName = json['user']['name']?.toString() ?? '';
    }

    String reqDate = json['date']?.toString() ?? '';
    if (reqDate.isEmpty) {
      reqDate = json['created_at']?.toString() ?? '';
    }
    
    try {
      if (reqDate.isNotEmpty) {
        final dateObj = DateTime.parse(reqDate);
        reqDate = '${dateObj.year}/${dateObj.month.toString().padLeft(2, '0')}/${dateObj.day.toString().padLeft(2, '0')}';
      }
    } catch (_) {
      if (reqDate.length > 10) {
        reqDate = reqDate.substring(0, 10).replaceAll('-', '/');
      }
    }

    return UnpaidRequestModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      customerName: custName,
      totalPrice: json['total_price']?.toString() ?? '0',
      commissionAmount: commAmount,
      paidSoFar: paidAmount,
      remainingCommission: remainingComm,
      date: reqDate,
    );
  }
}

class ServicesPerformanceModel {
  final List<PerformanceServiceItem> mostRequested;
  final List<PerformanceServiceItem> allServicesCounts;

  ServicesPerformanceModel({
    required this.mostRequested,
    required this.allServicesCounts,
  });

  factory ServicesPerformanceModel.fromJson(Map<String, dynamic> json) {
    return ServicesPerformanceModel(
      mostRequested: (json['most_requested'] as List?)
              ?.map((e) => PerformanceServiceItem.fromJson(e))
              .toList() ??
          [],
      allServicesCounts: (json['all_services_counts'] as List?)
              ?.map((e) => PerformanceServiceItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PerformanceServiceItem {
  final int id;
  final String name;
  final int requestsCount;
  final String? price;

  PerformanceServiceItem({
    required this.id,
    required this.name,
    required this.requestsCount,
    this.price,
  });

  factory PerformanceServiceItem.fromJson(Map<String, dynamic> json) {
    return PerformanceServiceItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      requestsCount: int.tryParse(json['requests_count']?.toString() ?? '0') ?? 0,
      price: json['price']?.toString(),
    );
  }
}

class NewDashboardRequestModel {
  final int id;
  final String customerName;
  final String mainService;
  final String totalPrice;
  final String createdAt;

  NewDashboardRequestModel({
    required this.id,
    required this.customerName,
    required this.mainService,
    required this.totalPrice,
    required this.createdAt,
  });

  factory NewDashboardRequestModel.fromJson(Map<String, dynamic> json) {
    String formattedDate = json['created_at'] ?? '';
    try {
      if (formattedDate.isNotEmpty) {
        final date = DateTime.parse(formattedDate);
        formattedDate = '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
      }
    } catch (_) {}

    return NewDashboardRequestModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      customerName: json['customer_name'] ?? '',
      mainService: json['main_service'] ?? '',
      totalPrice: json['total_price']?.toString() ?? '0',
      createdAt: formattedDate,
    );
  }
}