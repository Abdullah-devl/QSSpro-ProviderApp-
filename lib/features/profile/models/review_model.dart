// مسار الملف: lib/features/profile/models/review_model.dart

class ReviewModel {
  final int id;
  final double rating;
  final String comment;
  final String createdAt;
  final bool isHidden;
  final ReviewUser user;

  ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.isHidden,
    required this.user,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] ?? '',
      isHidden: json['is_hidden'] == 1 || json['is_hidden'] == true,
      user: ReviewUser.fromJson(json['user'] ?? {}),
    );
  }
}

class ReviewUser {
  final String name;
  final String avatarUrl;

  ReviewUser({
    required this.name,
    required this.avatarUrl,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    // حاولنا تغطية احتمالات مختلفة لاسم حقل الصورة (avatar, avatar_url, image)
    return ReviewUser(
      name: json['name'] ?? 'مستخدم',
      avatarUrl: json['avatar'] ?? json['avatar_url'] ?? json['image'] ?? '',
    );
  }
}
