// lib/presentation/shared/widgets/marcat_color_selector.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import 'package:marcat/models/product_color_model.dart';

class MarcatColorSelector extends StatelessWidget {
  const MarcatColorSelector({
    super.key,
    required this.colors,
    required this.selectedColorId,
    required this.onColorSelected,
  });

  final List<ProductColorModel> colors;
  final int? selectedColorId;
  final ValueChanged<ProductColorModel> onColorSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.space8,
      runSpacing: AppDimensions.space8,
      children: colors.map((color) {
        final isSelected = color.id == selectedColorId;
        final colorValue = _parseHex(color.hexCode);
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Tooltip(
            message: color.name,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorValue,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.marcatGold
                      : colorValue.computeLuminance() > 0.8
                          ? AppColors.borderMedium
                          : Colors.transparent,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.marcatGold.withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: colorValue.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    )
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _parseHex(String hex) {
    try {
      final h = hex.replaceFirst('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return AppColors.surfaceGrey;
    }
  }
}
