// lib/presentation/admin/settings/admin_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../shared/widgets/marcat_app_bar.dart';
import 'package:marcat/core/router/app_router.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: MarcatAppBar(
        title: "Admin Settings",
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
                _buildProfileHeader(user),
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
                      trailing:
                          Text('English', style: AppTextStyles.labelLarge),
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space24),
                _buildSettingsSection(
                  title: 'Account Actions',
                  icon: Icons.account_circle,
                  items: [
                    _SettingsItem(
                      title: 'Change Password',
                      subtitle: 'Update your admin account password',
                      icon: Icons.lock_outline,
                      onTap: () {},
                    ),
                    _SettingsItem(
                      title: 'Sign Out',
                      subtitle: 'End your current session safely',
                      icon: Icons.logout,
                      iconColor: AppColors.statusRed,
                      textColor: AppColors.statusRed,
                      onTap: () {
                        // Implement sign out using existing auth mechanism
                        Supabase.instance.client.auth.signOut();
                        Get.offAllNamed(AppRoutes.login);
                      },
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

  Widget _buildProfileHeader(User? user) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.marcatGold.withOpacity(0.2),
              child: const Icon(Icons.manage_accounts,
                  size: 40, color: AppColors.marcatGold),
            ),
            const SizedBox(width: AppDimensions.space24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Administrator', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        user?.email ?? 'Unknown Email',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
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
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.marcatGold),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.titleMedium),
            ],
          ),
        ),
        Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Icon(item.icon,
                    color: item.iconColor ?? AppColors.textPrimary),
                title: Text(
                  item.title,
                  style:
                      AppTextStyles.bodyLarge.copyWith(color: item.textColor),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                trailing: item.trailing ??
                    const Icon(Icons.chevron_right,
                        color: AppColors.textDisabled),
                onTap: item.onTap,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space16,
                  vertical: AppDimensions.space8,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  _SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });
}
