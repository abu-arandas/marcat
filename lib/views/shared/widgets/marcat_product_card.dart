// lib/presentation/shared/widgets/marcat_product_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:marcat/models/product_model.dart';
import 'marcat_price_display.dart';

class MarcatProductCard extends StatelessWidget {
  const MarcatProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onWishlistTap,
    this.isWishlisted = false,
    this.badgeText,
  });

  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback? onWishlistTap;
  final bool isWishlisted;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          boxShadow: [
            BoxShadow(
              color: AppColors.marcatBlack.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusS),
                topRight: Radius.circular(AppDimensions.radiusS),
              ),
              child: AspectRatio(
                aspectRatio: AppDimensions.productCardAspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (product.primaryImageUrl != null)
                      CachedNetworkImage(
                        imageUrl: product.primaryImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppColors.surfaceGrey),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.surfaceGrey,
                          child: const Icon(Icons.image_not_supported_outlined),
                        ),
                      )
                    else
                      Container(color: AppColors.surfaceGrey),
                    if (badgeText != null)
                      Positioned(
                        top: AppDimensions.space8,
                        left: AppDimensions.space8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.space8,
                            vertical: AppDimensions.space4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.marcatGold,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusXS),
                          ),
                          child:
                              Text(badgeText!, style: AppTextStyles.labelSmall),
                        ),
                      ),
                    if (onWishlistTap != null)
                      Positioned(
                        top: AppDimensions.space8,
                        right: AppDimensions.space8,
                        child: GestureDetector(
                          onTap: onWishlistTap,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: AppDimensions.iconS,
                              color: isWishlisted
                                  ? AppColors.statusRed
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.space4),
                  Text(
                    product.name,
                    style: AppTextStyles.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  MarcatPriceDisplay(price: product.basePrice),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
