// مسار الملف: lib/features/profile/views/profile_view.dart

import 'package:flutter/material.dart';
import 'package:service_provider_app/core/network/api_client.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/features/profile/repositories/profile_repository.dart';
import 'package:service_provider_app/features/profile/viewmodels/edit_profile_viewmodel.dart';
import 'package:service_provider_app/features/profile/views/edit_profile_view.dart';
import 'package:service_provider_app/features/profile/viewmodels/add_work_viewmodel.dart';
import 'package:service_provider_app/features/profile/views/add_work_view.dart';
import 'package:service_provider_app/features/profile/viewmodels/previous_works_viewmodel.dart';
import 'package:service_provider_app/features/profile/views/previous_works_view.dart';
import 'package:service_provider_app/features/profile/viewmodels/edit_work_viewmodel.dart';
import 'package:service_provider_app/features/profile/views/edit_work_view.dart';
import 'package:service_provider_app/features/profile/models/work_model.dart';
import 'package:service_provider_app/features/profile/viewmodels/services_viewmodel.dart';
import 'package:service_provider_app/features/profile/views/services_view.dart';
import 'package:service_provider_app/features/profile/views/contact_info_view.dart';
import 'package:service_provider_app/features/profile/viewmodels/contact_info_viewmodel.dart';
import 'package:service_provider_app/features/profile/views/provider_reviews_view.dart';
import 'package:service_provider_app/features/profile/viewmodels/provider_reviews_viewmodel.dart';
import 'package:service_provider_app/features/profile/repositories/review_repository.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/utils/dialog_helper.dart';

