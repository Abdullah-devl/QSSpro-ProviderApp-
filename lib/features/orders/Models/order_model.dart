// مسار الملف: lib/features/orders/models/order_model.dart

import '../../../core/network/api_endpoints.dart';

enum OrderStatus { newOrder, inProgress, completed, canceled }

class OrderSubService {
  final String name;
  final double price;

  OrderSubService({required this.name, required this.price});

  factory OrderSubService.fromJson(Map<String, dynamic> json) {
    return OrderSubService(
      name: json['name'] ?? 'خدمة فرعية',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class OrderBond {
  final String id;
  final String bondNumber;
  final String imagePath;
  final double amount;
  final String? description;
  final String status;
  final String? createdAt;

  OrderBond({
    required this.id,
    required this.bondNumber,
    required this.imagePath,
    this.amount = 0.0,
    this.description,
    this.status = 'pending',
    this.createdAt,
  });

  String get imageUrl {
    if (imagePath.isEmpty) return '';
    return imagePath.startsWith('http')
        ? imagePath
        : '${ApiEndpoints.storageBaseUrl}$imagePath';
  }

  factory OrderBond.fromJson(Map<String, dynamic> json) {
    return OrderBond(
      id: json['id']?.toString() ?? '',
      bondNumber: json['bond_number']?.toString() ?? json['number']?.toString() ?? json['amount']?.toString() ?? '---',
      imagePath: json['image_path'] ?? json['image'] ?? json['file_path'] ?? json['file'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString(),
    );
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String serviceName;
  final String customerImage;
  final String customerPhone;
  final bool isVerified;
  final double price;
  final double? oldPrice;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String timeAgo;
  final List<OrderSubService> subServices;
  final String status; // 📝 تم تغييره إلى String لدعم الحالات المحددة
  final String distance;
  final double paidAmount; // 💰 المبلغ المدفوع
  final double requiredPartialPercentage; // 📊 نسبة الدفع الجزئي
  final List<OrderBond> bonds; // 📂 السندات الخاصة بالطلب
  final DateTime? createdAt; // 📅 تاريخ الإنشاء للفرز والدقة
  final Map<String, dynamic>? rawJson; // 🔍 الحزم الأصلية للتشخيص (Diagnostics)
  final bool providerFinished; // ✅ هل انتهى المزود من العمل؟


  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.serviceName,
    required this.customerImage,
    required this.customerPhone,
    this.isVerified = false,
    required this.price,
    this.oldPrice,
    required this.location,
    this.latitude,
    this.longitude,
    this.description,
    required this.timeAgo,
    required this.subServices,
    required this.status,
    this.distance = '---',
    this.paidAmount = 0.0,
    this.requiredPartialPercentage = 0.0,
    this.bonds = const [],
    this.createdAt,
    this.rawJson,
    this.providerFinished = false,
  });

  // 🏆 هل تم دفع العمولة؟ (يُحسب ديناميكياً لتجنب مشاكل التوافق مع الكاش القديم)
  bool get isCommissionPaid {
    if (rawJson == null) return false;
    return rawJson!['commission_paid'] == 1 || rawJson!['commission_paid'] == true;
  }

  // 🔍 التحقق إذا كانت commission_paid تساوي 0 بالتحديد
  bool get isCommissionPaidZero {
    if (rawJson == null) return false;
    final val = rawJson!['commission_paid'];
    return val == 0 || val?.toString() == '0' || val == false;
  }

  // 💰 جلب قيمة العموله من commission_amount
  double get commissionAmount {
    if (rawJson == null) return 0.0;
    return double.tryParse(rawJson!['commission_amount']?.toString() ?? '0') ?? 0.0;
  }

  // 💵 جلب المبلغ المدفوع من العموله من commission_amount_paid
  double get commissionAmountPaid {
    if (rawJson == null) return 0.0;
    return double.tryParse(rawJson!['commission_amount_paid']?.toString() ?? '0') ?? 0.0;
  }

  // 🚀 حساب المبلغ المتبقي (محلياً)
  double get remainingAmount => price - paidAmount;

  // 📅 تنسيق التاريخ بشكل منسق (YYYY/MM/DD)
  String get formattedDate {
    if (createdAt == null) return timeAgo;
    final year = createdAt!.year;
    final month = createdAt!.month.toString().padLeft(2, '0');
    final day = createdAt!.day.toString().padLeft(2, '0');
    return '$year/$month/$day';
  }

  // 🚀 دالة تحويل الـ JSON القادم من السيرفر إلى مودل
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // جلب الحالة كما هي من الباك اند
    String currentStatus = (json['status'] ?? 'pending')
        .toString()
        .toLowerCase();

    // استخراج بيانات المستخدم
    final userData = json['user'] ?? json['seeker'] ?? json['customer'] ?? {};

    // استخراج بيانات الخدمات (الرئيسية والفرعية) من مفتاح services أو الحقول القديمة
    final List allServices = json['services'] ?? json['main_service'] ?? [];
    String serviceName = 'خدمة عامة';
    List<OrderSubService> subServices = [];
    double partialPercentage = 0.0;

    if (allServices.isNotEmpty) {
      // 1. البحث عن الخدمة الرئيسية (التي نوعها main أو ليس لها أب)
      final mainService = allServices.firstWhere(
        (s) => s['type'] == 'main' || s['parent_service_id'] == null,
        orElse: () => allServices[0],
      );

      serviceName = mainService['name'] ?? 'خدمة عامة';
      
      // جلب نسبة الدفع الجزئي
      partialPercentage = double.tryParse(
        mainService['required_partial_percentage']?.toString() ?? '0',
      ) ?? 0.0;

      // 2. استخراج الخدمات الفرعية
      // نبحث عن الخدمات التي نوعها child أو لها أب، أو موجودة كقائمة فرSubService داخل الرئيسية
      final List childFromFlatList = allServices
          .where((s) => s['type'] == 'child' || s['parent_service_id'] != null)
          .toList();

      if (childFromFlatList.isNotEmpty) {
        subServices = childFromFlatList
            .map((e) => OrderSubService.fromJson(e))
            .toList();
      } else if (mainService['sub_services'] != null) {
        final List rawSub = mainService['sub_services'];
        subServices = rawSub.map((e) => OrderSubService.fromJson(e)).toList();
      }
    }

    // استخراج السندات
    final List rawBonds = json['bonds'] ?? json['receipts'] ?? [];
    List<OrderBond> bonds = rawBonds.map((e) => OrderBond.fromJson(e)).toList();

    // تنسيق الوقت
    String timeOnly = '';
    DateTime? fullCreatedAt;
    try {
      fullCreatedAt = DateTime.parse(json['created_at'].toString());
      final hour = fullCreatedAt.hour.toString().padLeft(2, '0');
      final minute = fullCreatedAt.minute.toString().padLeft(2, '0');
      timeOnly = '$hour:$minute';
    } catch (e) {
      timeOnly = (json['created_at_human'] ?? '').toString();
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      customerId: userData['id']?.toString() ?? '',
      customerName: userData['name'] ?? 'عميل',
      customerImage: userData['avatar'] ?? userData['image_path'] ?? '',
      customerPhone: userData['phone'] ?? userData['mobile'] ?? '',
      serviceName: serviceName,
      price: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      oldPrice: json['old_price'] != null
          ? double.tryParse(json['old_price'].toString())
          : null,
      location: json['address'] ?? json['location'] ?? 'الموقع غير محدد',
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      description: json['message'] ?? json['notes'] ?? json['description'],
      timeAgo: timeOnly,
      subServices: subServices,
      status: currentStatus,
      isVerified:
          userData['is_verified'] == 1 || userData['is_verified'] == true,
      distance: (json['distance'] ?? '2.5').toString(),
      paidAmount:
          double.tryParse(
            json['money_paid']?.toString() ??
                json['paid_amount']?.toString() ??
                '0',
          ) ??
          0.0,
      requiredPartialPercentage: partialPercentage,
      bonds: bonds,
      createdAt: fullCreatedAt,
      rawJson: json,
      providerFinished: json['provider_finished'] == 1 || json['provider_finished'] == true,
    );
  }
}
