// lib/views/admin/staff/staff_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_controller.dart';
import '../../../models/staff_model.dart';
import '../../../models/enums.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:marcat/core/router/app_router.dart';

class AdminStaffListScreen extends StatelessWidget {
  const AdminStaffListScreen({super.key});

  static String _getInitials(StaffModel staff) {
    final first =
        staff.firstName.isNotEmpty ? staff.firstName[0].toUpperCase() : '';
    final last = (staff.lastName?.isNotEmpty ?? false)
        ? staff.lastName![0].toUpperCase()
        : '';
    final initials = '$first$last';
    return initials.isNotEmpty ? initials : 'ST';
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
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
            itemCount: controller.staffList.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.space8),
            itemBuilder: (_, index) {
              final staff = controller.staffList[index];
              return _StaffCard(
                staff: staff,
                initials: _getInitials(staff),
              );
            },
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.staff, required this.initials});

  final StaffModel staff;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.marcatNavy,
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          '${staff.firstName} ${staff.lastName ?? ''}',
          style: AppTextStyles.titleSmall,
        ),
        subtitle: Text(
          staff.role?.dbValue ?? 'Staff',
          style: AppTextStyles.bodySmall,
        ),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textDisabled),
        onTap: () {
          // TODO: navigate to staff detail / edit screen
        },
      ),
    );
  }
}
