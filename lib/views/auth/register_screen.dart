// lib/views/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_scaffold.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../core/utils/validators.dart';
// FIX: was importing auth_provider.dart — replaced by auth_controller.dart
import 'package:marcat/controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmController.text) {
      SnackbarUtils.showError(context, 'Passwords do not match');
      return;
    }
    try {
      await Get.find<AuthController>().register(
        email: _emailController.text,
        password: _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      );
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
        title: 'Create account',
        subTitle: 'Fill in the details below to get started',
        form: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── First & Last name ─────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      textInputAction: TextInputAction.next,
                      style: AuthTheme.bodyStyle,
                      decoration: AuthTheme.inputDecoration(
                        'First name',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      validator: Validators.requiredField,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      textInputAction: TextInputAction.next,
                      style: AuthTheme.bodyStyle,
                      decoration: AuthTheme.inputDecoration(
                        'Last name',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      validator: Validators.requiredField,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Email ─────────────────────────────────────────────────
              TextFormField(
                controller: _emailController,
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

              // ── Phone ─────────────────────────────────────────────────
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                style: AuthTheme.bodyStyle,
                decoration: AuthTheme.inputDecoration(
                  'Phone number',
                  prefixIcon: Icons.phone_outlined,
                ),
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),

              // ── Password ──────────────────────────────────────────────
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
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
              ),
              const SizedBox(height: 16),

              // ── Confirm password ──────────────────────────────────────
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                style: AuthTheme.bodyStyle,
                decoration: AuthTheme.inputDecoration(
                  'Confirm password',
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: AppDimensions.iconM,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                // FIX: Pass a function that evaluates the current password text
                validator: (val) {
                  if (val == null || val.isEmpty) return 'This field is required';
                  if (val != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 28),

              // ── Terms notice ──────────────────────────────────────────
              const Text(
                'By creating an account you agree to our Terms of Service and Privacy Policy.',
                style: TextStyle(
                  color: AuthTheme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // ── Submit button ─────────────────────────────────────────
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
                        : Text('Create Account', style: AuthTheme.buttonLabel),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // ── Login link ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
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
}
