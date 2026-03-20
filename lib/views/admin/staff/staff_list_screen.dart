// lib/views/admin/staff/staff_list_screen.dart
//
// Paginated list of all staff members with role chips and active/inactive
// status indicators. Supports pull-to-refresh.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../models/enums.dart';
import '../../../models/staff_model.dart';
import '../shared/admin_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminStaffListScreen
// ─────────────────────────────────────────────────────────────────────────────

/// All staff members in a searchable card list.
///
/// Displays each member's initials avatar, name, role chip, assigned store,
/// and active/inactive status dot.
class AdminStaffListScreen extends StatelessWidget {
  const AdminStaffListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title: const Text('Staff'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Add Staff Member',
            onPressed: () => Get.toNamed(AppRoutes.adminStaff),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ctrl.fetchStaff(),
        color: AppColors.marcatGold,
        child: Obx(() {
          // ── Loading ─────────────────────────────────────────────────────
          if (ctrl.isLoadingStaff.value && ctrl.staffList.isEmpty) {
            return const AdminListSkeleton();
          }

          // ── Empty ───────────────────────────────────────────────────────
          if (ctrl.staffList.isEmpty) {
            return AdminEmptyState(
              icon: Icons.group_outlined,
              title: 'No Staff Members',
              subtitle: 'Add your first team member to get started.',
              actionLabel: 'Add Staff',
              onAction: () => Get.toNamed(AppRoutes.adminStaff),
            );
          }

          // ── List ────────────────────────────────────────────────────────
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pagePaddingH,
              AppDimensions.pagePaddingH,
              AppDimensions.pagePaddingH,
              AppDimensions.space64,
            ),
            itemCount: ctrl.staffList.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.space8),
            itemBuilder: (_, i) => _StaffCard(staff: ctrl.staffList[i]),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StaffCard
// ─────────────────────────────────────────────────────────────────────────────

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.staff});

  final StaffModel staff;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          onTap: () {
            // Navigate to staff detail / edit screen when implemented.
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Row(
              children: [
                // ── Avatar ───────────────────────────────────────────────
                _StaffAvatar(staff: staff),
                const SizedBox(width: AppDimensions.space12),

                // ── Info ─────────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${staff.firstName} ${staff.lastName ?? ''}',
                        style: AppTextStyles.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.space4),
                      Row(
                        children: [
                          _RoleChip(role: staff.role),
                          if (staff.assignedStoreId != null) ...[
                            const SizedBox(width: AppDimensions.space8),
                            Text(
                              'Store #${staff.assignedStoreId}',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Active indicator ─────────────────────────────────────
                _ActiveDot(isActive: staff.isActive),

                const SizedBox(width: AppDimensions.space4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textDisabled,
                  size: AppDimensions.iconM,
                ),
              ],
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _StaffAvatar
// ─────────────────────────────────────────────────────────────────────────────

class _StaffAvatar extends StatelessWidget {
  const _StaffAvatar({required this.staff});

  final StaffModel staff;

  String get _initials {
    final first =
        staff.firstName.isNotEmpty ? staff.firstName[0].toUpperCase() : '';
    final last = (staff.lastName?.isNotEmpty ?? false)
        ? staff.lastName![0].toUpperCase()
        : '';
    final combined = '$first$last';
    return combined.isNotEmpty ? combined : 'ST';
  }

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.marcatNavy,
        child: Text(
          _initials,
          style: AppTextStyles.titleSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _RoleChip
// ─────────────────────────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  const _RoleChip({this.role});

  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    final label = _label(role);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.loyaltyBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.marcatNavy,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static String _label(UserRole? role) => switch (role) {
        UserRole.admin => 'Admin',
        UserRole.storeManager => 'Manager',
        UserRole.salesperson => 'Salesperson',
        UserRole.driver => 'Driver',
        _ => 'Staff',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// _ActiveDot
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveDot extends StatelessWidget {
  const _ActiveDot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? AppColors.statusGreen : AppColors.textDisabled,
        ),
      );
}
