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
  final OrderStatus status;

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
  });

  // 🚀 دالة تحويل الـ JSON القادم من السيرفر إلى مودل
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // تحديد حالة الطلب بناءً على الكلمة القادمة من الباك اند
    OrderStatus currentStatus = OrderStatus.newOrder;
    String rawStatus = (json['status'] ?? 'pending').toString().toLowerCase();

    if (rawStatus == 'pending' || rawStatus == 'new' || rawStatus == 'new_order') {
      currentStatus = OrderStatus.newOrder;
    } else if (rawStatus == 'accepted' || rawStatus == 'in_progress' || rawStatus == 'accepted_initial') {
      currentStatus = OrderStatus.inProgress;
    } else if (rawStatus == 'completed' || rawStatus == 'finished' || rawStatus == 'done') {
      currentStatus = OrderStatus.completed;
    } else if (rawStatus == 'canceled' || rawStatus == 'rejected') {
      currentStatus = OrderStatus.canceled;
    }

    // استخراج بيانات المستخدم
    final userData = json['user'] ?? json['seeker'] ?? json['customer'] ?? {};
    
    // استخراج اسم الخدمة والخدمات الفرعية من قائمة main_service
    final List mainServices = json['main_service'] ?? [];
    String serviceName = 'خدمة عامة';
    List<OrderSubService> subServices = [];

    if (mainServices.isNotEmpty) {
      serviceName = mainServices[0]['name'] ?? 'خدمة عامة';
      final List rawSubServices = mainServices[0]['sub_services'] ?? [];
      subServices = rawSubServices.map((e) => OrderSubService.fromJson(e)).toList();
    }

    // تنسيق الوقت لعرض الساعة فقط (مثلاً 14:30)
    String timeOnly = '';
    try {
      final DateTime createdAt = DateTime.parse(json['created_at'].toString());
      final hour = createdAt.hour.toString().padLeft(2, '0');
      final minute = createdAt.minute.toString().padLeft(2, '0');
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
      oldPrice: json['old_price'] != null ? double.tryParse(json['old_price'].toString()) : null,
      location: json['address'] ?? json['location'] ?? 'الموقع غير محدد',
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      description: json['message'] ?? json['notes'] ?? json['description'],
      timeAgo: timeOnly, 
      subServices: subServices,
      status: currentStatus,
      isVerified: userData['is_verified'] == 1 || userData['is_verified'] == true,
    );
  }
}
