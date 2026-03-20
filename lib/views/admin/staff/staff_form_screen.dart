// lib/views/admin/staff/staff_form_screen.dart
//
// Create a new staff member via the `create-staff` Supabase Edge Function.
//
// Key improvements over the original:
//  • Store is picked from a [DropdownButtonFormField] populated by
//    [AdminController.stores] — no more raw numeric text input.
//  • Password field shows a live strength meter.
//  • Role picker excludes customer + admin (only assignable roles).
//  • Full [_FormSection] card layout matches product_form_screen.
//  • All controllers disposed; mounted checks before every setState.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/enums.dart';
import '../shared/admin_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StaffFormScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Form to create a new staff member.
///
/// Accessible via [AppRoutes.adminStaff].
class StaffFormScreen extends StatefulWidget {
  const StaffFormScreen({super.key});

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────
  UserRole _selectedRole = UserRole.salesperson;
  int? _selectedStoreId;
  bool _isLoading = false;
  bool _obscurePassword = true;

  AdminController get _adminCtrl => Get.find<AdminController>();

  /// Roles that can be assigned when creating a staff member.
  static const _assignableRoles = [
    UserRole.salesperson,
    UserRole.storeManager,
    UserRole.driver,
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Ensure stores are loaded — they're fetched in AdminController.onInit()
    // but may still be loading on first navigation to this screen.
    if (_adminCtrl.stores.isEmpty) {
      _adminCtrl.fetchStores();
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStoreId == null) {
      Get.snackbar(
        'Store Required',
        'Please select the store this staff member belongs to.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.statusAmberLight,
        colorText: AppColors.statusAmber,
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
        storeId: _selectedStoreId!,
      );

      if (mounted) {
        Get.back();
        Get.snackbar(
          'Staff Member Created',
          '${_firstNameCtrl.text.trim()} has been added successfully.',
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

  // ── Build ─────────────────────────────────────────────────────────────────

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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Personal Information ───────────────────────────────
                  _FormSection(
                    title: 'Personal Information',
                    icon: Icons.person_outline_rounded,
                    children: [
                      // First + Last name row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'First Name *',
                                border: OutlineInputBorder(),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space16),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Last Name *',
                                border: OutlineInputBorder(),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.space24),

                  // ── Account Credentials ────────────────────────────────
                  _FormSection(
                    title: 'Account Credentials',
                    icon: Icons.lock_outline_rounded,
                    children: [
                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email Address *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined,
                              size: AppDimensions.iconM),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required.';
                          }
                          if (!RegExp(
                                  r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
                              .hasMatch(v.trim())) {
                            return 'Enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.space16),

                      // Password + strength meter
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Temporary Password *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.vpn_key_outlined,
                              size: AppDimensions.iconM),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: AppDimensions.iconM,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          helperText:
                              'The staff member should change this on first login.',
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

                      // Password strength meter
                      if (_passwordCtrl.text.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.space8),
                        _PasswordStrengthMeter(password: _passwordCtrl.text),
                      ],
                    ],
                  ),

                  const SizedBox(height: AppDimensions.space24),

                  // ── Role & Store ───────────────────────────────────────
                  _FormSection(
                    title: 'Role & Assignment',
                    icon: Icons.badge_outlined,
                    children: [
                      // Role segmented button
                      Text(
                        'Role',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      _RoleSelector(
                        selected: _selectedRole,
                        onChanged: (r) => setState(() => _selectedRole = r),
                      ),

                      const SizedBox(height: AppDimensions.space16),

                      // Store dropdown — populated from controller
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
                                            ? ' · ${s.location}'
                                            : ''),
                                    overflow: TextOverflow.ellipsis,
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
                      backgroundColor: AppColors.marcatNavy,
                      foregroundColor: AppColors.textOnDark,
                      minimumSize: const Size.fromHeight(
                          AppDimensions.buttonHeightPrimary),
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
                                .copyWith(color: AppColors.textOnDark),
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
// _FormSection  (matches product_form_screen layout)
// ─────────────────────────────────────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppDimensions.space20),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: AppDimensions.iconS, color: AppColors.marcatGold),
                const SizedBox(width: AppDimensions.space8),
                Text(title, style: AppTextStyles.titleSmall),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimensions.space12),
              child: Divider(height: 1, color: AppColors.borderLight),
            ),
            ...children,
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _RoleSelector
// ─────────────────────────────────────────────────────────────────────────────

/// Segmented button for choosing salesperson / manager / driver.
class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.selected, required this.onChanged});

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  static String _label(UserRole r) => switch (r) {
        UserRole.salesperson => 'Salesperson',
        UserRole.storeManager => 'Manager',
        UserRole.driver => 'Driver',
        _ => r.dbValue,
      };

  static IconData _icon(UserRole r) => switch (r) {
        UserRole.salesperson => Icons.point_of_sale_rounded,
        UserRole.storeManager => Icons.manage_accounts_rounded,
        UserRole.driver => Icons.delivery_dining_rounded,
        _ => Icons.person_rounded,
      };

  @override
  Widget build(BuildContext context) {
    const roles = [
      UserRole.salesperson,
      UserRole.storeManager,
      UserRole.driver,
    ];

    return SegmentedButton<UserRole>(
      segments: roles
          .map(
            (r) => ButtonSegment(
              value: r,
              icon: Icon(_icon(r), size: 16),
              label: Text(_label(r)),
            ),
          )
          .toList(),
      selected: {selected},
      onSelectionChanged: (Set<UserRole> s) => onChanged(s.first),
      style: ButtonStyle(
        side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.borderMedium)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PasswordStrengthMeter
// ─────────────────────────────────────────────────────────────────────────────

/// Live password strength bar shown below the password field.
class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({required this.password});

  final String password;

  /// Returns 0–4 strength score.
  static int _score(String p) {
    int s = 0;
    if (p.length >= 8) s++;
    if (p.length >= 12) s++;
    if (RegExp(r'[A-Z]').hasMatch(p)) s++;
    if (RegExp(r'[0-9]').hasMatch(p)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s.clamp(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    final score = _score(password);
    const labels = ['Very Weak', 'Weak', 'Fair', 'Strong', 'Very Strong'];
    const colors = [
      AppColors.statusRed,
      AppColors.statusRed,
      AppColors.statusAmber,
      AppColors.statusGreen,
      AppColors.statusGreen,
    ];

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            child: LinearProgressIndicator(
              value: (score + 1) / 5,
              backgroundColor: AppColors.surfaceGrey,
              color: colors[score],
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        Text(
          labels[score],
          style: AppTextStyles.labelSmall.copyWith(
            color: colors[score],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StoreLoadingShimmer  /  _StoreEmptyWarning
// ─────────────────────────────────────────────────────────────────────────────

class _StoreLoadingShimmer extends StatelessWidget {
  const _StoreLoadingShimmer();

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: AppColors.marcatGold,
              strokeWidth: 2,
            ),
          ),
        ),
      );
}

class _StoreEmptyWarning extends StatelessWidget {
  const _StoreEmptyWarning({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppDimensions.space12),
        decoration: BoxDecoration(
          color: AppColors.statusAmberLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(color: AppColors.statusAmber),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.statusAmber,
              size: AppDimensions.iconM,
            ),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: Text(
                'No stores found. Tap retry to reload.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.statusAmber),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(color: AppColors.statusAmber),
              ),
            ),
          ],
        ),
      );
}
