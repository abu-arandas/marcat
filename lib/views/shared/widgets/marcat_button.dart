// lib/presentation/shared/widgets/marcat_button.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

enum MarcatButtonVariant { primary, secondary, ghost, gold, danger }

class MarcatButton extends StatelessWidget {
  const MarcatButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = MarcatButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.height,
  });

  final String label;
  final VoidCallback? onPressed;
  final MarcatButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ??
        (variant == MarcatButtonVariant.secondary
            ? AppDimensions.buttonHeightSecondary
            : AppDimensions.buttonHeightPrimary);

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _foregroundColor,
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      size: AppDimensions.iconM, color: _foregroundColor),
                  const SizedBox(width: AppDimensions.space8),
                  Text(label,
                      style: AppTextStyles.buttonPrimary
                          .copyWith(color: _foregroundColor)),
                ],
              )
            : Text(label,
                style: AppTextStyles.buttonPrimary
                    .copyWith(color: _foregroundColor));

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      side: variant == MarcatButtonVariant.secondary
          ? BorderSide(color: _backgroundColor, width: 1.5)
          : BorderSide.none,
    );

    if (variant == MarcatButtonVariant.secondary ||
        variant == MarcatButtonVariant.ghost) {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: _backgroundColor,
            side: BorderSide(color: _backgroundColor, width: 1.5),
            shape: shape,
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _backgroundColor,
          foregroundColor: _foregroundColor,
          elevation: 0,
          shape: shape,
        ),
        child: child,
      ),
    );
  }

  Color get _backgroundColor => switch (variant) {
        MarcatButtonVariant.primary => AppColors.marcatBlack,
        MarcatButtonVariant.gold => AppColors.marcatGold,
        MarcatButtonVariant.danger => AppColors.statusRed,
        MarcatButtonVariant.secondary => AppColors.marcatBlack,
        MarcatButtonVariant.ghost => Colors.transparent,
      };

  Color get _foregroundColor => switch (variant) {
        MarcatButtonVariant.primary => AppColors.marcatCream,
        MarcatButtonVariant.gold => AppColors.marcatBlack,
        MarcatButtonVariant.danger => Colors.white,
        MarcatButtonVariant.secondary => AppColors.marcatBlack,
        MarcatButtonVariant.ghost => AppColors.marcatBlack,
      };
}
