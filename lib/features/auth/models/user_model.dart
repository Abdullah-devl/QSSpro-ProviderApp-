
class UserModel {
  final dynamic id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final String token;
  final bool isVerified; // هذا هو الحقل الذي سنبني عليه الشرط (Middleware)
  final bool providerPolicy; // تمت إضافته للتحقق من الموافقة على السياسة

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    required this.token,
    required this.isVerified,
    this.providerPolicy = false,
  });

  // دالة تحويل الـ JSON إلى كائن
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // استخراج قيمة الموافقة (قد تكون 1، أو true)
    final userJson = json['user'] ?? {};
    final provPolVal = userJson['provider_policy'];
    final providerPolicy = provPolVal == 1 || provPolVal == true || provPolVal == '1' || provPolVal == 'true';

    return UserModel(
      id: userJson['id'],
      name: userJson['name'] ?? '',
      email: userJson['email'] ?? '',
      role: userJson['role'] ?? '',
      phone: userJson['phone'],
      address: userJson['address'],
      token: json['token'] ?? json['access_token'] ?? '',
      isVerified: json['email_verified'] == true || 
                  json['email_verified'] == 1 || 
                  json['is_verified'] == true || 
                  json['is_verified'] == 1 ||
                  userJson['email_verified_at'] != null,
      providerPolicy: providerPolicy,
    );
  }
}