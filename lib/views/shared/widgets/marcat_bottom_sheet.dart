// lib/presentation/shared/widgets/marcat_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Utility to show a branded bottom sheet.
Future<T?> showMarcatBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    backgroundColor: AppColors.surfaceWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppDimensions.radiusL),
        topRight: Radius.circular(AppDimensions.radiusL),
      ),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: AppDimensions.space12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (title != null) ...[
              const SizedBox(height: AppDimensions.space16),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space16),
                child: Text(title, style: AppTextStyles.titleMedium),
              ),
              const Divider(height: AppDimensions.space24),
            ] else
              const SizedBox(height: AppDimensions.space16),
            child,
            const SizedBox(height: AppDimensions.space24),
          ],
        ),
      );
    },
  );
}
