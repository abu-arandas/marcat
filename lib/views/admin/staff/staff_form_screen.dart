// lib/presentation/admin/staff/staff_form_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import '../../../controllers/admin_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:marcat/models/enums.dart';
import '../../shared/widgets/marcat_app_bar.dart';
import '../../shared/widgets/marcat_button.dart';

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

  UserRole _selectedRole = UserRole.admin;
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Find the controller if it exists, or create a new one temporarily
    final controller = Get.isRegistered<AdminController>()
        ? Get.find<AdminController>()
        : Get.put(AdminController());

    final success = await controller.createStaffMember(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: _selectedRole,
      storeId: int.parse(_storeIdCtrl.text.trim()),
    );

    setState(() => _isLoading = false);

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        'Staff member created successfully',
        backgroundColor: AppColors.statusGreen,
        colorText: Colors.white,
      );
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
      builder: (context) {
        return Scaffold(
          backgroundColor: AppColors.surfaceGrey,
          appBar: const MarcatAppBar(
            title: 'Add Staff',
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
                            _buildSectionCard(
                              title: 'Personal Details',
                              children: [
                                FB5Row(
                                  children: [
                                    FB5Col(
                                      classNames:
                                          'col-12 col-md-6 mb-3 mb-md-0',
                                      child: TextFormField(
                                        controller: _firstNameCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'First Name',
                                          filled: true,
                                          fillColor: AppColors.surfaceGrey,
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (v) =>
                                            v!.isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                    FB5Col(
                                      classNames: 'col-12 col-md-6',
                                      child: TextFormField(
                                        controller: _lastNameCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Last Name',
                                          filled: true,
                                          fillColor: AppColors.surfaceGrey,
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (v) =>
                                            v!.isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimensions.space16),
                                TextFormField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email Address',
                                    filled: true,
                                    fillColor: AppColors.surfaceGrey,
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) {
                                    if (v!.isEmpty) return 'Required';
                                    if (!v.contains('@')) {
                                      return 'Invalid email';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.space24),
                            _buildSectionCard(
                              title: 'Account Settings',
                              children: [
                                TextFormField(
                                  controller: _passwordCtrl,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Temporary Password',
                                    filled: true,
                                    fillColor: AppColors.surfaceGrey,
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) =>
                                      v!.length < 6 ? 'Min 6 chars' : null,
                                ),
                                const SizedBox(height: AppDimensions.space16),
                                DropdownButtonFormField<UserRole>(
                                  value: _selectedRole,
                                  decoration: const InputDecoration(
                                    labelText: 'Role',
                                    filled: true,
                                    fillColor: AppColors.surfaceGrey,
                                    border: OutlineInputBorder(),
                                  ),
                                  items: UserRole.values.map((role) {
                                    return DropdownMenuItem(
                                      value: role,
                                      child: Text(role.name.toUpperCase()),
                                    );
                                  }).toList(),
                                  onChanged: (role) {
                                    if (role != null) {
                                      setState(() => _selectedRole = role);
                                    }
                                  },
                                ),
                                const SizedBox(height: AppDimensions.space16),
                                TextFormField(
                                  controller: _storeIdCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Assigned Store ID',
                                    filled: true,
                                    fillColor: AppColors.surfaceGrey,
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) {
                                    if (v!.isEmpty) return 'Required';
                                    if (int.tryParse(v) == null) {
                                      return 'Must be a number';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.space32),
                            MarcatButton(
                              label: 'Save Staff Member',
                              isLoading: _isLoading,
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.titleMedium),
            const SizedBox(height: AppDimensions.space24),
            ...children,
          ],
        ),
      ),
    );
  }
}
