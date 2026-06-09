import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:service_provider_app/core/widgets/custom_button.dart';
import '../../services/models/category_model.dart';
import '../viewmodels/authorized_categories_viewmodel.dart';

class AuthorizedCategoriesView extends StatelessWidget {
  const AuthorizedCategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthorizedCategoriesViewModel>(context);
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('authorized_categories_title'), // "الأقسام المصرحة"
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.authorizedCategories.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: viewModel.authorizedCategories.length,
                  itemBuilder: (context, index) {
                    final category = viewModel.authorizedCategories[index];
                    return _buildCategoryCard(context, category);
                  },
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: CustomButton(
          text: context.tr('request_new_category'), // "طلب إضافة قسم جديد"
          icon: Icons.category_outlined,
          isPrimary: true,
          onPressed: () => _showRequestBottomSheet(context, viewModel),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.qsColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: colors.textSub.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('no_packages_available'), // fallback empty text
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSub,
                fontSize: 15,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryModel category) {
    final colors = context.qsColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.text.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.category_rounded, color: colors.primary),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
            fontSize: 16,
          ),
        ),
        subtitle: category.maxServices != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '${context.tr('services_count').replaceAll('{count}', category.maxServices.toString())} (الأقصى)',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              )
            : null,
        children: [
          if (category.children.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  context.tr('no_services_available'),
                  style: TextStyle(color: colors.textSub, fontFamily: 'Cairo', fontSize: 13),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: category.children.map((sub) {
                    return Chip(
                      backgroundColor: colors.background,
                      label: Text(
                        sub.name,
                        style: TextStyle(
                          color: colors.text,
                          fontFamily: 'Cairo',
                          fontSize: 12,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: colors.textSub.withOpacity(0.1),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showRequestBottomSheet(BuildContext context, AuthorizedCategoriesViewModel viewModel) {
    final colors = context.qsColors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AnimatedBuilder(
              animation: viewModel,
              builder: (context, _) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: 24,
                    left: 24,
                    right: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: colors.textSub.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          context.tr('request_new_category'),
                          style: TextStyle(
                            color: colors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Dropdown of all categories
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
                        Container(
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
                              items: viewModel.allCategories.map((category) {
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

                        // Description of requested services
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
                          controller: viewModel.descriptionController,
                          maxLines: 3,
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

                        // Certificate / Document picker
                        Text(
                          context.tr('document_label'), // "مستند التوثيق / الشهادة"
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: viewModel.documentFile == null
                              ? viewModel.pickDocument
                              : null,
                          child: DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              radius: const Radius.circular(12),
                              color: viewModel.documentFile == null
                                  ? colors.textSub.withOpacity(0.3)
                                  : colors.primary,
                              strokeWidth: 2,
                              dashPattern: const [6, 4],
                            ),
                            child: Container(
                              width: double.infinity,
                              height: 120,
                              decoration: BoxDecoration(
                                color: colors.text.withOpacity(0.01),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: viewModel.documentFile == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.document_scanner_outlined,
                                          size: 32,
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
                                      ],
                                    )
                                  : Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.file(
                                            viewModel.documentFile!,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: viewModel.removeDocument,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        viewModel.isSubmitLoading
                            ? const Center(child: CircularProgressIndicator())
                            : CustomButton(
                                text: context.tr('submit_for_review'),
                                icon: Icons.send_rounded,
                                isPrimary: true,
                                onPressed: () => viewModel.submitRequest(context),
                              ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
