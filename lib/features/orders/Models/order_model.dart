// مسار الملف: lib/features/orders/models/order_model.dart

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

  OrderBond({
    required this.id,
    required this.bondNumber,
    required this.imagePath,
  });

  factory OrderBond.fromJson(Map<String, dynamic> json) {
    return OrderBond(
      id: json['id']?.toString() ?? '',
      bondNumber: json['bond_number']?.toString() ?? '---',
      imagePath: json['image_path'] ?? '',
    );
  }
}

class OrderModel {
  final String id;
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

  OrderModel({
    required this.id,
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
  });

  // 🚀 حساب المبلغ المتبقي (محلياً)
  double get remainingAmount => price - paidAmount;

  // 🚀 دالة تحويل الـ JSON القادم من السيرفر إلى مودل
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // جلب الحالة كما هي من الباك اند
    String currentStatus = (json['status'] ?? 'pending')
        .toString()
        .toLowerCase();

    // استخراج بيانات المستخدم
    final userData = json['user'] ?? json['seeker'] ?? json['customer'] ?? {};

    // استخراج اسم الخدمة والخدمات الفرعية والنسبة المطلوبة
    final List mainServices = json['main_service'] ?? [];
    String serviceName = 'خدمة عامة';
    List<OrderSubService> subServices = [];
    double partialPercentage = 0.0;

    if (mainServices.isNotEmpty) {
      final firstService = mainServices[0];
      serviceName = firstService['name'] ?? 'خدمة عامة';
      partialPercentage =
          double.tryParse(
            firstService['required_partial_percentage']?.toString() ?? '0',
          ) ??
          0.0;

      final List rawSubServices = firstService['sub_services'] ?? [];
      subServices = rawSubServices
          .map((e) => OrderSubService.fromJson(e))
          .toList();
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
    );
  }
}
