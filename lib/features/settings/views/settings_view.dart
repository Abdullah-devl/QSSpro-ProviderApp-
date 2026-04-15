import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../viewmodels/settings_provider.dart';
import '../../complaints/views/complaints_hub_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('nav_settings'),
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎨 Section: Appearance
            _buildSectionTitle(context, 'appearance'),
            _buildSettingsCard([
              _buildSettingTile(
                context,
                icon: Icons.dark_mode_outlined,
                title: context.tr('dark_mode'),
                trailing: CupertinoSwitch(
                  activeColor: colors.primary,
                  value: settingsProvider.isDarkMode,
                  onChanged: (value) => settingsProvider.toggleDarkMode(),
                ),
              ),
            ]),

            const SizedBox(height: 24),

            // 🌍 Section: Preferences
            _buildSectionTitle(context, 'preferences'),
            _buildSettingsCard([
              _buildSettingTile(
                context,
                icon: Icons.language_outlined,
                title: context.tr('language'),
                subtitle: settingsProvider.languageCode == 'ar' 
                    ? context.tr('arabic') 
                    : context.tr('english'),
                onTap: () => _showLanguageDialog(context, settingsProvider),
              ),
            ]),

            const SizedBox(height: 24),

            // 🛠️ Section: Support
            _buildSectionTitle(context, 'support_hub'),
            _buildSettingsCard([
              _buildSettingTile(
                context,
                icon: Icons.report_problem_outlined,
                title: context.tr('complaints'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ComplaintsView()),
                  );
                },
              ),
            ]),

            const SizedBox(height: 24),

            // 📜 Section: Legal & About
            _buildSectionTitle(context, 'legal_about'),
            _buildSettingsCard([
              _buildSettingTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: context.tr('privacy_policy'),
                onTap: () => _showInfoDialog(context, 'privacy_policy'),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                context,
                icon: Icons.description_outlined,
                title: context.tr('terms_of_service'),
                onTap: () => _showInfoDialog(context, 'terms_of_service'),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                context,
                icon: Icons.info_outline,
                title: context.tr('app_version'),
                trailing: const Text(
                  '2.4.0',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
            ]),

            const SizedBox(height: 40),
            Center(
              child: Text(
                'QuickServe © 2026',
                style: TextStyle(color: colors.textSub, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String key) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        context.tr(key).toUpperCase(),
        style: const TextStyle(
          color: Colors.blueGrey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.blue, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: subtitle != null 
          ? Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)) 
          : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr('select_language'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Center(child: Text('العربية', style: TextStyle(fontWeight: FontWeight.bold))),
                onTap: () {
                  provider.changeLanguage('ar');
                  Navigator.pop(ctx);
                },
              ),
              const Divider(),
              ListTile(
                title: const Center(child: Text('English', style: TextStyle(fontWeight: FontWeight.bold))),
                onTap: () {
                  provider.changeLanguage('en');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context, String key) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.tr(key)),
        content: SingleChildScrollView(
          child: Text(
            'هذه مسودة لسياسة الخصوصية وشروط الخدمة. سيتم إدراج المحتوى القانوني الكامل لاحقاً.\n\n'
            'This is a placeholder for the privacy policy and terms of service. The full legal content will be included later.',
            style: const TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق / Close'),
          ),
        ],
      ),
    );
  }
}
