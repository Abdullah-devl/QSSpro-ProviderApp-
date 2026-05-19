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
  final double? latitude;
  final double? longitude;

  // 🎨 حقول جدول profiles
  final String jobTitle;
  final String bio;
  final String avatarUrl;
  final int completedJobs;
  final int yearsExperience;
  final List<String> worksImages;
  final bool isAvailable;
  final int servicesCount;
  final int requestsCount;

  final bool? isSuspendedForCommissions;
  final String? suspendedMessage;

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
    this.latitude,
    this.longitude,
    this.jobTitle = '',
    this.bio = '',
    this.avatarUrl = '',
    this.completedJobs = 0,
    this.yearsExperience = 0,
    this.worksImages = const [],
    this.isAvailable = true,
    this.servicesCount = 0,
    this.requestsCount = 0,
    this.isSuspendedForCommissions = false,
    this.suspendedMessage,
    this.phones = const [],
    this.banks = const [],
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // كائنات البحث المحتملة
    final userJson = json['user'] is Map ? json['user'] : (json['provider'] is Map ? json['provider'] : json);
    final statsJson = json['provider_stats'] is Map ? json['provider_stats'] : (json['stats'] is Map ? json['stats'] : json);
    final profileJson = json['profile'] is Map ? json['profile'] : (json['data'] is Map ? json['data'] : json);

    // دالة مساعدة للبحث عن قيمة في عدة كائنات
    dynamic findKey(List<String> keys, [List<dynamic>? maps]) {
      final searchMaps = maps ?? [json, profileJson, userJson, statsJson];
      for (final map in searchMaps) {
        if (map is Map) {
          for (final key in keys) {
            if (map.containsKey(key) && map[key] != null) {
              return map[key];
            }
          }
        }
      }
      return null;
    }

    // استخراج ID
    final idVal = findKey(['id', 'user_id']);
    final id = int.tryParse(idVal?.toString() ?? '0') ?? 0;

    // استخراج الاسم
    final name = findKey(['name', 'username'])?.toString() ?? 'مستخدم غير معروف';

    // استخراج الإيميل
    final email = findKey(['email'])?.toString() ?? '';

    // الدور
    final role = findKey(['role'])?.toString() ?? 'seeker';

    // التقييم
    final ratingVal = findKey(['rating_avg', 'rating', 'avg_rating']);
    final ratingAvg = double.tryParse(ratingVal?.toString() ?? '0') ?? 0.0;

    // العمولة
    final noCommVal = findKey(['no_commission']);
    final noCommission = noCommVal == 1 || noCommVal == true || noCommVal == '1' || noCommVal == 'true';

    final commVal = findKey(['commission']);
    final commission = double.tryParse(commVal?.toString() ?? '0') ?? 0.0;

    // السياسات
    final seekerPolVal = findKey(['seeker_policy']);
    final seekerPolicy = seekerPolVal == 1 || seekerPolVal == true || seekerPolVal == '1' || seekerPolVal == 'true';

    final provPolVal = findKey(['provider_policy']);
    final providerPolicy = provPolVal == 1 || provPolVal == true || provPolVal == '1' || provPolVal == 'true';

    // التوثيق
    final verProvVal = findKey(['verification_provider', 'is_verified']);
    final verificationProvider = verProvVal == 1 || verProvVal == true || verProvVal == '1' || verProvVal == 'true';

    final dateStr = findKey(['provider_verified_until', 'verified_until', 'verification_until'])?.toString() ?? '';
    DateTime? providerVerifiedUntil;
    if (dateStr.isNotEmpty && !dateStr.contains('0000-00-00')) {
      providerVerifiedUntil = DateTime.tryParse(dateStr);
    }

    // النقاط
    final bonusVal = findKey(['bonus_points']);
    final bonusPoints = double.tryParse(bonusVal?.toString() ?? '0') ?? 0.0;

    final paidVal = findKey(['paid_points']);
    final paidPoints = double.tryParse(paidVal?.toString() ?? '0') ?? 0.0;

    final latVal = findKey(['latitude', 'lat']);
    final latitude = double.tryParse(latVal?.toString() ?? '');

    final lngVal = findKey(['longitude', 'lng', 'long']);
    final longitude = double.tryParse(lngVal?.toString() ?? '');

    // المسمى الوظيفي
    final jobTitle = findKey(['job-title', 'job_title', 'position'])?.toString() ?? '';

    // النبذة
    final bio = findKey(['bio', 'description'])?.toString() ?? '';

    // الصورة
    final avatarRaw = findKey(['image_url', 'avatar', 'image', 'profile_image']);
    String avatarUrl = '';
    if (avatarRaw != null && avatarRaw.toString().isNotEmpty) {
      final str = avatarRaw.toString();
      if (str.startsWith('http')) {
        avatarUrl = str;
      } else {
        avatarUrl = '${ApiEndpoints.domain}$str?v=${DateTime.now().millisecondsSinceEpoch}';
      }
    }

    // الإحصائيات (الأعمال المكتملة، عدد الخدمات، عدد الطلبات)
    final compVal = findKey(['completed_requests_count', 'completed_jobs', 'completed_count'], [statsJson, json, profileJson, userJson]);
    final completedJobs = int.tryParse(compVal?.toString() ?? '0') ?? 0;

    final expVal = findKey(['years_experience', 'experience']);
    final yearsExperience = int.tryParse(expVal?.toString() ?? '0') ?? 0;

    final servCountVal = findKey(['services_count'], [statsJson, json, profileJson, userJson]);
    int servicesCount = int.tryParse(servCountVal?.toString() ?? '0') ?? 0;
    if (servicesCount == 0 && findKey(['services']) is List) {
      servicesCount = (findKey(['services']) as List).length;
    }

    final reqCountVal = findKey(['requests_count', 'orders_count'], [statsJson, json, profileJson, userJson]);
    final requestsCount = int.tryParse(reqCountVal?.toString() ?? '0') ?? 0;

    // صور الأعمال
    final worksList = findKey(['works', 'previous_works']);
    List<String> worksImages = [];
    if (worksList is List) {
      worksImages = worksList.map((work) {
        if (work is String) return work;
        if (work is Map && work['image_url'] != null) {
          final url = work['image_url'].toString();
          return url.startsWith('http') ? url : '${ApiEndpoints.domain}$url';
        }
        return '';
      }).where((url) => url.isNotEmpty).toList().cast<String>();
    }

    // التوفر
    final availVal = findKey(['is_available', 'status']);
    final isAvailable = availVal == null || availVal == 1 || availVal == true || availVal == '1' || availVal == 'true' || availVal == 'available';

    // الهواتف والبنوك
    final phonesList = findKey(['phones', 'profile_phones']);
    List<PhoneModel> phones = [];
    if (phonesList is List) {
      phones = phonesList.map((p) {
        if (p is Map) return PhoneModel.fromJson(Map<String, dynamic>.from(p));
        return null;
      }).whereType<PhoneModel>().toList();
    }

    final banksList = findKey(['banks', 'user_banks', 'userBanks']);
    List<BankModel> banks = [];
    if (banksList is List) {
      banks = banksList.map((b) {
        if (b is Map) return BankModel.fromJson(Map<String, dynamic>.from(b));
        return null;
      }).whereType<BankModel>().toList();
    }

    // الإيقاف بسبب العمولات المتأخرة
    final isSuspVal = findKey(['is_suspended_for_commissions']);
    final isSuspendedForCommissions = isSuspVal == 1 || isSuspVal == true || isSuspVal == '1' || isSuspVal == 'true';

    final suspendedMessage = findKey(['suspended_message'])?.toString();

    return ProfileModel(
      id: id,
      name: name,
      email: email,
      role: role,
      ratingAvg: ratingAvg,
      noCommission: noCommission,
      commission: commission,
      seekerPolicy: seekerPolicy,
      providerPolicy: providerPolicy,
      verificationProvider: verificationProvider,
      providerVerifiedUntil: providerVerifiedUntil,
      bonusPoints: bonusPoints,
      paidPoints: paidPoints,
      latitude: latitude,
      longitude: longitude,
      jobTitle: jobTitle,
      bio: bio,
      avatarUrl: avatarUrl,
      completedJobs: completedJobs,
      yearsExperience: yearsExperience,
      worksImages: worksImages,
      isAvailable: isAvailable,
      servicesCount: servicesCount,
      requestsCount: requestsCount,
      phones: phones,
      banks: banks,
      isSuspendedForCommissions: isSuspendedForCommissions,
      suspendedMessage: suspendedMessage,
    );
  }
}
