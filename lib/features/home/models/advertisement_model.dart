// مسار الملف: lib/features/home/models/advertisement_model.dart

class AdvertisementModel {
  final int id;
  final String title;
  final String imageUrl;
  final String type; // carousel, section, popup
  final String targetType; // service, category, external, none
  final int? targetId;
  final String? externalLink;

  AdvertisementModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.type,
    required this.targetType,
    this.targetId,
    this.externalLink,
  });

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '',
      type: json['type'] ?? 'carousel',
      targetType: json['target_type'] ?? 'none',
      targetId: int.tryParse(json['target_id']?.toString() ?? ''),
      externalLink: json['external_link'],
    );
  }
}
