// lib/views/admin/settings/admin_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marcat/models/enums.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/user_model.dart';

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
                // ✅ Wrapped in Obx so header reacts to auth state changes
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
                  title: 'Account',
                  icon: Icons.manage_accounts_outlined,
                  items: [
                    _SettingsItem(
                      title: 'Change Password',
                      subtitle: 'Update your admin account password',
                      icon: Icons.lock_outline,
                      onTap: () {},
                    ),
                    _SettingsItem(
                      title: 'Sign Out',
                      subtitle: 'Sign out of the admin panel',
                      icon: Icons.logout,
                      onTap: () => authCtrl.signOut(),
                      isDestructive: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.borderMedium,
              backgroundImage: user?.avatarUrl != null
                  ? NetworkImage(user!.avatarUrl!)
                  : null,
              child: user?.avatarUrl == null
                  ? Text(
                      user?.firstName.substring(0, 1).toUpperCase() ?? 'A',
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
                    '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                    style: AppTextStyles.titleMedium,
                  ),
                  Text(
                    user?.role.dbValue ?? 'Admin',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(title.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: AppDimensions.space8),
        Card(
          child: Column(
            children: items.map((item) {
              final isLast = item == items.last;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      item.icon,
                      color: item.isDestructive
                          ? AppColors.errorRed
                          : AppColors.marcatSlate,
                    ),
                    title: Text(
                      item.title,
                      style: item.isDestructive
                          ? AppTextStyles.labelMedium
                              .copyWith(color: AppColors.errorRed)
                          : AppTextStyles.labelMedium,
                    ),
                    subtitle:
                        Text(item.subtitle, style: AppTextStyles.bodySmall),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textDisabled),
                    onTap: item.onTap,
                  ),
                  if (!isLast)
                    const Divider(
                        height: 1, indent: 56, color: AppColors.borderLight),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SettingsItem {
  const _SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
}
