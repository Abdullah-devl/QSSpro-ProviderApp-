
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// import 'package:service_provider_app/features/home/views/widgets/activeServicCared.dart';
import 'package:service_provider_app/features/home/views/widgets/hederSection.dart';
import 'package:service_provider_app/features/home/views/widgets/newRequestCard.dart';
// import 'package:service_provider_app/features/home/views/widgets/statCard.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../viewmodels/main_viewmodel.dart';
import '../models/home_model.dart';
import '../../notifications/viewmodels/notification_viewmodel.dart';
import 'package:service_provider_app/features/profile/viewmodels/profile_viewmodel.dart';

import 'package:service_provider_app/features/home/views/widgets/ad_carousel.dart';
import '../models/advertisement_model.dart';
import 'package:shimmer/shimmer.dart';
import '../../commissions/views/unpaid_commissions_view.dart';

class HomeDashboardView extends StatefulWidget {
  const HomeDashboardView({super.key});

  @override
  State<HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends State<HomeDashboardView> {
  static bool _hasShownPopupInSession = false;

  void _checkAndShowPopup(HomeViewModel vm) {
    if (!_hasShownPopupInSession && vm.popupAd != null) {
      _hasShownPopupInSession = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAdPopup(context, vm.popupAd!, vm);
      });
    }
  }

  void _showAdPopup(BuildContext context, AdvertisementModel ad, HomeViewModel vm) {
    vm.trackAdView(ad.id);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    vm.handleAdClick(context, ad);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(ad.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final mainViewModel = Provider.of<MainViewModel>(context);
    final colors = context.qsColors;

    // تفعيل البوب أب إذا كان متاحاً
    _checkAndShowPopup(homeViewModel);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: _buildHeader(context, profileViewModel, mainViewModel),
      ),
      body: RefreshIndicator(
        color: colors.primary,
        backgroundColor: colors.card,
        onRefresh: () async {
          await homeViewModel.fetchHomeData();
          await profileViewModel.fetchProfile();
          await homeViewModel.fetchAds();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 2. حالة التحميل والخطأ
              // ==========================================
              if (homeViewModel.isLoading)
                _buildLoadingState(context)
              else if (homeViewModel.errorMessage != null)
                _buildErrorState(context, homeViewModel)
              else if (homeViewModel.homeData != null) ...[
                
                // ==========================================
                // 🆕 عرض التوكن (FCM Token Card)
                // ==========================================
                if (homeViewModel.fcmToken != null)
                  _buildFCMTokenCard(context, homeViewModel.fcmToken!),
                
                const SizedBox(height: 15),

                // ==========================================
                // 3. حالة التوثيق (Verification Banner)
                // ==========================================
                _buildVerificationBanner(context, homeViewModel.homeData!.verification),

                const SizedBox(height: 25),

                // ==========================================
                // 4. الإحصائيات العامة (3 كروت صغيرة)
                // ==========================================
                _buildGeneralStats(context, homeViewModel.homeData!),

                const SizedBox(height: 20),

                // ==========================================
                // 5. إعلانات الكاروسيل (Carousel Ads)
                // ==========================================
                AdCarousel(ads: homeViewModel.carouselAds),

                const SizedBox(height: 10),

                // ==========================================
                // 6. قسم العمولات (Commissions)
                // ==========================================
                _buildCommissionsCard(context, homeViewModel.homeData!.commissions),

                const SizedBox(height: 25),

                // ==========================================
                // 7. قسم الدخل (Income)
                // ==========================================
                SectionHeader(title: context.tr('income')),
                const SizedBox(height: 12),
                _buildIncomeSection(context, homeViewModel.homeData!.income),

                const SizedBox(height: 25),

                // ==========================================
                // 9. أداء الخدمات (Services Performance)
                // ==========================================
                SectionHeader(
                  title: context.tr('services_performance'),
                  actionText: context.tr('view_all'),
                  onActionTap: () {
                    // Navigate to services details
                  },
                ),
                const SizedBox(height: 12),
                _buildServicesPerformance(context, homeViewModel.homeData!.servicesPerformance),

                const SizedBox(height: 25),

                // ==========================================
                // 8. الطلبات الجديدة (New Requests)
                // ==========================================
                SectionHeader(
                  title: context.tr('new_requests'),
                  badgeCount: homeViewModel.homeData!.newRequests.length,
                  actionText: context.tr('view_all'),
                  onActionTap: () {},
                ),
                const SizedBox(height: 16),

                if (homeViewModel.homeData!.newRequests.isEmpty)
                  _buildEmptyState(context, context.tr('no_new_requests'))
                else
                  ...homeViewModel.homeData!.newRequests.map((request) => NewRequestCard(
                        title: request.customerName,
                        location: request.mainService,
                        distance: request.createdAt, 
                        price: "${request.totalPrice} ${context.tr('sar')}",
                        imageUrl: 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                      )),

                const SizedBox(height: 100), // مساحة إضافية للناف بار العائم
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileViewModel profileVM, MainViewModel mainVM) {
    final colors = context.qsColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: colors.primary.withOpacity(0.1),
                backgroundImage: profileVM.profile?.avatarUrl != null && profileVM.profile!.avatarUrl.isNotEmpty
                    ? NetworkImage(profileVM.profile!.avatarUrl)
                    : const NetworkImage('https://cdn-icons-png.flaticon.com/512/149/149071.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('welcome_back'),
                      style: TextStyle(color: colors.textSub, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      profileVM.profile?.name ?? context.tr('auto_tr_6'), 
                      style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildNotificationIcon(context),
      ],
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    final colors = context.qsColors;
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/notifications'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.card,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: colors.text.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Consumer<NotificationViewModel>(
          builder: (context, notificationVM, child) {
            final unreadCount = notificationVM.unreadCount;
            return Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(Icons.notifications_none_rounded, color: colors.text, size: 28),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.card, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text(
                      unreadCount > 9 ? '+9' : unreadCount.toString(),
                      style: TextStyle(color: colors.card, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colors = context.qsColors;
    return Shimmer.fromColors(
      baseColor: colors.text.withValues(alpha: 0.08),
      highlightColor: colors.text.withValues(alpha: 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Verification Banner Skeleton
          Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 25),

          // 2. 3 Stat Cards Skeleton
          Row(
            children: List.generate(3, (index) => Expanded(
              child: Container(
                height: 100,
                margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )),
          ),
          const SizedBox(height: 25),

          // 3. Carousel Banner Skeleton
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 25),

          // 4. Section Title Skeleton
          Container(
            height: 20,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 12),

          // 5. Income Cards Skeleton
          Row(
            children: List.generate(3, (index) => Expanded(
              child: Container(
                height: 80,
                margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, HomeViewModel vm) {
    final colors = context.qsColors;
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 80),
          Icon(Icons.error_outline, color: colors.error, size: 60),
          const SizedBox(height: 16),
          Text(vm.errorMessage!, style: TextStyle(color: colors.error, fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => vm.fetchHomeData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(context.tr('retry')),
          )
        ],
      ),
    );
  }

  Widget _buildGeneralStats(BuildContext context, HomeDataModel data) {
    return Row(
      children: [
        _buildSmallStatCard(context, context.tr('total_services'), data.totalServices.toString(), Icons.miscellaneous_services_rounded, context.qsColors.primary),
        const SizedBox(width: 12),
        _buildSmallStatCard(context, context.tr('total_requests'), data.totalRequests.toString(), Icons.assignment_rounded, context.qsColors.warning),
        const SizedBox(width: 12),
        _buildSmallStatCard(context, context.tr('active_requests'), data.activeRequestsCount.toString(), Icons.play_circle_fill_rounded, context.qsColors.success),
      ],
    );
  }

  Widget _buildSmallStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final colors = context.qsColors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: colors.text.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: colors.textSub, fontSize: 10), textAlign: TextAlign.center, maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBanner(BuildContext context, VerificationModel verification) {
    final colors = context.qsColors;
    final bool isVerified = verification.status == 'verified';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isVerified 
            ? [colors.success.withValues(alpha: 0.8), colors.success] 
            : [colors.error.withValues(alpha: 0.8), colors.error],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isVerified ? colors.success : colors.error).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(
              isVerified ? Icons.verified_user_rounded : Icons.info_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVerified ? context.tr('verified') : context.tr('not_verified'),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  isVerified 
                    ? "${context.tr('days_left_label')}: ${verification.daysLeft} ${context.tr('days_label')}"
                    : context.tr('verify_account_banner_subtitle'),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                ),
              ],
            ),
          ),
          if (!isVerified)
            ElevatedButton(
              onPressed: () {
                // Navigate to verification page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: colors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 0,
              ),
              child: Text(context.tr('verify_now'), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildIncomeSection(BuildContext context, IncomeModel income) {
    return Row(
      children: [
        _buildIncomeCard(context, context.tr('weekly_earnings'), income.weekly, context.qsColors.primary),
        const SizedBox(width: 12),
        _buildIncomeCard(context, context.tr('monthly_earnings'), income.monthly, context.qsColors.success),
        const SizedBox(width: 12),
        _buildIncomeCard(context, context.tr('yearly_earnings'), income.yearly, context.qsColors.secondary ),
      ],
    );
  }

  Widget _buildIncomeCard(BuildContext context, String title, double value, Color color) {
    final colors = context.qsColors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: colors.textSub, fontSize: 11)),
            const SizedBox(height: 8),
            Text(
              value.toStringAsFixed(0),
              style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(context.tr('sar'), style: TextStyle(color: colors.textSub, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionsCard(BuildContext context, CommissionsModel commissions) {
    final colors = context.qsColors;
    final bool isZero = commissions.totalOwed <= 0 && commissions.unpaidRequestsCount <= 0;
    final Color statusColor = isZero ? colors.success : colors.error;

    return Container(
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UnpaidCommissionsView()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('total_owed'), style: TextStyle(color: statusColor, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            "${commissions.totalOwed.toStringAsFixed(2)} ${context.tr('sar')}",
                            style: TextStyle(color: colors.text, fontSize: 24, fontWeight: FontWeight.w900),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "${commissions.unpaidRequestsCount} ${context.tr('unpaid_requests_count')}",
                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (!isZero) ...[
                  const SizedBox(height: 15),
                  Divider(color: statusColor.withOpacity(0.1)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.tr('pay_now'), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios_rounded, color: statusColor, size: 14),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesPerformance(BuildContext context, ServicesPerformanceModel performance) {
    final colors = context.qsColors;
    if (performance.mostRequested.isEmpty) {
      return _buildEmptyState(context, context.tr('no_services_currently'));
    }
    
    return Column(
      children: performance.mostRequested.take(3).map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: colors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text("${performance.mostRequested.indexOf(item) + 1}", style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: TextStyle(color: colors.text, fontWeight: FontWeight.bold)),
                    Text("${item.requestsCount} ${context.tr('total_requests')}", style: TextStyle(color: colors.textSub, fontSize: 12)),
                  ],
                ),
              ),
              if (item.price != null)
                Text("${item.price} ${context.tr('sar')}", style: TextStyle(color: colors.success, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(message, style: TextStyle(color: context.qsColors.textSub)),
      ),
    );
  }

  // 🔔 مكوّن عرض توكن فايربيز
  Widget _buildFCMTokenCard(BuildContext context, String token) {
    final colors = context.qsColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active_rounded, color: colors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                "Firebase FCM Token",
                style: TextStyle(color: colors.primary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.copy_rounded, color: colors.primary, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: token));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم نسخ التوكن بنجاح")),
                  );
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            token,
            style: TextStyle(color: colors.textSub, fontSize: 11, fontFamily: 'monospace'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
