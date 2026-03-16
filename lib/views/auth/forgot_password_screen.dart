// lib/views/auth/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_scaffold.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../core/utils/validators.dart';
import 'package:marcat/controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Get.find<AuthController>().forgotPassword(_emailController.text);
      if (mounted) setState(() => _isSuccess = true);
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => _isSuccess
      ? _buildSuccessScaffold()
      : AuthScaffold(
          title: 'Forgot password?',
          subTitle: "Enter your email and we'll send you a reset link",
          form: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Email ─────────────────────────────────────────────────
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  style: AuthTheme.bodyStyle,
                  decoration: AuthTheme.inputDecoration(
                    'Email address',
                    prefixIcon: Icons.email_outlined,
                  ),
                  validator: Validators.email,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 28),

                // ── Submit button ─────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: AuthTheme.primaryButtonStyle(),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Send Reset Link', style: AuthTheme.buttonLabel),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Back to login ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Remember your password?',
                        style: TextStyle(color: AuthTheme.muted, fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

  Widget _buildSuccessScaffold() => Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Icon badge ────────────────────────────────────────────
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_rounded,
                    size: 40,
                    color: Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(height: AppDimensions.space24),

                // ── Headline ──────────────────────────────────────────────
                const Text(
                  'Email Sent',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AuthTheme.primary,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check your inbox for a link to reset your password.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AuthTheme.muted,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.space48),

                // ── Back button ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: AuthTheme.primaryButtonStyle(),
                    child: Text('Back to Login', style: AuthTheme.buttonLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
