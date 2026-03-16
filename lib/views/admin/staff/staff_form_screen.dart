// lib/views/admin/staff/staff_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:marcat/models/enums.dart';

class StaffFormScreen extends StatefulWidget {
  const StaffFormScreen({super.key});

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _storeIdCtrl = TextEditingController();

  UserRole _selectedRole = UserRole.salesperson;
  bool _isLoading = false;
  bool _obscurePassword = true;

  AdminController get _adminCtrl => Get.find<AdminController>();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _storeIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final storeIdParsed = int.tryParse(_storeIdCtrl.text.trim());
    if (storeIdParsed == null) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid numeric Store ID.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await _adminCtrl.createStaffMember(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: _selectedRole,
        storeId: storeIdParsed,
      );

      // Success path — navigate back
      if (mounted) {
        Get.back();
        Get.snackbar(
          'Success',
          'Staff member created successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.successGreenLight,
          colorText: AppColors.statusGreen,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          e.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.statusRedLight,
          colorText: AppColors.statusRed,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title: const Text('Add Staff Member'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Name row ──────────────────────────────────────────
                  FB5Row(
                    children: [
                      FB5Col(
                        classNames: 'col-md-6',
                        child: _buildField(
                          controller: _firstNameCtrl,
                          label: 'First Name',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      FB5Col(
                        classNames: 'col-md-6',
                        child: _buildField(
                          controller: _lastNameCtrl,
                          label: 'Last Name',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // ── Email ─────────────────────────────────────────────
                  _buildField(
                    controller: _emailCtrl,
                    label: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // ── Password ──────────────────────────────────────────
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Temporary Password',
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // ── Store ID ──────────────────────────────────────────
                  _buildField(
                    controller: _storeIdCtrl,
                    label: 'Store ID',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (int.tryParse(v.trim()) == null) {
                        return 'Must be a number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // ── Role picker ───────────────────────────────────────
                  DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: [
                      UserRole.salesperson,
                      UserRole.store_manager,
                      UserRole.driver,
                    ]
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.dbValue),
                            ))
                        .toList(),
                    onChanged: (r) {
                      if (r != null) setState(() => _selectedRole = r);
                    },
                  ),
                  const SizedBox(height: AppDimensions.space32),

                  // ── Submit ────────────────────────────────────────────
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.marcatGold,
                        foregroundColor: AppColors.marcatBlack,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.marcatBlack),
                            )
                          : Text('Create Staff Member',
                              style: AppTextStyles.buttonPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: validator,
    );
  }
}
