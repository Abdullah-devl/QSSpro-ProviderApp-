import 'dart:convert';
import 'dart:io';

void main() async {
  final arFile = File('assets/lang/ar.json');
  final enFile = File('assets/lang/en.json');

  final arMap = json.decode(await arFile.readAsString()) as Map<String, dynamic>;
  final enMap = json.decode(await enFile.readAsString()) as Map<String, dynamic>;

  final allKeys = {...arMap.keys, ...enMap.keys}.toList()..sort();

  final newArMap = <String, dynamic>{};
  final newEnMap = <String, dynamic>{};

  for (var key in allKeys) {
    newArMap[key] = arMap[key] ?? enMap[key];
    newEnMap[key] = enMap[key] ?? arMap[key]; // Fallback to other lang if missing
  }

  // Pre-define some critical missing keys
  final ordersMissing = {
    'error_loading_orders': {'ar': 'فشل جلب الطلبات، يرجى المحاولة لاحقاً', 'en': 'Failed to load orders, please try again later'},
    'retry': {'ar': 'إعادة المحاولة', 'en': 'Retry'},
    'no_orders_yet': {'ar': 'لا توجد طلبات حالياً', 'en': 'No orders available yet'},
    'paid_currently': {'ar': 'المدفوع حالياً', 'en': 'Paid Currently'},
    'required_percentage_to_start': {'ar': 'النسبة المطلوبة للبدء: {percentage}%', 'en': 'Required percentage to start: {percentage}%'},
    'amount_updated_successfully': {'ar': 'تم تحديث المبلغ بنجاح', 'en': 'Amount updated successfully'},
    'pending_status': {'ar': 'في الانتظار', 'en': 'Pending'},
    'accepted_status': {'ar': 'تم القبول', 'en': 'Accepted'},
    'working_status': {'ar': 'جاري العمل', 'en': 'Working'},
    'completed_status': {'ar': 'مكتمل', 'en': 'Completed'},
    'status_accepted_full_paid': {'ar': 'مدفوع بالكامل', 'en': 'Full Paid'},
    'reviews_soon': {'ar': 'التقييمات قريباً', 'en': 'Reviews coming soon'},
    'complaints': {'ar': 'الشكاوي', 'en': 'Complaints'},
    'default_bio': {'ar': 'وصف فني محترف...', 'en': 'Professional technician description...'},
    'contact_info': {'ar': 'أرقام وحسابات', 'en': 'Contact Info'},
    'share': {'ar': 'مشاركة', 'en': 'Share'},
    'link_copied_soon': {'ar': 'تم نسخ رابط العمل (قريباً)', 'en': 'Work link copied (Coming soon)'},
    'delete_confirm_msg_specific': {'ar': 'هل أنت متأكد أنك تريد حذف "{title}"؟ لا يمكن التراجع عن هذا الإجراء.', 'en': 'Are you sure you want to delete "{title}"? This action cannot be undone.'},
    'delete_success': {'ar': 'تم الحذف بنجاح', 'en': 'Deleted successfully'},
    'logout_confirm': {'ar': 'هل أنت متأكد أنك تريد تسجيل الخروج؟', 'en': 'Are you sure you want to logout?'},
    'exit': {'ar': 'خروج', 'en': 'Exit'},
    'no_new_requests': {'ar': 'لا توجد طلبات جديدة حالياً.', 'en': 'No new requests currently.'},
    'logout_failed': {'ar': 'فشل تسجيل الخروج، حاول مرة أخرى', 'en': 'Logout failed, please try again'},
    'manage_my_services': {'ar': 'إدارة خدماتي', 'en': 'Manage My Services'},
    'search_service_hint': {'ar': 'بحث عن خدمة...', 'en': 'Search for a service...'},
    'add_service': {'ar': 'إضافة خدمة', 'en': 'Add Service'},
    'special_services_and_attendance': {'ar': 'الخدمات المخصصة والحضور', 'en': 'Special Services & Attendance'},
    'no_services_available': {'ar': 'لا توجد خدمات حالياً.', 'en': 'No services available currently.'},
    'filter_all': {'ar': 'الكل', 'en': 'All'},
    'filter_active': {'ar': 'نشط', 'en': 'Active'},
    'filter_inactive': {'ar': 'غير نشط', 'en': 'Inactive'},
    'service_not_available': {'ar': 'الخدمة غير متوفرة', 'en': 'Service not available'},
    'accepted_initial': {'ar': 'تم القبول', 'en': 'Accepted'},
    'in_progress': {'ar': 'جاري العمل', 'en': 'In Progress'},
    'status_accepted_initial': {'ar': 'تم القبول', 'en': 'Accepted'},
    'status_in_progress': {'ar': 'جاري العمل', 'en': 'In Progress'},
    'status_pending': {'ar': 'في الانتظار', 'en': 'Pending'},
    'status_completed': {'ar': 'مكتمل', 'en': 'Completed'},
    'status_canceled': {'ar': 'ملغي', 'en': 'Canceled'},
  };

  ordersMissing.forEach((key, val) {
    newArMap[key] = val['ar'];
    newEnMap[key] = val['en'];
  });

  const encoder = JsonEncoder.withIndent('  ');
  await arFile.writeAsString(encoder.convert(newArMap));
  await enFile.writeAsString(encoder.convert(newEnMap));

  print('Successfully synchronized and added missing keys.');
}
