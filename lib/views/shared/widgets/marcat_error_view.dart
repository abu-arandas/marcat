// lib/presentation/shared/widgets/marcat_error_view.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import 'marcat_button.dart';

class MarcatErrorView extends StatelessWidget {
  const MarcatErrorView({
    super.key,
    this.message,
    this.onRetry,
  });

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.statusRedLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.statusRed,
                size: 36,
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            Text(
              message ?? 'Something went wrong',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.space24),
              MarcatButton(
                label: 'Retry',
                onPressed: onRetry,
                fullWidth: false,
                variant: MarcatButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
