import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../viewmodels/policy_viewmodel.dart';
import 'package:service_provider_app/features/home/views/main_view.dart' as service_provider_app_main_view;
class PrivacyPolicyView extends StatefulWidget {
  final bool requiresAcceptance;
  const PrivacyPolicyView({super.key, this.requiresAcceptance = false});

  @override
  State<PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<PrivacyPolicyView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PolicyViewModel>().fetchProviderPolicy();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        centerTitle: true,
        leading: widget.requiresAcceptance
            ? const SizedBox()
            : IconButton(
                icon: Icon(Icons.arrow_back, color: colors.primary),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          context.tr('privacy_policy'),
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer<PolicyViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: colors.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: colors.text, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.fetchProviderPolicy(),
                      style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
                      child: Text(context.tr('retry'), style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          final policyText = viewModel.policyText ?? context.tr('no_data_available');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colors.text.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                policyText,
                style: TextStyle(
                  color: colors.text,
                  height: 1.8,
                  fontSize: 15,
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.requiresAcceptance
          ? Consumer<PolicyViewModel>(
              builder: (context, viewModel, child) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.card,
                    boxShadow: [
                      BoxShadow(
                        color: colors.text.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            try {
                              await viewModel.agreeToPolicy(context);
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const service_provider_app_main_view.MainView()),
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('حدث خطأ: $e'),
                                    backgroundColor: colors.error,
                                  ),
                                );
                              }
                            }
                          },
                    child: viewModel.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            context.tr('agree_to_policy') ?? 'موافق على سياسة الخصوصية', // fallback text if key not added
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              },
            )
          : null,
    );
  }
}
