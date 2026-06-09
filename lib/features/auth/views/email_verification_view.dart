import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_provider_app/core/localization/app_localizations.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:service_provider_app/core/widgets/custom_button.dart';
import 'package:service_provider_app/core/widgets/custom_textfield.dart';
import 'package:service_provider_app/core/utils/dialog_helper.dart';
import '../viewmodels/register_viewmodel.dart';
import 'login_view.dart';

class EmailVerificationView extends StatefulWidget {
  final String email;

  const EmailVerificationView({super.key, required this.email});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  final TextEditingController _codeController = TextEditingController();
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify(BuildContext context, RegisterViewModel viewModel) async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      DialogHelper.showErrorDialog(context, context.tr('validation_empty_fields'));
      return;
    }

    final success = await viewModel.verifyOtp(context, widget.email, code);
    if (success) {
      if (!context.mounted) return;
      DialogHelper.showSuccessDialog(
        context,
        context.tr('verification_success_msg'),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginView()),
            (route) => false,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RegisterViewModel>(context);
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          context.tr('email_verification_title'),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: colors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                context.tr('email_verification_subtitle'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 32),

              // Code field
              CustomTextField(
                label: context.tr('otp_code_label'),
                hint: context.tr('otp_code_hint'),
                prefixIcon: Icons.security_rounded,
                controller: _codeController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),

              // Verify Button
              viewModel.isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      text: context.tr('verify_button'),
                      icon: Icons.check_circle_outline_rounded,
                      isPrimary: true,
                      onPressed: () => _verify(context, viewModel),
                    ),
              const SizedBox(height: 24),

              // Resend code area
              _canResend
                  ? TextButton.icon(
                      onPressed: () async {
                        final success = await viewModel.resendOtp(context, widget.email);
                        if (success) {
                          _startTimer();
                        }
                      },
                      icon: Icon(Icons.refresh_rounded, color: colors.primary),
                      label: Text(
                        context.tr('resend_code_btn'),
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    )
                  : Text(
                      context.tr('resend_code_after').replaceAll(
                            '{seconds}',
                            _secondsRemaining.toString(),
                          ),
                      style: TextStyle(
                        color: colors.textSub,
                        fontFamily: 'Cairo',
                        fontSize: 13,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
