import '../../../../core/network/api_endpoints.dart';

class ServiceModel {
  final int id;
  final String title;
  final String imageUrl;
  final double rating;
  bool isActive;

  ServiceModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.rating,
    required this.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // معالجة مسار الصورة ليكون رابطاً كاملاً (ندعم كل الأسماء الممكنة)
    String parsedImageUrl = '';
    final rawImage = json['image_url'] ?? json['image'] ?? json['image_path'] ?? json['icon'];
    if (rawImage != null && rawImage.toString().isNotEmpty) {
      if (rawImage.toString().startsWith('http')) {
        parsedImageUrl = rawImage.toString();
      } else {
        String path = rawImage.toString();
        if (!path.startsWith('/storage/') && !path.startsWith('storage/')) {
          path = '/storage/$path';
        } else if (!path.startsWith('/')) {
          path = '/$path';
        }
        parsedImageUrl = '${ApiEndpoints.domain}$path';
      }
    }

    // معالجة التقييم (ندعم rating و rating_avg و average_rating)
    final ratingRaw = json['rating'] ?? json['rating_avg'] ?? json['average_rating'] ?? 0;

    return ServiceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'خدمة',
      imageUrl: parsedImageUrl,
      rating: double.tryParse(ratingRaw.toString()) ?? 0.0,
      isActive: (json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == '1'),
    );
  }
}
