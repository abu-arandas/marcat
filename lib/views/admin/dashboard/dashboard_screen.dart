// lib/presentation/admin/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import 'package:marcat/controllers/auth_controller.dart';
import '../../shared/widgets/marcat_app_bar.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: MarcatAppBar(
        title: context.l10n.adminDashboard,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const SizedBox(width: AppDimensions.space8),
          Obx(() {
            final user = authController.state.value.user;
            return CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.borderMedium,
              backgroundImage: user?.avatarUrl != null
                  ? NetworkImage(user!.avatarUrl!)
                  : null,
              child: user?.avatarUrl == null
                  ? Text(user?.firstName.substring(0, 1).toUpperCase() ?? 'A',
                      style: AppTextStyles.labelMedium)
                  : null,
            );
          }),
          const SizedBox(width: AppDimensions.space16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              final user = authController.state.value.user;
              return Text(
                'Welcome back, ${user?.firstName ?? 'Admin'}',
                style: AppTextStyles.headlineMedium,
              );
            }),
            const SizedBox(height: AppDimensions.space24),

            // Stats Grid
            LayoutBuilder(builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 800
                  ? 4
                  : constraints.maxWidth > 500
                      ? 2
                      : 1;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppDimensions.space16,
                mainAxisSpacing: AppDimensions.space16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.5,
                children: [
                  _StatCard(
                      title: "Today's Sales",
                      value: 'JOD 1,420.50',
                      icon: Icons.attach_money,
                      color: AppColors.statusGreen),
                  _StatCard(
                      title: "Pending Orders",
                      value: '24',
                      icon: Icons.pending_actions,
                      color: AppColors.statusAmber),
                  _StatCard(
                      title: "Low Stock Items",
                      value: '12',
                      icon: Icons.warning_amber,
                      color: AppColors.statusRed),
                  _StatCard(
                      title: "Active Users",
                      value: '450',
                      icon: Icons.people_outline,
                      color: AppColors.statusBlue),
                ],
              );
            }),

            const SizedBox(height: AppDimensions.space32),

            // Recent Orders / Actions
            Container(
              padding: const EdgeInsets.all(AppDimensions.space24),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Orders', style: AppTextStyles.titleMedium),
                      TextButton(
                          onPressed: () {}, child: const Text('View All')),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  Center(
                      child: Text('No recent orders to display.',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        boxShadow: [
          BoxShadow(
            color: AppColors.marcatBlack.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: AppDimensions.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppDimensions.space4),
                Text(value, style: AppTextStyles.titleLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
