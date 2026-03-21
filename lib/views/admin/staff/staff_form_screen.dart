// lib/views/admin/staff/staff_form_screen.dart
//
// Create a new staff member via the `create-staff` Supabase Edge Function.
//
// ✅ REFACTORED: uses AdminFormSection (deduplicated from _FormSection).
// ✅ REFACTORED: uses brand.dart color aliases.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/enums.dart';
import '../shared/admin_form_section.dart';
import '../shared/brand.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StaffFormScreen
// ─────────────────────────────────────────────────────────────────────────────

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

  UserRole _selectedRole = UserRole.salesperson;
  int? _selectedStoreId;
  bool _isLoading = false;
  bool _obscurePassword = true;

  AdminController get _adminCtrl => Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    if (_adminCtrl.stores.isEmpty) _adminCtrl.fetchStores();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedStoreId == null) {
      Get.snackbar(
        'Missing Store',
        'Please select a store.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.statusAmberLight,
        colorText: kAmber,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _adminCtrl.createStaffMember(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: _selectedRole,
        storeId: _selectedStoreId!,
      );
      if (mounted) {
        Get.snackbar(
          'Success',
          'Staff member created successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.successGreenLight,
          colorText: kGreen,
        );
        Get.back();
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          e.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.statusRedLight,
          colorText: kRed,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: const Text('New Staff Member'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Personal info ─────────────────────────────────────
                  // ✅ Uses shared AdminFormSection instead of _FormSection
                  AdminFormSection(
                    title: 'Personal Information',
                    icon: Icons.person_outline_rounded,
                    children: [
                      TextFormField(
                        controller: _firstNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'First Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline,
                              size: AppDimensions.iconM),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'First name is required.'
                            : null,
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      TextFormField(
                        controller: _lastNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Last Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline,
                              size: AppDimensions.iconM),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Last name is required.'
                            : null,
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined,
                              size: AppDimensions.iconM),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required.';
                          }
                          if (!v.contains('@')) return 'Enter a valid email.';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outlined,
                              size: AppDimensions.iconM),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: AppDimensions.iconM,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
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
                      if (_passwordCtrl.text.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.space8),
                        _PasswordStrengthMeter(password: _passwordCtrl.text),
                      ],
                    ],
                  ),

                  const SizedBox(height: AppDimensions.space24),

                  // ── Role & Store ──────────────────────────────────────
                  AdminFormSection(
                    title: 'Role & Assignment',
                    icon: Icons.badge_outlined,
                    children: [
                      Text(
                        'Role',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: kTextSecondary),
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      _RoleSelector(
                        selected: _selectedRole,
                        onChanged: (r) => setState(() => _selectedRole = r),
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      Obx(() {
                        final stores = _adminCtrl.stores;
                        final isLoadingStores =
                            _adminCtrl.isLoadingStores.value;

                        if (isLoadingStores && stores.isEmpty) {
                          return const _StoreLoadingShimmer();
                        }

                        if (stores.isEmpty) {
                          return _StoreEmptyWarning(
                            onRetry: _adminCtrl.fetchStores,
                          );
                        }

                        return DropdownButtonFormField<int>(
                          value: _selectedStoreId,
                          decoration: const InputDecoration(
                            labelText: 'Assigned Store *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.storefront_outlined,
                                size: AppDimensions.iconM),
                          ),
                          hint: const Text('Select a store'),
                          items: stores
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Text(
                                    s.name +
                                        (s.location != null
                                            ? ' — ${s.location}'
                                            : ''),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedStoreId = v),
                          validator: (_) => _selectedStoreId == null
                              ? 'Please select a store.'
                              : null,
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.space32),

                  // ── Submit ─────────────────────────────────────────────
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: kNavy,
                      foregroundColor: kTextOnDark,
                      minimumSize: const Size.fromHeight(
                        AppDimensions.buttonHeightPrimary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusS),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Create Staff Member',
                            style: AppTextStyles.labelLarge
                                .copyWith(color: kTextOnDark),
                          ),
                  ),

                  const SizedBox(height: AppDimensions.space64),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RoleSelector
// ─────────────────────────────────────────────────────────────────────────────

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.selected,
    required this.onChanged,
  });

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  static const _roles = [
    UserRole.salesperson,
    UserRole.storeManager,
    UserRole.driver,
  ];

  String _label(UserRole r) => switch (r) {
        UserRole.salesperson => 'Salesperson',
        UserRole.storeManager => 'Manager',
        UserRole.driver => 'Driver',
        _ => r.dbValue,
      };

  @override
  Widget build(BuildContext context) => SegmentedButton<UserRole>(
        segments: _roles
            .map(
              (r) => ButtonSegment<UserRole>(
                value: r,
                label: Text(_label(r)),
              ),
            )
            .toList(),
        selected: {selected},
        onSelectionChanged: (s) => onChanged(s.first),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return kGold.withAlpha(38);
            }
            return kSurfaceWhite;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return kNavy;
            return kTextSecondary;
          }),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _PasswordStrengthMeter
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({required this.password});

  final String password;

  double get _strength {
    if (password.isEmpty) return 0;
    double s = 0;
    if (password.length >= 8) s += 0.25;
    if (password.length >= 12) s += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(password)) s += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) s += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) s += 0.2;
    return s.clamp(0, 1);
  }

  Color get _color => _strength < 0.4
      ? kRed
      : _strength < 0.7
          ? kAmber
          : kGreen;

  String get _label => _strength < 0.4
      ? 'Weak'
      : _strength < 0.7
          ? 'Fair'
          : 'Strong';

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: _strength,
              backgroundColor: kBorder,
              color: _color,
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _label,
            style: AppTextStyles.labelSmall.copyWith(color: _color),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _StoreLoadingShimmer
// ─────────────────────────────────────────────────────────────────────────────

class _StoreLoadingShimmer extends StatelessWidget {
  const _StoreLoadingShimmer();

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: kGold,
              strokeWidth: 2,
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _StoreEmptyWarning
// ─────────────────────────────────────────────────────────────────────────────

class _StoreEmptyWarning extends StatelessWidget {
  const _StoreEmptyWarning({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppDimensions.space12),
        decoration: BoxDecoration(
          color: AppColors.statusAmberLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: AppDimensions.iconM, color: kAmber),
            const SizedBox(width: AppDimensions.space8),
            const Expanded(
              child: Text('No stores found. Add a store first.'),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
}
