// مسار الملف: lib/features/profile/views/edit_profile_view.dart

// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../viewmodels/edit_profile_viewmodel.dart';
import '../widgets/map_location_picker.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<EditProfileViewModel>();
    final bgColor = colors.background;

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
          icon: Icon(Icons.arrow_forward, color: colors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          vm.isLoading
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: () => vm.saveProfile(context),
                  child: Text(
                    context.tr('save'),
                    style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 16),
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
                _buildInputLabel(context.tr('full_name'), colors.primary),
                const SizedBox(height: 8),
                _buildTextField(context, vm.nameController, Icons.person_outline, readOnly: true),
                const SizedBox(height: 20),
                _buildInputLabel(context.tr('profession'), colors.primary),
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
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        context.tr('professional_badge'),
                        style: TextStyle(fontSize: 10, color: colors.primary),
                      ),
                    ),
                    _buildInputLabel(context.tr('personal_bio'), colors.primary),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(context, vm.bioController, null, maxLines: 5),
              ],
            ),
            const SizedBox(height: 24),

            // 📍 البطاقة الثالثة: الموقع الجغرافي
            _buildCardContainer(
              context,
              children: [
                _buildInputLabel(context.tr('work_location'), colors.primary),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final LatLng? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapLocationPicker(
                          initialLat: vm.selectedLat,
                          initialLng: vm.selectedLng,
                        ),
                      ),
                    );
                    if (result != null) {
                      vm.updateLocation(result.latitude, result.longitude);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          vm.selectedLat != null ? Icons.check_circle : Icons.add_location_alt_outlined,
                          color: vm.selectedLat != null ? colors.success : colors.textSub,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            vm.selectedLat != null
                                ? "${vm.selectedLat!.toStringAsFixed(4)}, ${vm.selectedLng!.toStringAsFixed(4)}"
                                : context.tr('select_location_on_map'),
                            style: TextStyle(
                              color: vm.selectedLat != null ? colors.text : colors.textSub,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
    final colors = context.qsColors;
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
                  border: Border.all(color: colors.card, width: 4),
                  boxShadow: [BoxShadow(color: colors.text.withOpacity(0.1), blurRadius: 10)],
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
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.card, width: 2),
                ),
                child: Icon(Icons.camera_alt_rounded, color: colors.card, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => vm.pickImage(),
          child: Text(
            context.tr('change_profile_picture'),
            style: TextStyle(color: colors.primary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer(BuildContext context, {required List<Widget> children}) {
    final colors = context.qsColors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: colors.text.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: children),
    );
  }

  Widget _buildInputLabel(String text, Color color) {
    return Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14));
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, IconData? icon, {int maxLines = 1, bool readOnly = false}) {
    final colors = context.qsColors;
    return Opacity(
      opacity: readOnly ? 0.7 : 1.0,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        textAlign: TextAlign.right,
        style: TextStyle(color: colors.text),
        decoration: InputDecoration(
          filled: true,
          fillColor: colors.background,
          prefixIcon: icon != null ? Icon(icon, color: colors.textSub) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
