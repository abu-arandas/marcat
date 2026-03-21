// lib/views/admin/shared/admin_widgets.dart
//
// Shared UI primitives for every admin screen.
//
// Mirrors the quality & consistency of the customer-side shared widgets
// (empty_state.dart, section_header.dart, brand.dart) but styled for
// the admin panel's darker, more data-dense aesthetic.
//
// ✅ REFACTORED: uses brand.dart color aliases exclusively — zero raw
//    AppColors references in this file.

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/enums.dart';
import 'brand.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminEmptyState
// ─────────────────────────────────────────────────────────────────────────────

/// Consistent empty / not-found placeholder used across all admin list screens.
class AdminEmptyState extends StatelessWidget {
  const AdminEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical: AppDimensions.space64,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container — matches customer EmptyState style
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: kSurfaceWhite,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: kBorder),
                ),
                child: Icon(icon, size: AppDimensions.iconXXL, color: kSlate),
              ),
              const SizedBox(height: AppDimensions.space24),

              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSmall,
              ),

              if (subtitle != null) ...[
                const SizedBox(height: AppDimensions.space8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style:
                      AppTextStyles.bodyMedium.copyWith(color: kTextSecondary),
                ),
              ],

              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppDimensions.space24),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(actionLabel!),
                  style: FilledButton.styleFrom(
                    backgroundColor: kNavy,
                    foregroundColor: kTextOnDark,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space24,
                      vertical: AppDimensions.space12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusS),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AdminErrorRetry
// ─────────────────────────────────────────────────────────────────────────────

/// Full-page error display with a retry action button.
class AdminErrorRetry extends StatelessWidget {
  const AdminErrorRetry({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: kRed,
                size: AppDimensions.iconXXL,
              ),
              const SizedBox(height: AppDimensions.space16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: kTextSecondary),
              ),
              const SizedBox(height: AppDimensions.space24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kNavy,
                  side: const BorderSide(color: kBorderMedium),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AdminListSkeleton
// ─────────────────────────────────────────────────────────────────────────────

/// Shimmer loading skeleton for list-based admin screens.
class AdminListSkeleton extends StatelessWidget {
  const AdminListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: const Color(0xFFEDE8DF),
        highlightColor: const Color(0xFFF5F0E8),
        child: ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          itemCount: itemCount,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppDimensions.space8),
          itemBuilder: (_, __) => const _SkeletonCard(),
        ),
      );
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) => Container(
        height: 80,
        decoration: BoxDecoration(
          color: kSurfaceWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AdminStatSkeleton
// ─────────────────────────────────────────────────────────────────────────────

/// Shimmer skeleton for the 4-stat dashboard grid.
class AdminStatSkeleton extends StatelessWidget {
  const AdminStatSkeleton({super.key, required this.crossAxisCount});

  final int crossAxisCount;

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: const Color(0xFFEDE8DF),
        highlightColor: const Color(0xFFF5F0E8),
        child: GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppDimensions.space16,
          mainAxisSpacing: AppDimensions.space16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          children: List.generate(
            4,
            (_) => Container(
              decoration: BoxDecoration(
                color: kSurfaceWhite,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AdminFormSkeleton
// ─────────────────────────────────────────────────────────────────────────────

/// Shimmer skeleton for form screens while pre-filling data.
class AdminFormSkeleton extends StatelessWidget {
  const AdminFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: const Color(0xFFEDE8DF),
        highlightColor: const Color(0xFFF5F0E8),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: kSurfaceWhite,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: kSurfaceWhite,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SaleStatusBadge
// ─────────────────────────────────────────────────────────────────────────────

/// Chip showing a sale's status with contextual color.
class SaleStatusBadge extends StatelessWidget {
  const SaleStatusBadge({super.key, required this.status});

  final SaleStatus status;

  Color get _bg => switch (status) {
        SaleStatus.pending => kAmber.withAlpha(26),
        SaleStatus.paid => kBlue.withAlpha(26),
        SaleStatus.shipped => kBlue.withAlpha(26),
        SaleStatus.delivered => kGreen.withAlpha(26),
        SaleStatus.cancelled => kRed.withAlpha(26),
      };

  Color get _fg => switch (status) {
        SaleStatus.pending => kAmber,
        SaleStatus.paid => kBlue,
        SaleStatus.shipped => kBlue,
        SaleStatus.delivered => kGreen,
        SaleStatus.cancelled => kRed,
      };

  String get _label =>
      status.dbValue[0].toUpperCase() + status.dbValue.substring(1);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space8,
          vertical: AppDimensions.space4,
        ),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
        child: Text(
          _label,
          style: AppTextStyles.labelSmall.copyWith(
            color: _fg,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// ProductStatusBadge
// ─────────────────────────────────────────────────────────────────────────────

/// Chip showing a product's status with contextual color.
class ProductStatusBadge extends StatelessWidget {
  const ProductStatusBadge({super.key, required this.status});

  final ProductStatus status;

  Color get _bg => switch (status) {
        ProductStatus.active => kGreen.withAlpha(26),
        ProductStatus.draft => kAmber.withAlpha(26),
        ProductStatus.archived => kSlate.withAlpha(26),
      };

  Color get _fg => switch (status) {
        ProductStatus.active => kGreen,
        ProductStatus.draft => kAmber,
        ProductStatus.archived => kSlate,
      };

  String get _label =>
      status.dbValue[0].toUpperCase() + status.dbValue.substring(1);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space8,
          vertical: AppDimensions.space4,
        ),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
        child: Text(
          _label,
          style: AppTextStyles.labelSmall.copyWith(
            color: _fg,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AdminSectionHeader
// ─────────────────────────────────────────────────────────────────────────────

/// Eyebrow + title header used to separate dashboard/detail sections.
class AdminSectionHeader extends StatelessWidget {
  const AdminSectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.trailing,
  });

  final String eyebrow;
  final String title;

  /// Optional trailing widget (e.g. a "View All" button).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gold eyebrow rule
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 2,
                      color: kGold,
                      margin: const EdgeInsets.only(right: 8),
                    ),
                    Text(
                      eyebrow.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: kGold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(title, style: AppTextStyles.headlineSmall),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AdminStatCard
// ─────────────────────────────────────────────────────────────────────────────

/// KPI card used on the admin dashboard stats grid.
class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: kSurfaceWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(26), // ≈10 % opacity
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Icon(icon, color: color, size: AppDimensions.iconM),
            ),
            const SizedBox(width: AppDimensions.space12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style:
                        AppTextStyles.bodySmall.copyWith(color: kTextSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: kTextDisabled),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AdminInfoRow
// ─────────────────────────────────────────────────────────────────────────────

/// A label/value row used in detail cards (e.g. order details).
class AdminInfoRow extends StatelessWidget {
  const AdminInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: kTextSecondary),
          ),
          Text(
            value,
            style: bold
                ? AppTextStyles.titleSmall.copyWith(color: valueColor)
                : AppTextStyles.bodyMedium.copyWith(
                    color: valueColor ?? kTextPrimary,
                  ),
          ),
        ],
      );
}
