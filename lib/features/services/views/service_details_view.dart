// // مسار الملف: lib/features/services/views/service_details_view.dart

// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:service_provider_app/core/network/api_client.dart';
// import '../../../core/localization/app_localizations.dart';
// import '../../../core/theme/qs_color_extension.dart';
// import '../../../core/storage/token_storage.dart';
// import '../repositories/manage_services_repository.dart';
// import '../viewmodels/service_details_viewmodel.dart';
// import '../models/service_details_model.dart';
// class ServiceDetailsView extends StatelessWidget {
//   final int serviceId;

//   const ServiceDetailsView({super.key, required this.serviceId});

//   @override
//   Widget build(BuildContext context) {
//     // تجهيز الحقن (Injection)
//     final tokenStorage = TokenStorage();
//     final apiService = ApiService(tokenStorage);
//     final repository = ManageServicesRepository(apiService);

//     return ChangeNotifierProvider(
//       create: (_) =>
//           ServiceDetailsViewModel(serviceId: serviceId, repository: repository),
//       child: const _ServiceDetailsBody(),
//     );
//   }
// }

// class _ServiceDetailsBody extends StatelessWidget {
//   const _ServiceDetailsBody();

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<ServiceDetailsViewModel>(context);

//     return Scaffold(
//       backgroundColor: context.qsColors.background,
//       appBar: AppBar(
//         backgroundColor: context.qsColors.background,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           context.tr('service_details'),
//           style: TextStyle(
//             color: context.qsColors.text,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: context.qsColors.text),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.more_vert, color: context.qsColors.text),
//             onPressed: () {}, // قائمة منسدلة إضافية إذا لزم الأمر
//           ),
//         ],
//       ),
//       body: viewModel.isLoading
//           ? Center(
//               child: CircularProgressIndicator(color: context.qsColors.primary),
//             )
//           : viewModel.errorMessage != null
//           ? Center(
//               child: Text(
//                 viewModel.errorMessage!,
//                 style: const TextStyle(color: Colors.red),
//               ),
//             )
//           : viewModel.serviceDetails == null
//           ? const Center(child: Text('الخدمة غير متوفرة'))
//           : _buildContent(context, viewModel.serviceDetails!, viewModel),
//     );
//   }

//   Widget _buildContent(
//     BuildContext context,
//     ServiceDetailsModel service,
//     ServiceDetailsViewModel viewModel,
//   ) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 1. الصورة العلوية (Hero Image)
//           _buildHeroImage(context, service),
//           const SizedBox(height: 20),

//           // 2. كارت التفاصيل الأساسية
//           _buildDetailsCard(context, service, viewModel),
//           const SizedBox(height: 30),

//           // 3. قسم الخدمات الفرعية
//           _buildSubServicesSection(context, service),
//         ],
//       ),
//     );
//   }

//   // --- دوال بناء الواجهة ---

