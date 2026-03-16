// lib/views/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_scaffold.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../core/utils/validators.dart';
import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/core/router/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await Get.find<AuthController>().signIn(_email.text, _password.text);
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
        title: 'Welcome back',
        subTitle: 'Sign in to continue to your account',
        form: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Email ─────────────────────────────────────────────────
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: AuthTheme.bodyStyle,
                decoration: AuthTheme.inputDecoration(
                  'Email address',
                  prefixIcon: Icons.email_outlined,
                ),
                validator: Validators.email,
              ),
              const SizedBox(height: 16),

              // ── Password ──────────────────────────────────────────────
              TextFormField(
                controller: _password,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                style: AuthTheme.bodyStyle,
                decoration: AuthTheme.inputDecoration(
                  'Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: AppDimensions.iconM,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: Validators.password,
                onFieldSubmitted: (_) => _submit(),
              ),

              // ── Forgot password ───────────────────────────────────────
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AuthTheme.muted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // ── Sign In button ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Obx(() {
                  final loading =
                      Get.find<AuthController>().state.value.isLoading;
                  return ElevatedButton(
                    onPressed: loading ? null : _submit,
                    style: AuthTheme.primaryButtonStyle(),
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Sign In', style: AuthTheme.buttonLabel),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // ── Register link ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New here?',
                      style: TextStyle(color: AuthTheme.muted, fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.register),
                      child: const Text('Create an Account'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
