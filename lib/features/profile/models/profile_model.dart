// مسار الملف: lib/features/profile/models/profile_model.dart
import '../../../../core/network/api_endpoints.dart';
import 'phone_model.dart';
import 'bank_model.dart';

class ProfileModel {
  // 🗄️ حقول جدول users
  final int id;
  final String name;
  final String email;
  final String role;
  final double ratingAvg;
  final bool noCommission;
  final double commission;
  final bool seekerPolicy;
  final bool providerPolicy;
  final bool verificationProvider;
  final DateTime? providerVerifiedUntil;
  final double bonusPoints;
  final double paidPoints;

  // 🎨 حقول جدول profiles
  final String jobTitle;
  final String bio;
  final String avatarUrl;
  final int completedJobs;
  final int yearsExperience;
  final List<String> worksImages;
  final bool isAvailable;

  // 📞 بيانات التواصل الإضافية والحسابات البنكية من الباك إند
  final List<PhoneModel> phones;
  final List<BankModel> banks;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.ratingAvg,
    required this.noCommission,
    required this.commission,
    required this.seekerPolicy,
    required this.providerPolicy,
    required this.verificationProvider,
    this.providerVerifiedUntil,
    required this.bonusPoints,
    required this.paidPoints,
    this.jobTitle = '',
    this.bio = '',
    this.avatarUrl = '',
    this.completedJobs = 0,
    this.yearsExperience = 0,
    this.worksImages = const [],
    this.isAvailable = true,
    this.phones = const [],
    this.banks = const [],
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // 🚀 الذكاء الاصطناعي هنا: إذا كانت بيانات المستخدم داخل مفتاح 'user' نستخدمه
    final userJson = json['user'] ?? json;

    return ProfileModel(
      id: json['id'] ?? userJson['id'] ?? 0, // نأخذ ID البروفايل أو المستخدم
      name: userJson['name'] ?? 'مستخدم غير معروف',
      email: userJson['email'] ?? '',
      role: userJson['role'] ?? 'seeker',
      ratingAvg:
          double.tryParse(userJson['rating_avg']?.toString() ?? '0') ?? 0.0,
      noCommission:
          userJson['no_commission'] == 1 || userJson['no_commission'] == true,
      commission:
          double.tryParse(userJson['commission']?.toString() ?? '0') ?? 0.0,
      seekerPolicy:
          userJson['seeker_policy'] == 1 || userJson['seeker_policy'] == true,
      providerPolicy:
          userJson['provider_policy'] == 1 ||
          userJson['provider_policy'] == true,
      verificationProvider:
          userJson['verification_provider'] == 1 ||
          userJson['verification_provider'] == true ||
          userJson['is_verified'] == 1 ||
          userJson['is_verified'] == true,
      providerVerifiedUntil: () {
        final dateStr = (userJson['provider_verified_until']?.toString() ?? 
                         userJson['verified_until']?.toString() ?? 
                         userJson['verification_until']?.toString() ?? '');
        if (dateStr.isEmpty || dateStr.contains('0000-00-00')) return null;
        return DateTime.tryParse(dateStr);
      }(),
      bonusPoints:
          double.tryParse(userJson['bonus_points']?.toString() ?? '0') ?? 0.0,
      paidPoints:
          double.tryParse(userJson['paid_points']?.toString() ?? '0') ?? 0.0,

      // 🎨 بيانات البروفايل المباشرة
      jobTitle: json['job-title']?.toString() ?? 
                json['job_title']?.toString() ?? 
                userJson['job-title']?.toString() ?? 
                userJson['job_title']?.toString() ?? 
                json['position']?.toString() ?? 
                '',
      bio: json['bio']?.toString() ?? 
           userJson['bio']?.toString() ?? 
           '',
      avatarUrl: (json['image_url'] ?? json['avatar'] ?? userJson['avatar']) != null
          ? (json['image_url'].toString().startsWith('http')
                ? json['image_url']
                : '${ApiEndpoints.domain}${json['image_url']}') // إتصال مع نقطة النهاية الموحدة
          : '',
      completedJobs: json['completed_jobs'] ?? 0,
      yearsExperience: json['years_experience'] ?? 0,
      worksImages: json['works'] != null
          ? (json['works'] as List).map((work) {
              if (work is String) return work;
              if (work is Map && work['image_url'] != null) {
                final url = work['image_url'].toString();
                return url.startsWith('http') ? url : '${ApiEndpoints.domain}$url'; // إتصال مع نقطة النهاية الموحدة
              }
              return '';
            }).where((url) => url.isNotEmpty).toList().cast<String>()
          : [],
      isAvailable: json['is_available'] == 1 || json['is_available'] == true,
      // 📞 بيانات التواصل من الـ JSON (ندعم المعالجة للأرقام والبنوك)
      phones: json['phones'] != null
          ? (json['phones'] as List).map((p) => PhoneModel.fromJson(Map<String, dynamic>.from(p))).toList()
          : [],
      banks: json['banks'] != null
          ? (json['banks'] as List).map((b) => BankModel.fromJson(Map<String, dynamic>.from(b))).toList()
          : [],
    );
  }
}
