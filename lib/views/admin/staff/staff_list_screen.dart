// lib/presentation/admin/staff/staff_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../shared/widgets/marcat_app_bar.dart';
import '../../shared/widgets/marcat_badge.dart';
import 'package:marcat/core/router/app_router.dart';

class AdminStaffListScreen extends StatelessWidget {
  const AdminStaffListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usually injected, but we'll instantiate it here for the screen scope
    final controller = Get.put(AdminController());

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: MarcatAppBar(
        title: 'Admin Staff',
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Staff',
            onPressed: () => Get.toNamed(AppRoutes.adminStaff),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchStaff(),
        color: AppColors.marcatGold,
        child: Obx(
          () {
            return ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
// null check removed because staffList is guaranteed non-null in this scope.
              itemCount: controller.staffList.length,
              itemBuilder: (context, index) {
                final staff = controller.staffList[index];

                // Helper to get initials
                String getInitials() {
                  // In a real app we'd fetch profile data. Since StaffModel just holds the ID right now,
                  // we'll display a placeholder based on role.
                  return "S";
                }

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: AppDimensions.space12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    side: const BorderSide(color: AppColors.borderLight),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(AppDimensions.space12),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.marcatGold.withOpacity(0.2),
                      foregroundColor: AppColors.marcatGold,
                      child: Text(
                        getInitials(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      'Staff ID: ${staff.id.substring(0, 8)}...',
                      style: AppTextStyles.titleMedium,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.storefront,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Store: ${staff.assignedStoreId ?? "Unassigned"}',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MarcatStatusBadge.custom(
                          label: staff.isActive ? "ACTIVE" : "INACTIVE",
                          color: staff.isActive
                              ? AppColors.statusGreen
                              : AppColors.statusRed,
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textDisabled),
                      ],
                    ),
                    onTap: () {
                      // Navigate to staff details when implemented
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
