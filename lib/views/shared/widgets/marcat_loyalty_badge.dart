// lib/presentation/shared/widgets/marcat_loyalty_badge.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

class MarcatLoyaltyBadge extends StatelessWidget {
  const MarcatLoyaltyBadge({
    super.key,
    required this.points,
    this.showIcon = true,
    this.size = LoyaltyBadgeSize.medium,
  });

  final int points;
  final bool showIcon;
  final LoyaltyBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final style = switch (size) {
      LoyaltyBadgeSize.small => AppTextStyles.labelSmall,
      LoyaltyBadgeSize.medium => AppTextStyles.labelMedium,
      LoyaltyBadgeSize.large => AppTextStyles.titleMedium,
    };

    final iconSize = switch (size) {
      LoyaltyBadgeSize.small => AppDimensions.iconS,
      LoyaltyBadgeSize.medium => AppDimensions.iconM,
      LoyaltyBadgeSize.large => AppDimensions.iconL,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size == LoyaltyBadgeSize.large
            ? AppDimensions.space12
            : AppDimensions.space8,
        vertical: size == LoyaltyBadgeSize.large
            ? AppDimensions.space8
            : AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.marcatGold.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(
          color: AppColors.marcatGold.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.stars_rounded,
              size: iconSize,
              color: AppColors.marcatGold,
            ),
            const SizedBox(width: AppDimensions.space4),
          ],
          Text(
            '$points points',
            style: style.copyWith(
              color: AppColors.marcatBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

enum LoyaltyBadgeSize { small, medium, large }
