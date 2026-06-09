import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:service_provider_app/core/widgets/custom_button.dart';
import 'package:service_provider_app/core/widgets/custom_textfield.dart';
import '../../services/models/category_model.dart';
import '../viewmodels/register_viewmodel.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RegisterViewModel>(context);
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('register_provider_title'),
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('register_provider_subtitle'),
                style: TextStyle(
                  color: colors.textSub,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 24),

              // Full Name
              CustomTextField(
                label: context.tr('name_label'),
                hint: context.tr('name_hint'),
                prefixIcon: Icons.person_outline,
                controller: viewModel.nameController,
              ),
              const SizedBox(height: 16),

              // Email
              CustomTextField(
                label: context.tr('email_label'),
                hint: context.tr('email_hint'),
                prefixIcon: Icons.email_outlined,
                controller: viewModel.emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              Text(
                context.tr('choose_category_label'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 8),
              viewModel.isCategoriesLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colors.text.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.textSub.withOpacity(0.2),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CategoryModel>(
                          isExpanded: true,
                          value: viewModel.selectedCategory,
                          hint: Text(
                            context.tr('choose_category_hint'),
                            style: TextStyle(
                              color: colors.textSub.withOpacity(0.5),
                              fontFamily: 'Cairo',
                              fontSize: 14,
                            ),
                          ),
                          dropdownColor: colors.card,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: colors.textSub,
                          ),
                          items: viewModel.categories.map((category) {
                            return DropdownMenuItem<CategoryModel>(
                              value: category,
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  color: colors.text,
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: viewModel.setSelectedCategory,
                        ),
                      ),
                    ),
              const SizedBox(height: 16),

              // Password
              CustomTextField(
                label: context.tr('password_label'),
                hint: context.tr('password_hint'),
                isPassword: viewModel.isObscurePassword,
                controller: viewModel.passwordController,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    viewModel.isObscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: colors.textSub.withOpacity(0.7),
                  ),
                  onPressed: viewModel.togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              CustomTextField(
                label: context.tr('password_confirm_label'),
                hint: context.tr('password_confirm_hint'),
                isPassword: viewModel.isObscureConfirmPassword,
                controller: viewModel.passwordConfirmController,
                prefixIcon: Icons.lock_clock_outlined,
                suffixIcon: IconButton(
                  icon: Icon(
                    viewModel.isObscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: colors.textSub.withOpacity(0.7),
                  ),
                  onPressed: viewModel.toggleConfirmPasswordVisibility,
                ),
              ),
              const SizedBox(height: 16),

              // Location Description
              CustomTextField(
                label: context.tr('location_label'),
                hint: context.tr('location_hint_text'),
                prefixIcon: Icons.location_on_outlined,
                controller: viewModel.locationController,
              ),
              const SizedBox(height: 16),

              // Request Content / Description
              Text(
                context.tr('provider_desc_label'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: viewModel.requestContentController,
                maxLines: 4,
                style: TextStyle(color: colors.text, fontFamily: 'Cairo'),
                decoration: InputDecoration(
                  hintText: context.tr('provider_desc_hint'),
                  hintStyle: TextStyle(
                    color: colors.textSub.withOpacity(0.5),
                    fontFamily: 'Cairo',
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: colors.text.withOpacity(0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colors.textSub.withOpacity(0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colors.textSub.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ID Card Image Picker
              Text(
                context.tr('id_card_label'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: viewModel.idCardImage == null
                    ? viewModel.pickIdCardImage
                    : null,
                child: DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    radius: const Radius.circular(12),
                    color: viewModel.idCardImage == null
                        ? colors.textSub.withOpacity(0.3)
                        : colors.primary,
                    strokeWidth: 2,
                    dashPattern: const [6, 4],
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: colors.text.withOpacity(0.01),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: viewModel.idCardImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_search_rounded,
                                size: 40,
                                color: colors.textSub.withOpacity(0.7),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                context.tr('id_card_picker_hint'),
                                style: TextStyle(
                                  color: colors.textSub.withOpacity(0.7),
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.tr('upload_limit_hint'),
                                style: TextStyle(
                                  color: colors.textSub.withOpacity(0.4),
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  viewModel.idCardImage!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: viewModel.removeIdCardImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              viewModel.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : CustomButton(
                      text: context.tr('register_button'),
                      icon: Icons.person_add_alt_1_rounded,
                      isPrimary: true,
                      onPressed: () => viewModel.register(context),
                    ),
              const SizedBox(height: 24),

              // Back to Login link
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    context.tr('already_have_account'),
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
