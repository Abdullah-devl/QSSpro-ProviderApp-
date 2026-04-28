// مسار الملف: lib/features/profile/views/edit_profile_view.dart

// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../viewmodels/edit_profile_viewmodel.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<EditProfileViewModel>();
    final bgColor = const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('edit_profile'),
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_forward, color: const Color(0xFF0F4A8A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          vm.isLoading
              ? const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
              : TextButton(
                  onPressed: () => vm.saveProfile(context),
                  child: Text(
                    context.tr('save'),
                    style: const TextStyle(color: Color(0xFF5CA4B8), fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 📸 الصورة الشخصية
            _buildAvatarSection(context, vm),
            const SizedBox(height: 32),

            // 📝 البطاقة الأولى: الاسم والمهنة
            _buildCardContainer(
              context,
              children: [
                _buildInputLabel(context.tr('full_name'), const Color(0xFF5CA4B8)),
                const SizedBox(height: 8),
                _buildTextField(context, vm.nameController, Icons.person_outline),
                const SizedBox(height: 20),
                _buildInputLabel(context.tr('profession'), const Color(0xFF5CA4B8)),
                const SizedBox(height: 8),
                _buildTextField(context, vm.jobTitleController, Icons.build_outlined),
              ],
            ),
            const SizedBox(height: 24),

            // 📄 البطاقة الثانية: الوصف الشخصي
            _buildCardContainer(
              context,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFD3E3EC), borderRadius: BorderRadius.circular(12)),
                      child: Text(context.tr('professional_badge'), style: const TextStyle(fontSize: 10, color: Color(0xFF0F4A8A))),
                    ),
                    _buildInputLabel(context.tr('personal_bio'), const Color(0xFF5CA4B8)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(context, vm.bioController, null, maxLines: 5),
              ],
            ),
            const SizedBox(height: 24),

            // ⚡ البطاقة الثالثة: وضع متاح للعمل
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF3F6), // أزرق فاتح جداً من التصميم
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                children: [
                  CupertinoSwitch(
                    value: vm.isAvailable,
                    activeColor: const Color(0xFF5CA4B8),
                    onChanged: (val) => vm.toggleAvailability(val),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(context.tr('available_for_work'), style: TextStyle(fontWeight: FontWeight.bold, color: colors.text, fontSize: 15)),
                      Text(context.tr('available_for_work_desc'), style: TextStyle(color: colors.textSub, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFD3E3EC), shape: BoxShape.circle),
                    child: const Icon(Icons.flash_on_rounded, color: Color(0xFF5CA4B8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 🧩 المكونات الداخلية (Widgets)
  // ==========================================

  Widget _buildAvatarSection(BuildContext context, EditProfileViewModel vm) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => vm.pickImage(),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.qsColors.card, width: 4),
                  boxShadow: [BoxShadow(color: context.qsColors.text.withOpacity(0.1), blurRadius: 10)],
                  image: vm.newAvatar != null
                      ? DecorationImage(image: FileImage(vm.newAvatar!), fit: BoxFit.cover)
                      : DecorationImage(
                          image: vm.currentProfile.avatarUrl.isNotEmpty 
                            ? NetworkImage(vm.currentProfile.avatarUrl) as ImageProvider
                            : const AssetImage('assets/images/default_avatar.png'), 
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF5CA4B8), shape: BoxShape.circle, border: Border.all(color: context.qsColors.card, width: 2)),
                child: Icon(Icons.camera_alt_rounded, color: context.qsColors.card, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => vm.pickImage(),
          child: Text(context.tr('change_profile_picture'), style: const TextStyle(color: Color(0xFF5CA4B8), fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildCardContainer(BuildContext context, {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.qsColors.card,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: context.qsColors.text.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: children),
    );
  }

  Widget _buildInputLabel(String text, Color color) {
    return Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14));
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, IconData? icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        filled: true,
        fillColor: context.qsColors.background,
        prefixIcon: icon != null ? Icon(icon, color: context.qsColors.textSub) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}


