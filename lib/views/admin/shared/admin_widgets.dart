// lib/views/admin/shared/admin_widgets.dart
//
// Shared UI primitives for every admin screen.
//
// Mirrors the quality & consistency of the customer-side shared widgets
// (empty_state.dart, section_header.dart, brand.dart) but styled for
// the admin panel's darker, more data-dense aesthetic.

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/core/constants/app_dimensions.dart';
import 'package:marcat/core/constants/app_text_styles.dart';
import 'package:marcat/models/enums.dart';

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
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Icon(icon,
                    size: AppDimensions.iconXXL, color: AppColors.marcatSlate),
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
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],

              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppDimensions.space24),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(actionLabel!),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.marcatNavy,
                    foregroundColor: AppColors.textOnDark,
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
                color: AppColors.statusRed,
                size: AppDimensions.iconXXL,
              ),
              const SizedBox(height: AppDimensions.space16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.space24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.marcatNavy,
                  side: const BorderSide(color: AppColors.borderMedium),
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
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          itemCount: itemCount,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppDimensions.space8),
          itemBuilder: (_, __) => _SkeletonCard(),
        ),
      );
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
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
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
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
                color: AppColors.surfaceWhite,
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
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _shimmerBox(height: 160),
              const SizedBox(height: AppDimensions.space16),
              _shimmerBox(height: 80),
              const SizedBox(height: AppDimensions.space16),
              _shimmerBox(height: 52),
            ],
          ),
        ),
      );

  Widget _shimmerBox({required double height}) => Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SaleStatusBadge
// ─────────────────────────────────────────────────────────────────────────────

/// Coloured pill badge showing the sale/order status.
class SaleStatusBadge extends StatelessWidget {
  const SaleStatusBadge({super.key, required this.status});

  final SaleStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static (Color bg, Color fg, String label) _resolve(SaleStatus s) =>
      switch (s) {
        SaleStatus.pending => (
            AppColors.statusAmberLight,
            AppColors.statusAmber,
            'PENDING'
          ),
        SaleStatus.paid => (
            AppColors.statusBlueLight,
            AppColors.statusBlue,
            'PAID'
          ),
        SaleStatus.shipped => (
            AppColors.statusBlueLight,
            AppColors.statusBlue,
            'SHIPPED'
          ),
        SaleStatus.delivered => (
            AppColors.statusGreenLight,
            AppColors.statusGreen,
            'DELIVERED'
          ),
        SaleStatus.cancelled => (
            AppColors.statusRedLight,
            AppColors.statusRed,
            'CANCELLED'
          ),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// ProductStatusBadge
// ─────────────────────────────────────────────────────────────────────────────

/// Coloured pill badge for product status (active / draft / archived).
class ProductStatusBadge extends StatelessWidget {
  const ProductStatusBadge({super.key, required this.status});

  final ProductStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static (Color bg, Color fg, String label) _resolve(ProductStatus s) =>
      switch (s) {
        ProductStatus.active => (
            AppColors.statusGreenLight,
            AppColors.statusGreen,
            'ACTIVE'
          ),
        ProductStatus.draft => (
            AppColors.statusAmberLight,
            AppColors.statusAmber,
            'DRAFT'
          ),
        ProductStatus.archived => (
            AppColors.surfaceGrey,
            AppColors.textSecondary,
            'ARCHIVED'
          ),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// AdminSectionHeader
// ─────────────────────────────────────────────────────────────────────────────

/// Editorial section header for admin page sections — eyebrow + title.
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
                      color: AppColors.marcatGold,
                      margin: const EdgeInsets.only(right: 8),
                    ),
                    Text(
                      eyebrow.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.marcatGold,
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
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(color: AppColors.borderLight),
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
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
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
                          .copyWith(color: AppColors.textDisabled),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppDimensions.space16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: bold
                  ? AppTextStyles.titleSmall
                  : AppTextStyles.bodyMedium.copyWith(
                      color: valueColor ?? AppColors.textPrimary,
                    ),
            ),
          ),
        ],
      );
}
