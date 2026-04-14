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
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import 'complaints_view.dart';
import '../../settings/views/settings_view.dart';
import '../../auth/views/login_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<ProfileViewModel>();
    final bgColor = const Color(0xFFF8F9FA); // الخلفية من التصميم

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(context, vm, colors, bgColor),

      // 🚀 التعديل 1: لا نظهر دائرة التحميل الكبيرة إلا في المرة الأولى
      body: vm.isLoading && vm.profile == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5CA4B8)),
            )
          : vm.errorMessage != null && vm.profile == null
          ? Center(
              child: Text(
                vm.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : vm.profile == null
          ? const SizedBox()
          // 🚀 التعديل 2: تغليف الشاشة بالسحب للتحديث (Pull to Refresh)
          : RefreshIndicator(
              color: const Color(0xFF5CA4B8),
              backgroundColor: Colors.white,
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

                      // داخل TabBarView
                      Center(
                        child: Text(context.tr('reviews_soon')),
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
        icon: const Icon(Icons.more_vert, color: Colors.blue),
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
                const Icon(Icons.logout, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(context.tr('logout'), style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.arrow_forward, color: colors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ],
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
              _buildStatItem(
                context,
                '${profile.yearsExperience}+',
                context.tr('years_experience'),
                colors,
              ),
              _buildStatItem(
                context,
                '${profile.ratingAvg}',
                context.tr('rating'),
                colors,
              ),
              _buildStatItem(
                context,
                '${profile.completedJobs}',
                context.tr('completed_jobs'),
                colors,
              ),

              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF5CA4B8), width: 3),
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
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5CA4B8),
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
          style: const TextStyle(fontSize: 12, color: Color(0xFF5CA4B8)),
        ),
      ],
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
                backgroundColor: const Color(0xFF5CA4B8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                context.tr('edit_profile'),
                style: const TextStyle(
                  color: Colors.white,
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
                backgroundColor: const Color(0xFFE5E7EB),
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
      labelColor: const Color(0xFF5CA4B8),
      unselectedLabelColor: colors.textSub,
      indicatorColor: const Color(0xFF5CA4B8),
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
          icon: const Icon(Icons.star_rate_rounded),
          text: context.tr('tab_reviews'),
        ),
        Tab(
          icon: const Icon(Icons.contact_phone_rounded),
          text: context.tr('contact_info'),
        ),
      ],
    );
  }

  Widget _buildWorksTab(BuildContext context, ProfileViewModel vm) {
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
              color: const Color(0xFFE4F3F8),
              child: const Center(
                child: Icon(
                  Icons.add_a_photo_outlined,
                  color: Color(0xFF5CA4B8),
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
              color: Colors.grey.shade300,
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF5CA4B8)),
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
                leading: const Icon(Icons.share, color: Colors.blue),
                title: Text(
                  context.tr('share'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('link_copied_soon'))),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  context.tr('delete'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
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
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(context.tr('delete_confirm_title'), textAlign: TextAlign.right),
          content: Text(
            context.tr('delete_confirm_msg_specific', args: {'title': work.title}),
            textAlign: TextAlign.right,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.tr('cancel'), style: const TextStyle(color: Colors.grey)),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('delete_success')),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context); // إغلاق الديالوج التحميل
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
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
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('تسجيل الخروج', textAlign: TextAlign.right),
          content: const Text(
            'هل أنت متأكد أنك تريد تسجيل الخروج؟',
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx); // إغلاق الديالوج

                // عرض مؤشر التحميل
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF5CA4B8)),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('logout_failed')),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                context.tr('exit'),
                style: const TextStyle(color: Colors.white),
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
