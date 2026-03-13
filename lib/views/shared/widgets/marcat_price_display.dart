// lib/presentation/shared/widgets/marcat_price_display.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/currency_extensions.dart';

class MarcatPriceDisplay extends StatelessWidget {
  const MarcatPriceDisplay({
    super.key,
    required this.price,
    this.originalPrice,
    this.size = PriceSize.medium,
  });

  final double price;
  final double? originalPrice;
  final PriceSize size;

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  @override
  Widget build(BuildContext context) {
    final priceStyle = switch (size) {
      PriceSize.small => AppTextStyles.priceSmall,
      PriceSize.medium => AppTextStyles.priceMedium,
      PriceSize.large => AppTextStyles.priceLarge,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(price.toJOD(), style: priceStyle),
        if (hasDiscount) ...[
          const SizedBox(width: AppDimensions.space8),
          Text(
            originalPrice!.toJOD(),
            style: priceStyle.copyWith(
              color: AppColors.textDisabled,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.lineThrough,
              fontSize: priceStyle.fontSize! - 2,
            ),
          ),
        ],
      ],
    );
  }
}

enum PriceSize { small, medium, large }
