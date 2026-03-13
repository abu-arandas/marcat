// lib/views/customer/shared/product_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/product_model.dart';
import '../../../models/enums.dart';
import 'brand.dart';

/// Full product card with hover effects, wishlist toggle, quick-add overlay.
/// Used in shop grid, new arrivals, best sellers, wishlist page, etc.
class ProductCard extends StatefulWidget {
  final ProductModel product;
  final bool isWishlisted;
  final VoidCallback? onWishlistToggle;
  final VoidCallback? onQuickAdd;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.isWishlisted = false,
    this.onWishlistToggle,
    this.onQuickAdd,
    this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap ??
              () => Get.toNamed('/app/product/${widget.product.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // â”€â”€ Image â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(fit: StackFit.expand, children: [
                    AnimatedScale(
                      scale: _hovered ? 1.06 : 1.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      child: CachedNetworkImage(
                        imageUrl: widget.product.primaryImageUrl ?? '',
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: kCream),
                        errorWidget: (_, __, ___) => Container(
                          color: kCream,
                          child: const Icon(Icons.image_outlined,
                              color: kSlate, size: 32),
                        ),
                      ),
                    ),

                    // Badges
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // FIX: was comparing ProductStatus enum to String 'active'.
                          //      Must compare enum to enum value.
                          if (widget.product.status == ProductStatus.active)
                            _Badge(label: 'NEW', color: kNavy),
                        ],
                      ),
                    ),

                    // Wishlist button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: widget.onWishlistToggle,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: widget.isWishlisted
                                ? kNavy
                                : Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.isWishlisted
                                ? Icons.favorite_rounded
                                : Icons.favorite_outline_rounded,
                            size: 16,
                            color: widget.isWishlisted ? Colors.white : kNavy,
                          ),
                        ),
                      ),
                    ),

                    // Quick-add overlay
                    AnimatedOpacity(
                      opacity: _hovered ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: widget.onQuickAdd,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            color: kNavy,
                            child: const Center(
                              child: Text(
                                'QUICK ADD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 12),

              // Category label
              const Text(
                'Collection',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: kSlate,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),

              // Product name
              Text(
                widget.product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kNavy,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),

              // Price
              Text(
                'JOD ${widget.product.basePrice.toStringAsFixed(3)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kNavy,
                ),
              ),
            ],
          ),
        ),
      );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        color: color,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      );
}
