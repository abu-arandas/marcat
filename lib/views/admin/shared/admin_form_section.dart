// lib/views/admin/shared/admin_form_section.dart
//
// Shared form section card widget used by both product_form_screen
// and staff_form_screen. Previously duplicated as _FormSection in
// each file — now extracted to a single source of truth.

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminFormSection
// ─────────────────────────────────────────────────────────────────────────────

/// Card-style section container for admin forms.
///
/// Displays an icon + title header, a divider, then the [children] list.
/// Consistent across all admin create/edit forms.
class AdminFormSection extends StatelessWidget {
  const AdminFormSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppDimensions.space20),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: AppDimensions.iconS,
                  color: AppColors.marcatGold,
                ),
                const SizedBox(width: AppDimensions.space8),
                Text(title, style: AppTextStyles.titleSmall),
              ],
            ),
            const Padding(
              padding:
                  EdgeInsets.symmetric(vertical: AppDimensions.space12),
              child: Divider(height: 1, color: AppColors.borderLight),
            ),
            ...children,
          ],
        ),
      );
}
