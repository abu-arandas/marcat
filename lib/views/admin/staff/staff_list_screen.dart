// lib/views/admin/staff/staff_list_screen.dart
//
// Paginated list of all staff members with role chips and active/inactive
// status indicators.
//
// ✅ REFACTORED: uses brand.dart color aliases.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_controller.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../models/enums.dart';
import '../../../models/staff_model.dart';
import '../shared/admin_widgets.dart';
import '../shared/brand.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminStaffListScreen
// ─────────────────────────────────────────────────────────────────────────────

class AdminStaffListScreen extends StatelessWidget {
  const AdminStaffListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: kSurface,
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
        color: kGold,
        child: Obx(() {
          if (ctrl.isLoadingStaff.value && ctrl.staffList.isEmpty) {
            return const AdminListSkeleton();
          }

          if (ctrl.staffList.isEmpty) {
            return AdminEmptyState(
              icon: Icons.group_outlined,
              title: 'No Staff Members',
              subtitle: 'Add your first team member to get started.',
              actionLabel: 'Add Staff',
              onAction: () => Get.toNamed(AppRoutes.adminStaff),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
            itemCount: ctrl.staffList.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.space12),
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

  String get _initials {
    final f =
        staff.firstName.isNotEmpty ? staff.firstName[0].toUpperCase() : '';
    final l = (staff.lastName ?? '').isNotEmpty
        ? (staff.lastName ?? '')[0].toUpperCase()
        : '';
    return '$f$l'.isNotEmpty ? '$f$l' : '?';
  }

  String get _roleLabel => switch (staff.role) {
        UserRole.salesperson => 'Salesperson',
        UserRole.storeManager => 'Store Manager',
        UserRole.driver => 'Driver',
        UserRole.admin => 'Admin',
        _ => staff.role?.dbValue ?? 'Unknown',
      };

  Color get _roleColor => switch (staff.role) {
        UserRole.admin => kRed,
        UserRole.storeManager => kBlue,
        UserRole.salesperson => kGold,
        UserRole.driver => kAmber,
        _ => kSlate,
      };

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: Row(
            children: [
              // ── Avatar ──────────────────────────────────────────────────
              CircleAvatar(
                radius: 22,
                backgroundColor: kGold.withAlpha(38),
                child: Text(
                  _initials,
                  style: AppTextStyles.titleSmall.copyWith(color: kNavy),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),

              // ── Name + role ─────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${staff.firstName} ${staff.lastName}',
                      style: AppTextStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.space8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _roleColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusPill,
                            ),
                          ),
                          child: Text(
                            _roleLabel,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _roleColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Active indicator ────────────────────────────────────────
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: staff.isActive ? kGreen : kTextDisabled,
                ),
              ),
            ],
          ),
        ),
      );
}
