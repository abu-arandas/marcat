// lib/views/admin/settings/admin_settings_screen.dart
//
// Admin settings panel — the last tab in AdminAppScaffold.
//
// ✅ REFACTORED: uses brand.dart color aliases exclusively.
// ✅ REFACTORED: removed local kGreenLight hack — now in brand.dart.
// ✅ REFACTORED: sign-out shows confirmation dialog.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marcat/core/extensions/string_extensions.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/enums.dart';
import '../../../models/user_model.dart';
import '../shared/admin_widgets.dart';
import '../shared/brand.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminSettingsScreen
// ─────────────────────────────────────────────────────────────────────────────

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: kSurface,
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

                // ── Store Configuration ─────────────────────────────────
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

                // ── Account ─────────────────────────────────────────────
                const AdminSectionHeader(
                  eyebrow: 'Security',
                  title: 'Account',
                ),
                const SizedBox(height: AppDimensions.space16),
                _SettingsGroup(
                  tiles: [
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      subtitle: 'Update your admin account password',
                      onTap: () => _showChangePasswordSheet(context),
                    ),
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      title: 'Sign Out',
                      subtitle: 'End your current session',
                      isDestructive: true,
                      onTap: () => _confirmSignOut(context, authCtrl),
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
    Get.snackbar(
      'Coming Soon',
      'This feature is under development.',
      snackPosition: SnackPosition.TOP,
    );
  }

  static void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  static Future<void> _confirmSignOut(
    BuildContext context,
    AuthController authCtrl,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of the admin panel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: kRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true) authCtrl.signOut();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProfileHeader
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppDimensions.space20),
        decoration: BoxDecoration(
          color: kSurfaceWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: kGold.withAlpha(38),
              backgroundImage: user?.avatarUrl != null
                  ? NetworkImage(user!.avatarUrl!)
                  : null,
              child: user?.avatarUrl == null
                  ? Text(
                      user != null && user!.firstName.isNotEmpty
                          ? user!.firstName[0].toUpperCase()
                          : 'A',
                      style: AppTextStyles.titleLarge,
                    )
                  : null,
            ),
            const SizedBox(width: AppDimensions.space16),
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
                    style:
                        AppTextStyles.bodySmall.copyWith(color: kTextSecondary),
                  ),
                  if (user?.fullName != null)
                    Text(
                      user!.fullName,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: kTextDisabled),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kGold,
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _SettingsGroup
// ─────────────────────────────────────────────────────────────────────────────

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
                  const Divider(height: 1, indent: 56, color: kBorder),
              ],
            );
          }).toList(),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _SettingsTile
// ─────────────────────────────────────────────────────────────────────────────

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
          color: isDestructive ? kRed : kSlate,
          size: AppDimensions.iconL,
        ),
        title: Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(
            color: isDestructive ? kRed : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: kTextSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDestructive ? kRed.withAlpha(128) : kTextDisabled,
        ),
        onTap: onTap,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _ChangePasswordSheet
// ─────────────────────────────────────────────────────────────────────────────

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      await Get.find<AuthController>().updatePassword(_newPwCtrl.text);
      if (mounted) {
        Navigator.of(context).pop();
        Get.snackbar(
          'Success',
          'Password updated.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: kGreenLight,
          colorText: kGreen,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          e.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: kRed.withAlpha(26),
          colorText: kRed,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppDimensions.pagePaddingH,
          right: AppDimensions.pagePaddingH,
          top: AppDimensions.space16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Change Password', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppDimensions.space20),
              TextFormField(
                controller: _newPwCtrl,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required.';
                  if (v.length < 8) return 'At least 8 characters.';
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.space16),
              TextFormField(
                controller: _confirmPwCtrl,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v != _newPwCtrl.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.space24),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Update Password'),
              ),
              const SizedBox(height: AppDimensions.space24),
            ],
          ),
        ),
      );
}
