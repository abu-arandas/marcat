// lib/views/admin/settings/admin_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marcat/models/enums.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/user_model.dart';
import 'package:marcat/core/router/app_router.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title: const Text('Admin Settings'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // FIX: wrapped in Obx so the header reacts to auth state changes
                // (e.g. avatar upload, name update, sign-out).
                Obx(() {
                  final user = authCtrl.state.value.user;
                  return _buildProfileHeader(user);
                }),

                const SizedBox(height: AppDimensions.space24),

                _buildSettingsSection(
                  title: 'Store Configuration',
                  icon: Icons.storefront,
                  items: [
                    _SettingsItem(
                      title: 'General Information',
                      subtitle: 'Store name, address, and contact details',
                      icon: Icons.info_outline,
                      onTap: () {},
                    ),
                    _SettingsItem(
                      title: 'Tax & Currency',
                      subtitle: 'Base currency, tax rates, and display formats',
                      icon: Icons.request_quote_outlined,
                      onTap: () {},
                    ),
                    _SettingsItem(
                      title: 'Shipping Methods',
                      subtitle: 'Delivery rates and available options',
                      icon: Icons.local_shipping_outlined,
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.space24),

                _buildSettingsSection(
                  title: 'System Settings',
                  icon: Icons.settings_applications,
                  items: [
                    _SettingsItem(
                      title: 'Notifications',
                      subtitle: 'Email and push notification preferences',
                      icon: Icons.notifications_none,
                      onTap: () {},
                    ),
                    _SettingsItem(
                      title: 'Language',
                      subtitle: 'App display language',
                      icon: Icons.language,
                      onTap: () {},
                    ),
                    _SettingsItem(
                      title: 'Security',
                      subtitle: 'Password, two-factor authentication',
                      icon: Icons.security_outlined,
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.space24),

                _buildSettingsSection(
                  title: 'Account',
                  icon: Icons.manage_accounts_outlined,
                  items: [
                    _SettingsItem(
                      title: 'Edit Profile',
                      subtitle: 'Update your name, avatar, and contact info',
                      icon: Icons.person_outline,
                      onTap: () => Get.toNamed(AppRoutes.profile),
                    ),
                    _SettingsItem(
                      title: 'Sign Out',
                      subtitle: 'Sign out of your admin account',
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.statusRed,
                      onTap: () => Get.find<AuthController>().signOut(),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.space32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Profile header
  // FIX: parameter changed from supabase_flutter.User? to UserModel?
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildProfileHeader(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.borderMedium,
            backgroundImage:
                user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
            child: user?.avatarUrl == null
                ? Text(
                    user?.firstName.isNotEmpty == true
                        ? user!.firstName[0].toUpperCase()
                        : 'A',
                    style: AppTextStyles.headlineMedium,
                  )
                : null,
          ),
          const SizedBox(width: AppDimensions.space16),

          // Name & role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'Admin',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.role.dbValue.replaceAll('_', ' ').toUpperCase() ??
                      'ADMIN',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Settings section builder
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<_SettingsItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.space16,
              AppDimensions.space16,
              AppDimensions.space16,
              AppDimensions.space8,
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppDimensions.space8),
                Text(title, style: AppTextStyles.titleSmall),
              ],
            ),
          ),
          const Divider(height: 1),

          // Items
          ...items.map((item) => _SettingsTile(item: item)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SettingsItem  — data class
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsItem {
  const _SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// _SettingsTile  — list tile widget
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.item});

  final _SettingsItem item;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(
          item.icon,
          size: 20,
          color: item.iconColor ?? AppColors.textSecondary,
        ),
        title: Text(item.title, style: AppTextStyles.bodyMedium),
        subtitle: Text(item.subtitle, style: AppTextStyles.bodySmall),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: AppColors.textSecondary,
        ),
        onTap: item.onTap,
      );
}
