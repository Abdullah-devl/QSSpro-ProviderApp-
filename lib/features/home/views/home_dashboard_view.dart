
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:service_provider_app/features/home/views/widgets/activeServicCared.dart';
// import 'package:service_provider_app/features/home/views/widgets/hederSection.dart';
// import 'package:service_provider_app/features/home/views/widgets/newRequestCard.dart';
// import 'package:service_provider_app/features/home/views/widgets/statCard.dart';
// import '../../../core/localization/app_localizations.dart';
// import '../../../core/theme/qs_color_extension.dart';
// import '../viewmodels/main_viewmodel.dart';

// class HomeDashboardView extends StatelessWidget {
//   const HomeDashboardView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<MainViewModel>(context);

//     return SafeArea(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ==========================================
//             // 1. رأس الشاشة (Header)
//             // ==========================================
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Stack(
//                       alignment: Alignment.bottomRight,
//                       children: [
//                         const CircleAvatar(
//                           radius: 25,
//                           backgroundImage: NetworkImage(
//                             'https://i.pravatar.cc/150?img=11',
//                           ),
//                         ),
//                         Container(
//                           width: 14,
//                           height: 14,
//                           decoration: BoxDecoration(
//                             color: Colors.green,
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: Theme.of(context).scaffoldBackgroundColor,
//                               width: 2,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(width: 12),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           context.tr('welcome_back'),
//                           style: TextStyle(
//                             color: context.qsColors.textSub,
//                             fontSize: 12,
//                           ),
//                         ),
//                         Text(
//                           'أحمد محمد',
//                           style: TextStyle(
//                             color: context.qsColors.text,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Transform.scale(
//                       scale: 0.8,
//                       child: CupertinoSwitch(
//                         activeColor: context.qsColors.primary,
//                         value: viewModel.isOnline,
//                         onChanged: viewModel.toggleOnlineStatus,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).cardColor,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Stack(
//                         alignment: Alignment.topRight,
//                         children: [
//                           Icon(
//                             Icons.notifications_none_rounded,
//                             color: context.qsColors.text,
//                           ),
//                           Container(
//                             width: 8,
//                             height: 8,
//                             decoration: const BoxDecoration(
//                               color: Colors.red,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             const SizedBox(height: 30),

//             // ==========================================
//             // 2. الإحصائيات (الأرباح والتقييم)
//             // ==========================================
//             Row(
//               children: [
//                 StatCard(
//                   title: context.tr('general_rating'),
//                   value: '4.8',
//                   subtitle: '/ 5.0',
//                   icon: Icons.star_rounded,
//                   isPrimary: false,
//                 ),
//                 const SizedBox(width: 16),
//                 StatCard(
//                   title: context.tr('weekly_earnings'),
//                   value: '1,250',
//                   subtitle: context.tr('sar'),
//                   icon: Icons.account_balance_wallet_rounded,
//                   isPrimary: true,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 30),

//             // ==========================================
//             // 3. الطلبات الجديدة
//             // ==========================================
//             SectionHeader(
//               title: context.tr('new_requests'),
//               badgeCount: 2,
//               actionText: context.tr('view_all'),
//               onActionTap: () {},
//             ),
//             const SizedBox(height: 16),

//             // كروت الطلبات (مؤقتاً بيانات ثابتة مطابقة لتصميمك)
//             const NewRequestCard(
//               title: 'خدمة تنظيف - شقة سكنية',
//               location: 'حي الملز، الرياض',
//               distance: '5 كم',
//               price: '150 ر.س',
//               imageUrl:
//                   'https://images.unsplash.com/photo-1581578731548-c64695cc6952?q=80&w=200&auto=format&fit=crop', // صورة تنظيف
//             ),
//             const NewRequestCard(
//               title: 'صيانة تكييف سبليت',
//               location: 'حي العليا، الرياض',
//               distance: '2.5 كم',
//               price: '200 ر.س',
//               imageUrl:
//                   'https://images.unsplash.com/photo-1527689638836-411945a2b57c?q=80&w=200&auto=format&fit=crop', // صورة تكييف
//             ),

//             const SizedBox(height: 20),

//             // ==========================================
//             // 4. الخدمات النشطة
//             // ==========================================
//             SectionHeader(title: context.tr('active_services')),
//             const SizedBox(height: 16),
//             const ActiveServiceCard(),

//             const SizedBox(height: 40), // مسافة فارغة أسفل الشاشة
//           ],
//         ),
//       ),
//     );
//   }
// }

// مسار الملف: lib/features/home/views/home_dashboard_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:service_provider_app/features/home/views/widgets/activeServicCared.dart';
import 'package:service_provider_app/features/home/views/widgets/hederSection.dart';
import 'package:service_provider_app/features/home/views/widgets/newRequestCard.dart';
import 'package:service_provider_app/features/home/views/widgets/statCard.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../viewmodels/main_viewmodel.dart';

class HomeDashboardView extends StatelessWidget {
  const HomeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // استدعاء الـ ViewModels مباشرة (لأنها متوفرة الآن في main.dart)
    final mainViewModel = Provider.of<MainViewModel>(context);
    final homeViewModel = Provider.of<HomeViewModel>(context);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => await homeViewModel.fetchHomeData(),
        color: context.qsColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. رأس الشاشة (Header)
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                          ),
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('welcome_back'),
                            style: TextStyle(color: context.qsColors.textSub, fontSize: 12),
                          ),
                          Text(
                            homeViewModel.userName, 
                            style: TextStyle(color: context.qsColors.text, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          activeColor: context.qsColors.primary,
                          value: mainViewModel.isOnline,
                          onChanged: mainViewModel.toggleOnlineStatus,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Icon(Icons.notifications_none_rounded, color: context.qsColors.text),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // ==========================================
              // 2. التحكم في حالة جلب البيانات (Loading / Error / Success)
              // ==========================================
              if (homeViewModel.isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: CircularProgressIndicator(color: context.qsColors.primary),
                  ),
                )
              else if (homeViewModel.errorMessage != null)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Icon(Icons.error_outline, color: Colors.red.shade400, size: 50),
                      const SizedBox(height: 16),
                      Text(homeViewModel.errorMessage!, style: const TextStyle(color: Colors.red)),
                      TextButton(
                        onPressed: () => homeViewModel.fetchHomeData(),
                        child: Text(context.tr('retry'), style: TextStyle(color: context.qsColors.primary, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                )
              else if (homeViewModel.homeData != null) ...[
                // ==========================================
                // البيانات الحقيقية تم جلبها بنجاح!
                // ==========================================
                Row(
                  children: [
                    StatCard(
                      title: context.tr('general_rating'),
                      value: homeViewModel.homeData!.rating.toString(),
                      subtitle: '/ 5.0',
                      icon: Icons.star_rounded,
                      isPrimary: false,
                    ),
                    const SizedBox(width: 16),
                    StatCard(
                      title: context.tr('weekly_earnings'),
                      value: homeViewModel.homeData!.weeklyEarnings.toString(),
                      subtitle: context.tr('sar'),
                      icon: Icons.account_balance_wallet_rounded,
                      isPrimary: true,
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                SectionHeader( // استبدل بـ hederSection إذا كان هذا هو اسمه لديك
                  title: context.tr('new_requests'),
                  badgeCount: homeViewModel.homeData!.newRequests.length,
                  actionText: context.tr('view_all'),
                  onActionTap: () {},
                ),
                const SizedBox(height: 16),

                if (homeViewModel.homeData!.newRequests.isEmpty)
                  Center(child: Text(context.tr('no_new_requests'), style: TextStyle(color: context.qsColors.textSub)))
                else
                  ...homeViewModel.homeData!.newRequests.map((request) => NewRequestCard(
                        title: request.title,
                        location: request.location,
                        distance: request.distance,
                        price: request.price,
                        imageUrl: request.imageUrl.isNotEmpty 
                            ? request.imageUrl 
                            : 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?q=80&w=200&auto=format&fit=crop',
                      )),

                const SizedBox(height: 20),

                SectionHeader(title: context.tr('active_services')), // استبدل بـ hederSection
                const SizedBox(height: 16),
                
                const ActiveServiceCard(),

                const SizedBox(height: 40),
              ]
            ],
          ),
        ),
      ),
    );
  }
}