import '../../complaints/views/complaints_hub_view.dart';
import '../../settings/views/settings_view.dart';
import '../../auth/views/login_view.dart';
import 'package:shimmer/shimmer.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<ProfileViewModel>();
    final bgColor = colors.background; // الخلفية من التصميم

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(context, vm, colors, bgColor),

      // 🚀 التعديل 1: لا نظهر دائرة التحميل الكبيرة إلا في المرة الأولى
      body: vm.isLoading
          ? _buildProfileSkeleton(colors)
          : vm.errorMessage != null && vm.profile == null
          ? Center(
              child: Text(
                vm.errorMessage!,
                style: TextStyle(color: colors.error),
              ),
            )
          : vm.profile == null
          ? const SizedBox()
          // 🚀 التعديل 2: تغليف الشاشة بالسحب للتحديث (Pull to Refresh)
          : RefreshIndicator(
              color: colors.primary,
              backgroundColor: colors.card,
              onRefresh: () async {
                await vm.fetchProfile();
              },
              child: DefaultTabController(
                length: 4,
                child: NestedScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildProfileHeader(context, vm.profile!, colors),
                            const SizedBox(height: 24),
                            // 🚀 تم تمرير الـ vm هنا ليعمل زر الإضافة
                            _buildActionButtons(context, vm, colors),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          _buildTabBar(context, colors) as TabBar,
                          bgColor,
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    children: [
                      _buildWorksTab(
                        context,
                        vm, // مررنا vm بدلاً من القائمة فقط للتحكم الأفضل
                      ),
                      ChangeNotifierProvider(
                        create: (context) => ServicesViewModel(
                          ProfileRepository(context.read<ApiService>()),
                        ),
                        child: const ServicesView(),
                      ),
                      ChangeNotifierProvider(
                        create: (context) => ContactInfoViewModel(
                          ProfileRepository(context.read<ApiService>()),
                        ),
                        child: ContactInfoView(profile: vm.profile!),
                      ),
                      ChangeNotifierProvider(
                        create: (context) => ProviderReviewsViewModel(
                          ReviewRepository(context.read<ApiService>()),
                          vm.profile!.id,
                        ),
                        child: const ProviderReviewsView(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ========================================================
  // 🧩 Widgets التصميم الفرعية
  // ========================================================

  AppBar _buildAppBar(
    BuildContext context,
    ProfileViewModel vm,
    dynamic colors,
    Color bgColor,
  ) {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      centerTitle: true,
      title: Text(
        vm.profile?.name ?? '...',
        style: TextStyle(
          color: colors.text,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      leading: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: colors.primary),
        onSelected: (value) => _handleMenuSelection(context, value),
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            value: 'complaints',
            child: Row(
              children: [
                const Icon(Icons.report_problem_outlined, size: 20),
                const SizedBox(width: 8),
                Text(context.tr('complaints')),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                const Icon(Icons.settings_outlined, size: 20),
                const SizedBox(width: 8),
                Text(context.tr('settings')),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, color: colors.error, size: 20),
                const SizedBox(width: 8),
                Text(
                  context.tr('logout'),
                  style: TextStyle(color: colors.error),
                ),
              ],
            ),
          ),
        ],
      ),
      // actions: [
      //   IconButton(
      //     icon: Icon(Icons.arrow_forward, color: colors.text),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      // ],
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    dynamic profile,
    dynamic colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.primary, width: 3),
                  image: profile.avatarUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(profile.avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage('assets/images/default_avatar.png'),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              _buildStatItem(
                context,
                '${profile.servicesCount}',
                context.tr('tab_services'),
                colors,
              ),
              _buildStatItem(
                context,
                '${profile.requestsCount}',
                context.tr('nav_orders'),
                colors,
              ),
              _buildStatItem(
                context,
                '${profile.ratingAvg}',
                context.tr('rating'),
                colors,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.jobTitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.bio.isNotEmpty ? profile.bio : context.tr('default_bio'),
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 13, color: colors.textSub, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    dynamic colors,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: colors.primary),
        ),
      ],
    );
  }

  Widget _buildProfileSkeleton(dynamic colors) {
    return Shimmer.fromColors(
      baseColor: colors.text.withValues(alpha: 0.08),
      highlightColor: colors.text.withValues(alpha: 0.02),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
            const SizedBox(height: 16),
            // Name
            Container(width: 180, height: 22, color: Colors.white),
            const SizedBox(height: 8),
            // Job Title
            Container(width: 120, height: 16, color: Colors.white),
            const SizedBox(height: 24),
            // Stats Grid
            Row(
              children: List.generate(3, (index) => Expanded(
                child: Container(
                  height: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                ),
              )),
            ),
            const SizedBox(height: 32),
            // Tabs skeleton
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            ),
            const SizedBox(height: 24),
            // Body items skeleton
            Column(
              children: List.generate(3, (index) => Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ProfileViewModel vm,
    dynamic colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          // زر تعديل الملف الشخصي
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (context) => EditProfileViewModel(
                        ProfileRepository(context.read<ApiService>()),
                        vm.profile!,
                      ),
                      child: const EditProfileView(),
                    ),
                  ),
                );
                if (result == true) vm.fetchProfile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                context.tr('edit_profile'),
                style: TextStyle(
                  color: context.qsColors.card,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 🚀 تم تغيير زر المشاركة إلى "إضافة عمل سابق"
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (context) => AddWorkViewModel(
                        ProfileRepository(context.read<ApiService>()),
                      ),
                      child: const AddWorkView(),
                    ),
                  ),
                );
                // 🔄 تحديث البيانات فور العودة بنجاح من شاشة الإضافة
                if (result == true) vm.fetchProfile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                context.tr(
                  'add_previous_work',
                ), // تأكد من وجود المفتاح في ملفات الترجمة
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, dynamic colors) {
    return TabBar(
      labelColor: colors.primary,
      unselectedLabelColor: colors.textSub,
      indicatorColor: colors.primary,
      indicatorWeight: 3,
      tabs: [
        Tab(
          icon: const Icon(Icons.grid_view_rounded),
          text: context.tr('tab_works'),
        ),
        Tab(
          icon: const Icon(Icons.build_rounded),
          text: context.tr('tab_services'),
        ),
        Tab(
          icon: const Icon(Icons.contact_phone_rounded),
          text: context.tr('contact_info'),
        ),
        Tab(
          icon: const Icon(Icons.star_rate_rounded),
          text: context.tr('tab_reviews'),
        ),
      ],
    );
  }

  Widget _buildWorksTab(BuildContext context, ProfileViewModel vm) {
    final colors = context.qsColors;
    final works = vm.works;
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: works.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // يمكن أيضاً جعل هذا المربع يفتح شاشة الإضافة
          return InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (context) => AddWorkViewModel(
                      ProfileRepository(context.read<ApiService>()),
                    ),
                    child: const AddWorkView(),
                  ),
                ),
              );
              if (result == true) vm.fetchProfile();
            },
            child: Container(
              color: context.qsColors.primary.withValues(alpha: 0.1),
              child: Center(
                child: Icon(
                  Icons.add_a_photo_outlined,
                  color: colors.primary,
                  size: 32,
                ),
              ),
            ),
          );
        }
        final work = works[index - 1]; // استخراج العمل الحالي كاملًا
        final imageUrl = work.imageUrl;
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                  create: (context) => PreviousWorksViewModel(
                    ProfileRepository(context.read<ApiService>()),
                  ),
                  child: PreviousWorksView(profile: vm.profile!),
                ),
              ),
            );
          },
          onLongPress: () {
            _showWorkOptionsBottomSheet(context, work, vm);
          },
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: context.qsColors.textSub.withValues(alpha: 0.1),
              child: const Icon(Icons.broken_image),
            ),
          ),
        );
      },
    );
  }

  // ========================================================
  // 🧩 قوائم التعديل والحذف المنبثقة للعمل السابق
  // ========================================================

  void _showWorkOptionsBottomSheet(
    BuildContext context,
    WorkModel work,
    ProfileViewModel vm,
  ) {
    final colors = context.qsColors;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.qsColors.textSub.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.edit, color: colors.primary),
                title: Text(
                  context.tr('edit'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => EditWorkViewModel(
                          ProfileRepository(context.read<ApiService>()),
                          work,
                        ),
                        child: const EditWorkView(),
                      ),
                    ),
                  );
                  if (result == true) vm.fetchProfile();
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: colors.primary),
                title: Text(
                  context.tr('share'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  DialogHelper.showSuccessDialog(
                    context,
                    context.tr('link_copied_soon'),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: colors.error),
                title: Text(
                  context.tr('delete'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.error,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteConfirmationDialog(context, work, vm);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WorkModel work,
    ProfileViewModel vm,
  ) {
    final colors = context.qsColors;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            context.tr('delete_confirm_title'),
            textAlign: TextAlign.right,
          ),
          content: Text(
            context.tr(
              'delete_confirm_msg_specific',
              args: {'title': work.title},
            ),
            textAlign: TextAlign.right,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                context.tr('cancel'),
                style: TextStyle(color: colors.textSub),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx); // اغلاق الديالوج

                // عرض مؤشر التحميل بينما يحذف
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );

                try {
                  await ProfileRepository(
                    context.read<ApiService>(),
                  ).deleteWork(work.id);
                  Navigator.pop(context); // إغلاق الديالوج حق التحميل
                  vm.fetchProfile(); // تحديث القائمة الواجهة
                  DialogHelper.showSuccessDialog(
                    context,
                    context.tr('delete_success'),
                  );
                } catch (e) {
                  Navigator.pop(context); // إغلاق الديالوج التحميل
                  DialogHelper.showErrorDialog(
                    context,
                    context.tr(e.toString()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: colors.error),
              child: Text(context.tr('auto_tr_86'), style: TextStyle(color: context.qsColors.card)),
            ),
          ],
        );
      },
    );
  }

  // ========================================================
  // 🧩 معالجة خيارات القائمة
  // ========================================================

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'complaints':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ComplaintsView()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsView()),
        );
        break;
      case 'logout':
        _showLogoutConfirmationDialog(context);
        break;
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    final colors = context.qsColors;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(context.tr('auto_tr_43'), textAlign: TextAlign.right),
          content: Text(context.tr('auto_tr_32'),
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.tr('auto_tr_51'), style: TextStyle(color: colors.textSub)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx); // إغلاق الديالوج

                // عرض مؤشر التحميل
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => Center(
                    child: CircularProgressIndicator(color: colors.primary),
                  ),
                );

                final authVm = context.read<AuthViewModel>();
                final success = await authVm.logout();

                if (context.mounted) {
                  Navigator.pop(context); // إغلاق مؤشر التحميل

                  if (success) {
                    // العودة لشاشة تسجيل الدخول ومسح كل الشاشات السابقة
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginView()),
                      (route) => false,
                    );
                  } else {
                    DialogHelper.showErrorDialog(
                      context,
                      context.tr('logout_failed'),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: colors.error),
              child: Text(
                context.tr('exit'),
                style: TextStyle(color: context.qsColors.card),
              ),
            ),
          ],
        );
      },
    );
  }
}

// 🧩 كلاس مساعد لتثبيت شريط التبويبات
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color backgroundColor;
  _SliverAppBarDelegate(this._tabBar, this.backgroundColor);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}



