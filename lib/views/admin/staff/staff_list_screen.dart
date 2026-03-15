// lib/views/admin/staff/staff_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_controller.dart';
import '../../../models/staff_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:marcat/core/router/app_router.dart';

class AdminStaffListScreen extends StatelessWidget {
  const AdminStaffListScreen({super.key});

  static String _getInitials(StaffModel staff) {
    return 'S';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title: const Text('Staff'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Staff Member',
            onPressed: () => Get.toNamed(AppRoutes.adminStaff),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchStaff(),
        color: AppColors.marcatGold,
        child: Obx(() {
          if (controller.isLoadingStaff.value && controller.staffList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.marcatGold),
            );
          }

          if (controller.staffList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.pagePaddingH),
                child: Text(
                  'No staff members found.\nTap + to add one.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
            itemCount: controller.staffList.length,
            itemBuilder: (context, index) {
              final staff = controller.staffList[index];

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
                    backgroundColor: AppColors.marcatGold.withOpacity(0.15),
                    foregroundColor: AppColors.marcatGold,
                    child: Text(
                      _getInitials(staff),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    'Staff ID: ${staff.id.substring(0, 8)}…',
                    style: AppTextStyles.titleMedium,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront,
                            size: AppDimensions.iconS,
                            color: AppColors.textSecondary),
                        const SizedBox(width: AppDimensions.space4),
                        Text(
                          staff.assignedStoreId != null
                              ? 'Store ${staff.assignedStoreId}'
                              : 'Unassigned',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  //  TODO   trailing: MarcatStatusBadge.custom(
                  //       label: staff.isActive ? 'ACTIVE' : 'INACTIVE',
                  //       color: staff.isActive
                  //           ? AppColors.statusGreen
                  //           : AppColors.statusAmber,
                  //     ),
                  onTap: () {
                    // TODO: navigate to staff detail / edit screen
                  },
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
