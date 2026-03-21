// lib/views/pos/shared/pos_widgets.dart
//
// Shared UI primitives for POS screens — mirrors the pattern of
// customer/shared/empty_state.dart and admin/shared/admin_widgets.dart.

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PosEmptyCart
// ─────────────────────────────────────────────────────────────────────────────

/// Empty cart placeholder for the POS ticket panel.
class PosEmptyCart extends StatelessWidget {
  const PosEmptyCart({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: AppDimensions.iconXXL,
              color: AppColors.textDisabled,
            ),
            SizedBox(height: AppDimensions.space12),
            Text(
              'Cart is empty',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textDisabled,
              ),
            ),
            SizedBox(height: AppDimensions.space4),
            Text(
              'Tap a product to add it',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// PosEmptyProducts
// ─────────────────────────────────────────────────────────────────────────────

/// Empty product grid placeholder.
class PosEmptyProducts extends StatelessWidget {
  const PosEmptyProducts({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: AppDimensions.iconXXL,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppDimensions.space12),
            Text(
              message ?? 'No products found.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// PosProductGridSkeleton
// ─────────────────────────────────────────────────────────────────────────────

/// Shimmer skeleton for the POS product grid while loading.
class PosProductGridSkeleton extends StatelessWidget {
  const PosProductGridSkeleton({super.key, this.itemCount = 9});

  final int itemCount;

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: GridView.builder(
          padding: const EdgeInsets.all(AppDimensions.space16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.75,
            crossAxisSpacing: AppDimensions.space12,
            mainAxisSpacing: AppDimensions.space12,
          ),
          itemCount: itemCount,
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusS),
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// PosCartItemTile
// ─────────────────────────────────────────────────────────────────────────────

/// A single line item row in the POS cart / ticket panel.
class PosCartItemTile extends StatelessWidget {
  const PosCartItemTile({
    super.key,
    required this.name,
    required this.size,
    required this.color,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.imageUrl,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
  });

  final String name;
  final String size;
  final String color;
  final int quantity;
  final String unitPrice;
  final String lineTotal;
  final String? imageUrl;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.space8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product info ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  Text(
                    '$size · $color',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  Text(
                    '$unitPrice × $quantity',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Quantity controls ────────────────────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QtyButton(
                  icon: Icons.remove,
                  onTap: onDecrement,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space8,
                  ),
                  child: Text(
                    '$quantity',
                    style: AppTextStyles.titleSmall,
                  ),
                ),
                _QtyButton(
                  icon: Icons.add,
                  onTap: onIncrement,
                ),
              ],
            ),

            const SizedBox(width: AppDimensions.space12),

            // ── Line total ──────────────────────────────────────────────
            Text(lineTotal, style: AppTextStyles.priceMedium),

            // ── Remove button ───────────────────────────────────────────
            if (onRemove != null)
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: AppDimensions.iconS,
                  color: AppColors.textDisabled,
                ),
                onPressed: onRemove,
                splashRadius: 16,
                tooltip: 'Remove',
              ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _QtyButton
// ─────────────────────────────────────────────────────────────────────────────

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusXS),
          ),
          child: Icon(icon, size: 14, color: AppColors.textPrimary),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// PosTotalRow
// ─────────────────────────────────────────────────────────────────────────────

/// Label + value row for the POS cart totals section.
class PosTotalRow extends StatelessWidget {
  const PosTotalRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppTextStyles.titleSmall
                : AppTextStyles.bodyMedium,
          ),
          Text(
            value,
            style: isBold
                ? AppTextStyles.priceMedium
                : AppTextStyles.priceSmall,
          ),
        ],
      );
}
