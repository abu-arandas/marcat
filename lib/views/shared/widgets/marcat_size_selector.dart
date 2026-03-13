// lib/presentation/shared/widgets/marcat_size_selector.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:marcat/models/product_size_model.dart';
import 'package:marcat/models/inventory_model.dart';

class MarcatSizeSelector extends StatelessWidget {
  const MarcatSizeSelector({
    super.key,
    required this.sizes,
    required this.inventory,
    required this.selectedSizeId,
    required this.onSizeSelected,
  });

  final List<ProductSizeModel> sizes;
  final List<InventoryModel> inventory;
  final int? selectedSizeId;
  final ValueChanged<ProductSizeModel> onSizeSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.space8,
      runSpacing: AppDimensions.space8,
      children: sizes.map((size) {
        final isSelected = size.id == selectedSizeId;
        final isAvailable = inventory
            .any((inv) => inv.productSizeId == size.id && inv.available > 0);

        return GestureDetector(
          onTap: isAvailable ? () => onSizeSelected(size) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.marcatBlack
                  : isAvailable
                      ? AppColors.surfaceWhite
                      : AppColors.surfaceGrey,
              border: Border.all(
                color: isSelected
                    ? AppColors.marcatBlack
                    : isAvailable
                        ? AppColors.borderMedium
                        : AppColors.borderLight,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
            ),
            child: Text(
              size.label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? AppColors.marcatCream
                    : isAvailable
                        ? AppColors.textPrimary
                        : AppColors.textDisabled,
                decoration: isAvailable ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
