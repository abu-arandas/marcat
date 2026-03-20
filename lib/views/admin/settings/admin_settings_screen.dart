// lib/views/admin/settings/admin_settings_screen.dart
//
// Admin settings panel — the last tab in AdminAppScaffold.
//
// Displays a live profile header (user-aware via Obx) followed by
// grouped settings sections. The "Change Password" item opens an
// inline bottom sheet with real validation instead of a no-op callback.
//
// All section items use a consistent [_SettingsTile] that applies the
// Marcat destructive-red style when [isDestructive] is true.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/user_model.dart';
import '../shared/admin_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminSettingsScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Settings & account management tab for admin and store-manager roles.
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Profile header ──────────────────────────────────────
                Obx(() {
                  final user = authCtrl.state.value.user;
                  return _ProfileHeader(user: user);
                }),

                const SizedBox(height: AppDimensions.space32),

                // ── Store Configuration ──────────────────────────────────
                const AdminSectionHeader(
                  eyebrow: 'Configuration',
                  title: 'Store Settings',
                ),
                const SizedBox(height: AppDimensions.space16),
                _SettingsGroup(
                  tiles: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'General Information',
                      subtitle: 'Store name, address, and contact details',
                      onTap: () => _comingSoon(context),
                    ),
                    _SettingsTile(
                      icon: Icons.request_quote_outlined,
                      title: 'Tax & Currency',
                      subtitle: 'Base currency, tax rates, and display formats',
                      onTap: () => _comingSoon(context),
                    ),
                    _SettingsTile(
                      icon: Icons.local_shipping_outlined,
                      title: 'Shipping Methods',
                      subtitle: 'Delivery rates and available carrier options',
                      onTap: () => _comingSoon(context),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.space32),

                // ── Notifications ────────────────────────────────────────
                const AdminSectionHeader(
                  eyebrow: 'Alerts',
                  title: 'Notifications',
                ),
                const SizedBox(height: AppDimensions.space16),
                _SettingsGroup(
                  tiles: [
                    _SettingsTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Order Alerts',
                      subtitle: 'Push notifications for new and updated orders',
                      onTap: () => _comingSoon(context),
                    ),
                    _SettingsTile(
                      icon: Icons.inventory_outlined,
                      title: 'Low Stock Alerts',
                      subtitle:
                          'Get notified when inventory drops below threshold',
                      onTap: () => _comingSoon(context),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.space32),

                // ── Account ──────────────────────────────────────────────
                const AdminSectionHeader(
                  eyebrow: 'Account',
                  title: 'Security',
                ),
                const SizedBox(height: AppDimensions.space16),
                _SettingsGroup(
                  tiles: [
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      subtitle: 'Update your admin account password',
                      onTap: () => _showChangePasswordSheet(context, authCtrl),
                    ),
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      title: 'Sign Out',
                      subtitle: 'Sign out of the admin panel',
                      onTap: () => _confirmSignOut(context, authCtrl),
                      isDestructive: true,
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.space64),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon — stay tuned!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static Future<void> _confirmSignOut(
    BuildContext context,
    AuthController authCtrl,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Sign Out', style: AppTextStyles.headlineSmall),
        content: Text(
          'Are you sure you want to sign out of the admin panel?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      authCtrl.signOut();
    }
  }

  static void _showChangePasswordSheet(
    BuildContext context,
    AuthController authCtrl,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ChangePasswordSheet(authCtrl: authCtrl),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProfileHeader
// ─────────────────────────────────────────────────────────────────────────────

/// User-aware profile card at the top of the settings screen.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.borderMedium,
                backgroundImage: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl!)
                    : null,
                child: user?.avatarUrl == null
                    ? Text(
                        user?.firstName.isNotEmpty == true
                            ? user!.firstName[0].toUpperCase()
                            : 'A',
                        style: AppTextStyles.titleLarge,
                      )
                    : null,
              ),
              const SizedBox(width: AppDimensions.space16),

              // Name + role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                      style: AppTextStyles.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.space4),
                    Text(
                      user?.role.dbValue.fromSlug ?? 'Admin',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    if (user?.email != null)
                      Text(
                        user!.email!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textDisabled),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Gold role indicator dot
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.marcatGold,
                ),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _SettingsGroup
// ─────────────────────────────────────────────────────────────────────────────

/// Card container that groups a list of [_SettingsTile]s.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.tiles});

  final List<_SettingsTile> tiles;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Column(
          children: tiles.asMap().entries.map((entry) {
            final isLast = entry.key == tiles.length - 1;
            return Column(
              children: [
                entry.value,
                if (!isLast)
                  const Divider(
                    height: 1,
                    indent: 56,
                    color: AppColors.borderLight,
                  ),
              ],
            );
          }).toList(),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _SettingsTile
// ─────────────────────────────────────────────────────────────────────────────

/// A single settings row with icon, title, subtitle, and optional chevron.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.errorRed : AppColors.marcatSlate,
          size: AppDimensions.iconL,
        ),
        title: Text(
          title,
          style: isDestructive
              ? AppTextStyles.labelMedium.copyWith(color: AppColors.errorRed)
              : AppTextStyles.labelMedium,
        ),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textDisabled,
          size: AppDimensions.iconM,
        ),
        onTap: onTap,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _ChangePasswordSheet
// ─────────────────────────────────────────────────────────────────────────────

/// Modal bottom sheet for changing the admin's password.
///
/// Calls [AuthController.updatePassword] which wraps the Supabase
/// `auth.updateUser` API.
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet({required this.authCtrl});

  final AuthController authCtrl;

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Supabase doesn't require current password for updateUser
      // when the user is already authenticated via session.
      await widget.authCtrl.updatePassword(_newCtrl.text);

      if (mounted) {
        Navigator.pop(context);
        Get.snackbar(
          'Password Changed',
          'Your password has been updated successfully.',
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
    return Padding(
      // Lift the sheet above the keyboard
      padding: EdgeInsets.only(
        left: AppDimensions.pagePaddingH,
        right: AppDimensions.pagePaddingH,
        top: AppDimensions.space24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppDimensions.space24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Change Password', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppDimensions.space4),
            Text(
              'Choose a strong password of at least 8 characters.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.space20),

            // Current password (kept as a UX confirmation step)
            _PasswordField(
              controller: _currentCtrl,
              label: 'Current Password',
              obscure: _obscureCurrent,
              onToggle: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppDimensions.space16),

            // New password
            _PasswordField(
              controller: _newCtrl,
              label: 'New Password',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.length < 8) {
                  return 'Must be at least 8 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.space16),

            // Confirm password
            _PasswordField(
              controller: _confirmCtrl,
              label: 'Confirm New Password',
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (v) =>
                  v != _newCtrl.text ? 'Passwords do not match.' : null,
            ),
            const SizedBox(height: AppDimensions.space24),

            // Submit
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.marcatNavy,
                foregroundColor: AppColors.textOnDark,
                minimumSize:
                    const Size.fromHeight(AppDimensions.buttonHeightPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
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
                      'Update Password',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.textOnDark),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PasswordField
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: AppDimensions.iconM,
            ),
            onPressed: onToggle,
          ),
        ),
        validator: validator,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Extension used in _ProfileHeader
// ─────────────────────────────────────────────────────────────────────────────

extension on String {
  /// Convert snake_case / db-value to a readable label.
  /// e.g. 'store_manager' → 'Store Manager'
  String get fromSlug => replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
