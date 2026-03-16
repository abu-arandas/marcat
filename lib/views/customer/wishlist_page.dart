// lib/views/customer/wishlist_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/product_controller.dart';
import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/models/product_model.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/empty_state.dart';
import 'shared/section_header.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final products = <ProductModel>[];
  bool isLoading = true;

  ProductController get _productCtrl => Get.find<ProductController>();
  AuthController get _auth => Get.find<AuthController>();

  String? get _userId => _auth.state.value.user?.id;

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    final uid = _userId;
    if (uid == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }
    if (mounted) setState(() => isLoading = true);
    try {
      // Ensure the wishlist observable is up to date.
      await _productCtrl.loadWishlist(uid);
      final wishItems = _productCtrl.wishlistItems;
      if (wishItems.isEmpty) {
        if (mounted) {
          setState(() {
            products.clear();
            isLoading = false;
          });
        }
        return;
      }
      final ids = wishItems.map((w) => w.productId).toList();
      final fetched = await _productCtrl.fetchProductsByIds(ids);
      if (mounted) {
        setState(() {
          products
            ..clear()
            ..addAll(fetched);
          isLoading = false;
        });
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    final uid = _userId;
    if (uid == null) return;
    try {
      await _productCtrl.removeFromWishlist(uid, productId);
      if (mounted) {
        setState(() => products.removeWhere((p) => p.id == productId));
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void viewProduct(int productId) {
    Get.toNamed(AppRoutes.productOf(productId));
  }

  @override
  Widget build(BuildContext context) {
    return CustomerScaffold(
      page: 'Wishlist',
      pageImage:
          'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=1600&q=80',
      body: _WishlistBody(
        products: products,
        isLoading: isLoading,
        onRemove: removeFromWishlist,
        onViewProduct: viewProduct,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WishlistBody
// ─────────────────────────────────────────────────────────────────────────────

class _WishlistBody extends StatelessWidget {
  const _WishlistBody({
    required this.products,
    required this.isLoading,
    required this.onRemove,
    required this.onViewProduct,
  });

  final List<ProductModel> products;
  final bool isLoading;
  final void Function(int) onRemove;
  final void Function(int) onViewProduct;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 1024;

    return FB5Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              eyebrow: 'Your Saved Items',
              title: 'Wishlist',
              subtitle:
                  '${products.length} item${products.length == 1 ? '' : 's'}',
            ),
            const SizedBox(height: 32),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (products.isEmpty)
              EmptyState(
                icon: Icons.favorite_outline_rounded,
                title: 'Your wishlist is empty',
                subtitle: 'Save items you love by tapping the heart icon.',
                actionLabel: 'Start Shopping',
                onAction: () => Get.toNamed(AppRoutes.shop),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.62,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) => _WishlistCard(
                  product: products[i],
                  onRemove: () => onRemove(products[i].id),
                  onViewProduct: () => onViewProduct(products[i].id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WishlistCard
// ─────────────────────────────────────────────────────────────────────────────

class _WishlistCard extends StatefulWidget {
  const _WishlistCard({
    required this.product,
    required this.onRemove,
    required this.onViewProduct,
  });

  final ProductModel product;
  final VoidCallback onRemove;
  final VoidCallback onViewProduct;

  @override
  State<_WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends State<_WishlistCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onViewProduct,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedScale(
                        scale: _hovered ? 1.06 : 1.0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        child: widget.product.primaryImageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: widget.product.primaryImageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) =>
                                    Container(color: kCream),
                                errorWidget: (_, __, ___) => Container(
                                    color: kCream,
                                    child: const Icon(Icons.image_outlined,
                                        color: kSlate, size: 32)),
                              )
                            : Container(
                                color: kCream,
                                child: const Icon(Icons.image_outlined,
                                    color: kSlate, size: 32)),
                      ),

                      // Remove from wishlist button
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: widget.onRemove,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              color: kNavy,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.favorite_rounded,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),

                      // "View & Add to Cart" overlay — navigates to detail
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedOpacity(
                          opacity: _hovered ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            color: kNavy.withOpacity(0.85),
                            child: const Center(
                              child: Text(
                                'Select Size & Add',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Text(
                widget.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.product.basePrice.toJOD(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kSlate,
                ),
              ),
            ],
          ),
        ),
      );
}
