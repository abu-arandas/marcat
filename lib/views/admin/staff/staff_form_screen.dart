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

    setState(() => _isLoading = true);

    try {
      final success = await _adminCtrl.createStaffMember(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: _selectedRole,
        storeId: storeIdParsed,
      );

      if (success && mounted) {
        Get.back();
        Get.snackbar(
          'Success',
          'Staff member created successfully.',
          backgroundColor: AppColors.statusGreenLight,
          colorText: AppColors.statusGreen,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _storeIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterBootstrap5(
      builder: (context) => Scaffold(
        backgroundColor: AppColors.surfaceGrey,
        appBar: AppBar(
          title: const Text('Add Staff Member'),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Center(
            child: FB5Container(
              child: FB5Row(
                classNames: 'justify-content-center',
                children: [
                  FB5Col(
                    classNames: 'col-12 col-md-10 col-lg-8 col-xl-6',
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Personal details ────────────────────────────
                          _buildSectionCard(
                            title: 'Personal Details',
                            children: [
                              FB5Row(
                                children: [
                                  FB5Col(
                                    classNames: 'col-12 col-md-6 mb-3 mb-md-0',
                                    child: TextFormField(
                                      controller: _firstNameCtrl,
                                      textInputAction: TextInputAction.next,
                                      decoration: const InputDecoration(
                                        labelText: 'First Name',
                                      ),
                                      validator: (v) =>
                                          v == null || v.trim().isEmpty
                                              ? 'First name is required.'
                                              : null,
                                    ),
                                  ),
                                  FB5Col(
                                    classNames: 'col-12 col-md-6',
                                    child: TextFormField(
                                      controller: _lastNameCtrl,
                                      textInputAction: TextInputAction.next,
                                      decoration: const InputDecoration(
                                        labelText: 'Last Name',
                                      ),
                                      validator: (v) =>
                                          v == null || v.trim().isEmpty
                                              ? 'Last name is required.'
                                              : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.space16),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Email is required.';
                                  }
                                  if (!v.contains('@')) {
                                    return 'Enter a valid email address.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.space16),

                          // ── Access credentials ──────────────────────────
                          _buildSectionCard(
                            title: 'Access Credentials',
                            children: [
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon:
                                      const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required.';
                                  }
                                  if (v.length < 8) {
                                    return 'Password must be at least 8 characters.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.space16),

                          // ── Role & store assignment ─────────────────────
                          _buildSectionCard(
                            title: 'Role & Store',
                            children: [
                              // Role dropdown
                              DropdownButtonFormField<UserRole>(
                                value: _selectedRole,
                                decoration: const InputDecoration(
                                  labelText: 'Role',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                items: [
                                  UserRole.salesperson,
                                  UserRole.store_manager,
                                  UserRole.driver,
                                ].map((role) {
                                  return DropdownMenuItem(
                                    value: role,
                                    child: Text(
                                      role.dbValue
                                          .replaceAll('_', ' ')
                                          .toUpperCase(),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (r) {
                                  if (r != null) {
                                    setState(() => _selectedRole = r);
                                  }
                                },
                              ),

                              const SizedBox(height: AppDimensions.space16),

                              // Store ID
                              // TODO: replace with a DropdownButtonFormField
                              TextFormField(
                                controller: _storeIdCtrl,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                decoration: const InputDecoration(
                                  labelText: 'Store ID',
                                  prefixIcon: Icon(Icons.storefront_outlined),
                                  helperText:
                                      'Numeric ID of the assigned store.',
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Store ID is required.';
                                  }
                                  if (int.tryParse(v.trim()) == null) {
                                    return 'Store ID must be a number.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.space32),

                          // ── Submit ──────────────────────────────────────
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            child: Text('Create Staff Member'),
                          ),

                          const SizedBox(height: AppDimensions.space32),
                        ],
                      ),
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

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.space16),
          ...children,
        ],
      ),
    );
  }
}
