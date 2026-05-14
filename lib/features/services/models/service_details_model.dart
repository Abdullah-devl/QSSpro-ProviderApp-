// مسار الملف: lib/features/services/models/service_details_model.dart
import '../../../../core/network/api_endpoints.dart';
import 'service_schedule_model.dart';

class ServiceDetailsModel {
  final int id;
  final int categoryId;
  final String title;
  final String description;
  final String priceText;
  final String status;
  final bool isActive;
  final String imageUrl;
  final String categoryName;
  final List<SubServiceDetailModel> subServices;
  final List<ServiceScheduleModel> schedules;
  final int requiredPartialPercentage;
  final bool distanceBasedPrice;
  final double pricePerKm;

  ServiceDetailsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priceText,
    required this.status,
    required this.isActive,
    required this.imageUrl,
    required this.categoryName,
    required this.subServices,
    required this.categoryId,
    this.schedules = const [],
    this.requiredPartialPercentage = 0,
    this.distanceBasedPrice = false,
    this.pricePerKm = 0.0,
  });

  factory ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    bool active = false;
    if (json['is_active'] != null) {
      final val = json['is_active'];
      if (val == 1 || val == '1' || val == true || val == 'true') {
        active = true;
      }
    }
    String currentStatus = active ? 'نشط' : 'غير نشط';

    final categoryData = json['category'];
    String catName = categoryData != null
        ? (categoryData['name'] ?? 'بدون فئة')
        : 'بدون فئة';

    //
    String rawImagePath = json['image_path'] ?? json['image_url'] ?? '';
    String finalImageUrl = '';

    if (rawImagePath.isNotEmpty) {
      if (rawImagePath.startsWith('http')) {
        finalImageUrl = rawImagePath;
      } else {
        // إضافة رابط السيرفر لكي يفهم فلاتر أنه رابط إنترنت وليس ملف محلي
        finalImageUrl = '${ApiEndpoints.domain}/storage/$rawImagePath';
      }
    }

    final childList = json['children'] ?? json['child_services'] ?? [];

    return ServiceDetailsModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      title: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? 'لا يوجد وصف متاح لهذه الخدمة.',
      priceText: '${json['price'] ?? 0} ر.س',
      status: currentStatus,
      isActive: active,
      imageUrl: finalImageUrl,
      categoryName: catName,
      subServices: (childList as List)
          .map((e) => SubServiceDetailModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryId: json['category_id'] != null ? int.tryParse(json['category_id'].toString()) ?? 0 : 0,
      requiredPartialPercentage: json['required_partial_percentage'] != null ? int.tryParse(json['required_partial_percentage'].toString()) ?? 0 : 0,
      distanceBasedPrice: json['distance_based_price'] == 1 || json['distance_based_price'] == '1' || json['distance_based_price'] == true || json['distance_based_price'] == 'true',
      pricePerKm: json['price_per_km'] != null ? double.tryParse(json['price_per_km'].toString()) ?? 0.0 : 0.0,
      schedules: (json['schedules'] as List?)
              ?.map((sch) => ServiceScheduleModel.fromJson(sch as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SubServiceDetailModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String priceText;
  final int categoryId;

  SubServiceDetailModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceText,
    required this.categoryId,
  });

  factory SubServiceDetailModel.fromJson(Map<String, dynamic> json) {
    return SubServiceDetailModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      priceText: '${json['price'] ?? 0} ر.س',
      categoryId: json['category_id'] ?? 0,
    );
  }
}
