
class UserModel {
  final dynamic id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final String token;
  final bool isVerified; // هذا هو الحقل الذي سنبني عليه الشرط (Middleware)

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    required this.token,
    required this.isVerified,
  });

  // دالة تحويل الـ JSON إلى كائن
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user']['id'],
      name: json['user']['name'] ?? '',
      email: json['user']['email'] ?? '',
      role: json['user']['role'] ?? '',
      phone: json['user']['phone'],
      address: json['user']['address'],
      token: json['token'] ?? '',
      isVerified: json['email_verified'] ?? false,
    );
  }
}