//   Widget _buildHeroImage(BuildContext context, ServiceDetailsModel service) {
//     return Container(
//       height: 200,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         image: DecorationImage(
//           image: NetworkImage(
//             service.imageUrl.isNotEmpty
//                 ? service.imageUrl
//                 : 'https://via.placeholder.com/400',
//           ),
//           fit: BoxFit.cover,
//         ),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           gradient: LinearGradient(
//             begin: Alignment.bottomCenter,
//             end: Alignment.topCenter,
//             colors: [Colors.black.withOpacity(0.8), Colors.transparent],
//           ),
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.green,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 service.status,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               service.title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailsCard(
//     BuildContext context,
//     ServiceDetailsModel service,
//     ServiceDetailsViewModel viewModel,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
//         ],
//       ),
//       child: Column(
//         children: [
//           _buildDetailRow(
//             context,
//             Icons.category,
//             context.tr('category'),
//             service.categoryName,
//           ),
//           const Divider(height: 30),
//           _buildDetailRow(
//             context,
//             Icons.payments_outlined,
//             context.tr('base_price'),
//             service.priceText,
//           ),
//           const Divider(height: 30),
//           _buildDetailRow(
//             context,
//             Icons.description_outlined,
//             context.tr('service_description'),
//             service.description,
//             isParagraph: true,
//           ),
//           const SizedBox(height: 24),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red.shade50,
//                     foregroundColor: Colors.red,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   icon: const Icon(Icons.delete_outline, size: 18),
//                   label: Text(
//                     context.tr('delete_service'),
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   onPressed: () => viewModel.deleteService(context),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: context.qsColors.primary,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   icon: const Icon(Icons.edit, size: 18),
//                   label: Text(
//                     context.tr('edit_data'),
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   onPressed: () {},
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(
//     BuildContext context,
//     IconData icon,
//     String title,
//     String value, {
//     bool isParagraph = false,
//   }) {
//     return Row(
//       crossAxisAlignment: isParagraph
//           ? CrossAxisAlignment.start
//           : CrossAxisAlignment.center,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: context.qsColors.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: context.qsColors.primary, size: 20),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(color: context.qsColors.textSub, fontSize: 12),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 value,
//                 style: TextStyle(
//                   color: context.qsColors.text,
//                   fontSize: 14,
//                   fontWeight: isParagraph ? FontWeight.normal : FontWeight.bold,
//                   height: isParagraph ? 1.5 : 1.0,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSubServicesSection(
//     BuildContext context,
//     ServiceDetailsModel service,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               context.tr('sub_services'),
//               style: TextStyle(
//                 color: context.qsColors.text,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(
//                 color: context.qsColors.background,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 '${service.subServices.length} خدمات',
//                 style: TextStyle(color: context.qsColors.textSub, fontSize: 12),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         ...service.subServices.map((sub) => _buildSubServiceItem(context, sub)),

//         // زر إضافة خدمة فرعية متقطع
//         const SizedBox(height: 8),
//         // GestureDetector(
//         //   onTap: () {}, // فتح شاشة إضافة خدمة فرعية
//         //   child: DottedBorder(
//         //     color: context.qsColors.primary.withOpacity(0.5),
//         //     strokeWidth: 1.5,
//         //     dashPattern:  [6, 4],
//         //    borderType: BorderType.rRect,
//         //     radius:  Radius.circular(16),
//         //     child: Container(
//         //       width: double.infinity,
//         //       padding: const EdgeInsets.symmetric(vertical: 16),
//         //       child: Row(
//         //         mainAxisAlignment: MainAxisAlignment.center,
//         //         children: [
//         //           Icon(Icons.add_circle, color: context.qsColors.primary),
//         //           const SizedBox(width: 8),
//         //           Text(
//         //             context.tr('add_sub_service'),
//         //             style: TextStyle(
//         //               color: context.qsColors.primary,
//         //               fontWeight: FontWeight.bold,
//         //             ),
//         //           ),
//         //         ],
//         //       ),
//         //     ),
//         //   ),
//         // ),

//         // زر إضافة خدمة فرعية (بدون مكتبات خارجية - Native Flutter)
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: () {}, // فتح شاشة إضافة خدمة فرعية
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             decoration: BoxDecoration(
//               // لون خلفية خفيف جداً من نفس لون التطبيق
//               color: context.qsColors.primary.withOpacity(0.05),
//               border: Border.all(
//                 color: context.qsColors.primary.withOpacity(0.4), // لون الإطار
//                 width: 1.5,
//               ),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.add_circle, color: context.qsColors.primary),
//                 const SizedBox(width: 8),
//                 Text(
//                   context.tr('add_sub_service'),
//                   style: TextStyle(
//                     color: context.qsColors.primary,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSubServiceItem(BuildContext context, SubServiceDetailModel sub) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(
//               color: context.qsColors.primary,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               sub.name,
//               style: TextStyle(
//                 color: context.qsColors.text,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Text(
//             sub.priceText,
//             style: TextStyle(
//               color: context.qsColors.primary,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Icon(Icons.arrow_back_ios, size: 14, color: context.qsColors.textSub),
//         ],
//       ),
//     );
//   }
// }

// مسار الملف: lib/features/services/views/service_details_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/network/api_client.dart';
import 'package:service_provider_app/features/services/viewmodels/service_details_viewmodel.dart';
import 'package:service_provider_app/features/services/viewmodels/service_schedule_viewmodel.dart';
import 'package:service_provider_app/features/services/models/service_schedule_model.dart';
import 'package:service_provider_app/features/services/views/edit_service_view.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';

import '../../../core/storage/token_storage.dart';
import '../repositories/manage_services_repository.dart';
import '../viewmodels/service_details_viewmodel.dart';
import '../viewmodels/edit_service_viewmodel.dart';
import '../models/service_details_model.dart';
import 'edit_service_schedule_view.dart';

class ServiceDetailsView extends StatelessWidget {
  final int serviceId;

  const ServiceDetailsView({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final tokenStorage = TokenStorage();
    final apiService = ApiService(tokenStorage);
    final repository = ManageServicesRepository(apiService);

    return ChangeNotifierProvider(
      create: (_) =>
          ServiceDetailsViewModel(serviceId: serviceId, repository: repository),
      child: const _ServiceDetailsBody(),
    );
  }
}

class _ServiceDetailsBody extends StatelessWidget {
  const _ServiceDetailsBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ServiceDetailsViewModel>(context);

    return Scaffold(
      backgroundColor: context.qsColors.background,
      appBar: AppBar(
        backgroundColor: context.qsColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('service_details'),
          style: TextStyle(
            color: context.qsColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: context.qsColors.text,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: context.qsColors.text),
            onPressed: () {},
          ),
        ],
      ),
      body: viewModel.isLoading
          ? Center(
              child: CircularProgressIndicator(color: context.qsColors.primary),
            )
          : viewModel.errorMessage != null
          ? Center(
              child: Text(
                viewModel.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : viewModel.serviceDetails == null
          ? Center(child: Text(context.tr('service_not_available')))
          : _buildContent(context, viewModel.serviceDetails!, viewModel),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ServiceDetailsModel service,
    ServiceDetailsViewModel viewModel,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. الصورة العلوية (مطابقة للتصميم)
          _buildHeroImage(context, service),
          const SizedBox(height: 20),

          // 2. كارت التفاصيل الأساسية
          _buildDetailsCard(context, service, viewModel),
          const SizedBox(height: 30),

          // 3. قسم الخدمات الفرعية
          _buildSubServicesSection(context, service, viewModel),
          const SizedBox(height: 30),

          // 4. قسم الجدول الزمني (المواعيد)
          _buildScheduleSection(context, service, viewModel),
        ],
      ),
    );
  }

  // ==========================================
  // قسم 1: بناء صورة الخدمة العلوية
  // ==========================================
  Widget _buildHeroImage(BuildContext context, ServiceDetailsModel service) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(
            service.imageUrl.isNotEmpty
                ? service.imageUrl
                : 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=400&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.9), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end, // محاذاة لليمين
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade500,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                service.status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // قسم 2: بناء كارت التفاصيل والأزرار
  // ==========================================
  Widget _buildDetailsCard(
    BuildContext context,
    ServiceDetailsModel service,
    ServiceDetailsViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        // color: context.qsColors.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            context,
            Icons.widgets_outlined,
            context.tr('category'),
            service.categoryName,
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            context,
            Icons.payments_outlined,
            context.tr('base_price'),
            '${service.priceText} / ${context.tr('hour')}',
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            context,
            Icons.description_outlined,
            context.tr('service_description'),
            service.description,
            isParagraph: true,
          ),

          const SizedBox(height: 30),

          // أزرار التعديل والحذف
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade600,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: Text(
                    context.tr('delete_service'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  // 🚀 التعديل هنا: استدعاء دالة التأكيد
                  onPressed: () =>
                      _showDeleteConfirmationDialog(context, viewModel),
                ),
                // ElevatedButton.icon(
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.red.shade50,
                //     foregroundColor: Colors.red.shade600,
                //     elevation: 0,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     padding: const EdgeInsets.symmetric(vertical: 14),
                //   ),
                //   icon: const Icon(Icons.delete_outline, size: 20),
                //   label: Text(
                //     context.tr('delete_service'),
                //     style: const TextStyle(
                //       fontWeight: FontWeight.bold,
                //       fontSize: 13,
                //     ),
                //   ),
                //   onPressed: () {},
                // ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.qsColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.edit, size: 20),
                  label: Text(
                    context.tr('edit_data'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  // onPressed: () async {
                  //   // نفتح شاشة الإضافة ونمرر لها بيانات الخدمة الحالية
                  //   final shouldRefresh = await Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (_) => AddServiceView(),
                  //     ),
                  //   );

                  //   // إذا عاد المستخدم بنجاح، نقوم بتحديث شاشة التفاصيل
                  //   if (shouldRefresh == true) {
                  //     viewModel.fetchServiceDetails();
                  //   }
                  // },
                  onPressed: () async {
                    // 🚀 التعديل هنا: نفتح شاشة التعديل المنفصلة
                    final shouldRefresh = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditServiceView(service: service),
                      ),
                    );

                    // إذا عاد المستخدم بنجاح، نقوم بتحديث شاشة التفاصيل
                    if (shouldRefresh == true) {
                      viewModel.fetchServiceDetails();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String title,
    String value, {
    bool isParagraph = false,
  }) {
    return Row(
      crossAxisAlignment: isParagraph
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.qsColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: context.qsColors.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: context.qsColors.textSub, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: context.qsColors.text,
                  fontSize: 14,
                  fontWeight: isParagraph ? FontWeight.normal : FontWeight.bold,
                  height: isParagraph ? 1.6 : 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // قسم 3: الخدمات الفرعية + زر الإضافة المتقطع
  // ==========================================
  Widget _buildSubServicesSection(
    BuildContext context,
    ServiceDetailsModel service,
    ServiceDetailsViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('sub_services'),
              style: TextStyle(
                color: context.qsColors.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.qsColors.textSub.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${service.subServices.length} خدمات',
                style: TextStyle(
                  color: context.qsColors.textSub,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // رسم قائمة الخدمات الفرعية
        ...service.subServices.map(
          (sub) => _buildSubServiceItem(context, sub, viewModel),
        ),

        const SizedBox(height: 8),

        // زر "إضافة خدمة فرعية" بتصميم الحدود المتقطعة (Native)
        GestureDetector(
          onTap: () => _showAddSubServiceDialog(context, viewModel),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: context.qsColors.primary.withOpacity(0.4),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle,
                  color: context.qsColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('add_sub_service'),
                  style: TextStyle(
                    color: context.qsColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubServiceItem(
    BuildContext context,
    SubServiceDetailModel sub,
    ServiceDetailsViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.qsColors.textSub.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: context.qsColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              sub.name,
              style: TextStyle(
                color: context.qsColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            sub.priceText,
            style: TextStyle(
              color: context.qsColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          // Icon(
          //   Icons.arrow_back_ios_new,
          //   size: 14,
          //   color: context.qsColors.textSub,
          // ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () =>
                _showDeleteSubServiceDialog(context, sub.id, viewModel),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // قسم 4: نافذة إضافة خدمة فرعية (Dialog)
  // ==========================================
  void _showAddSubServiceDialog(
    BuildContext context,
    ServiceDetailsViewModel viewModel,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Theme.of(context).cardColor,
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr('add_sub_service'),
                        style: TextStyle(
                          color: context.qsColors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('add_sub_service_subtitle'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.qsColors.textSub,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // حقل اسم الخدمة
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          context.tr('sub_service_name'),
                          style: TextStyle(
                            color: context.qsColors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDialogTextField(
                        context,
                        controller: viewModel.subNameController,
                        hint: context.tr('sub_service_name_hint'),
                      ),

                      const SizedBox(height: 16),

                      // حقل السعر
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          context.tr('price_sar'),
                          style: TextStyle(
                            color: context.qsColors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDialogTextField(
                        context,
                        controller: viewModel.subPriceController,
                        hint: '0.00',
                        isNumber: true,
                        suffix: 'ر.س',
                      ),

                      const SizedBox(height: 30),

                      // الأزرار
                      ChangeNotifierProvider.value(
                        value: viewModel,
                        child: Consumer<ServiceDetailsViewModel>(
                          builder: (context, vm, _) {
                            return Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: context.qsColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: vm.isAddingSubService
                                        ? null
                                        : () async {
                                            bool success = await vm
                                                .addSubService(context);
                                            if (success &&
                                                dialogContext.mounted) {
                                              Navigator.pop(
                                                dialogContext,
                                              ); // إغلاق النافذة عند النجاح
                                            }
                                          },
                                    child: vm.isAddingSubService
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            context.tr('save'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () {
                                    vm.subNameController.clear();
                                    vm.subPriceController.clear();
                                    Navigator.pop(dialogContext); // إلغاء
                                  },
                                  child: Text(
                                    context.tr('cancel'),
                                    style: TextStyle(
                                      color: context.qsColors.textSub,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // الدائرة العلوية للآيقونة
              Positioned(
                top: -30,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      context.qsColors.background, // لون الخلفية لعزل الأيقونة
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: context.qsColors.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.add,
                      color: context.qsColors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
    String? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.qsColors.textSub.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: context.qsColors.textSub.withOpacity(0.5),
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    suffix,
                    style: TextStyle(
                      color: context.qsColors.textSub,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  // ==========================================
  // قسم 5: نافذة تأكيد الحذف (Confirmation Dialog)
  // ==========================================
  void _showDeleteConfirmationDialog(
    BuildContext context,
    ServiceDetailsViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).cardColor,
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('delete_confirm_title'),
              style: TextStyle(
                color: context.qsColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          context.tr('delete_confirm_msg'),
          style: TextStyle(color: context.qsColors.textSub, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // إغلاق النافذة بدون حذف
            child: Text(
              context.tr('cancel'),
              style: TextStyle(
                color: context.qsColors.textSub,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx); // 1. إغلاق نافذة التأكيد

              // 2. البدء بعملية الحذف
              final success = await viewModel.deleteService(context);

              // 3. إذا نجح الحذف، نغلق شاشة التفاصيل بالكامل ونعود للخلف
              if (success && context.mounted) {
                // نرسل (true) للشاشة السابقة لكي تعرف أنه تم الحذف وتقوم بتحديث القائمة
                Navigator.pop(context, true);
              }
            },
            child: Text(
              context.tr('confirm'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // قسم 6: نافذة تأكيد حذف خدمة فرعية
  // ==========================================
  void _showDeleteSubServiceDialog(
    BuildContext context,
    int subServiceId,
    ServiceDetailsViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).cardColor,
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('delete_sub_service') ?? 'حذف خدمة فرعية',
              style: TextStyle(
                color: context.qsColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          context.tr('delete_sub_service_confirm') ??
              'هل أنت متأكد أنك تريد حذف هذه الخدمة الفرعية نهائياً؟',
          style: TextStyle(color: context.qsColors.textSub, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.tr('cancel') ?? 'إلغاء',
              style: TextStyle(
                color: context.qsColors.textSub,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx); // إغلاق نافذة التأكيد
              // 🚀 تنفيذ الحذف
              await viewModel.deleteSubService(context, subServiceId);
            },
            child: Text(
              context.tr('confirm') ?? 'تأكيد الحذف',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // الانتقال لصفحة تعديل/إضافة الجدولة
  // ==========================================
  void _navigateToAddEditSchedule(
    BuildContext context,
    ServiceDetailsModel service,
    ServiceDetailsViewModel viewModel, {
    ServiceScheduleModel? scheduleToEdit,
  }) async {
    final tokenStorage = TokenStorage();
    final apiService = ApiService(tokenStorage);
    final repository = ManageServicesRepository(apiService);

    // ننتقل لصفحة التعديل وننتظر النتيجة
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ServiceScheduleViewModel(
            repository, 
            service.id, 
            initialSchedule: scheduleToEdit,
          ),
          child: const EditServiceScheduleView(),
        ),
      ),
    );

    // عند العودة، نقوم بتحديث البيانات لضمان ظهور التغييرات
    viewModel.fetchServiceDetails();
  }

  Widget _buildScheduleSection(
    BuildContext context,
    ServiceDetailsModel service,
    ServiceDetailsViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: context.qsColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              context.tr('service_schedule'),
              style: TextStyle(
                color: context.qsColors.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _navigateToAddEditSchedule(context, service, viewModel),
              icon: Icon(Icons.add, size: 18, color: context.qsColors.primary),
              label: Text(
                'إضافة فترة',
                style: TextStyle(
                  color: context.qsColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: context.qsColors.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (service.schedules.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'لا يوجد فترات عمل لهذه الخدمة',
                style: TextStyle(color: context.qsColors.textSub),
              ),
            ),
          )
        else
          ...service.schedules.map((schedule) {
            String sTime = schedule.startTime;
            String eTime = schedule.endTime;
            if (sTime.length > 5) sTime = sTime.substring(0, 5);
            if (eTime.length > 5) eTime = eTime.substring(0, 5);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: schedule.isActive
                      ? context.qsColors.primary.withOpacity(0.3)
                      : context.qsColors.textSub.withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        schedule.isActive ? Icons.event_available : Icons.event_busy,
                        color: schedule.isActive ? context.qsColors.primary : context.qsColors.textSub,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          schedule.label ?? (schedule.isActive ? 'متاح' : 'غير متاح'),
                          style: TextStyle(
                            color: schedule.isActive ? context.qsColors.text : context.qsColors.textSub,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: context.qsColors.primary, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _navigateToAddEditSchedule(context, service, viewModel, scheduleToEdit: schedule),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          if (schedule.id != null) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(context.tr('confirm_delete') ?? 'تأكيد الحذف'),
                                content: const Text('هل متأكد أنك تريد حذف فترة العمل هذه؟'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(context.tr('cancel') ?? 'إلغاء'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      await viewModel.deleteServiceSchedule(context, schedule.id!);
                                    },
                                    child: Text(context.tr('confirm') ?? 'حذف', style: const TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: context.qsColors.textSub, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '$sTime - $eTime',
                        style: TextStyle(
                          color: context.qsColors.textSub,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (schedule.days.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: schedule.days.map((day) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.qsColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.tr(day.toLowerCase()),
                            style: TextStyle(
                              color: context.qsColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }
}
