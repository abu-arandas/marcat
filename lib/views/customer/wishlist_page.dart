// lib/views/customer/wishlist_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/controllers/product_controller.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/models/cart_item_model.dart';
import 'package:marcat/models/product_model.dart';

import '../../models/cart_item_model.dart';
import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/empty_state.dart';
import 'shared/section_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WishlistPage
// ─────────────────────────────────────────────────────────────────────────────

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final _products = <ProductModel>[];
  bool _isLoading = true;
  String? _error;

  ProductController get _productCtrl => Get.find<ProductController>();
  AuthController get _auth => Get.find<AuthController>();
  String? get _userId => _auth.state.value.user?.id;

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    final uid = _userId;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      await _productCtrl.loadWishlist(uid);
      final ids = _productCtrl.wishlistItems.map((w) => w.productId).toList();

      // ✅ All fetches run concurrently — O(1) RTT instead of O(N).
      final products = await Future.wait(
        ids.map((id) => _productCtrl.fetchProductById(id)),
      );

      if (mounted) {
        setState(() {
          _products
            ..clear()
            ..addAll(products);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFromWishlist(int productId) async {
    final uid = _userId;
    if (uid == null) return;
    try {
      await _productCtrl.toggleWishlist(uid, productId);
      if (mounted) {
        setState(() {
          _products.removeWhere((p) => p.id == productId);
        });
      }
    } catch (e) {
      if (mounted) Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomerScaffold(
      page: 'Wishlist',
      pageImage:
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=1600&q=80',
      body: _isLoading
          ? _WishlistSkeleton()
          : _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final uid = _userId;

    if (uid == null) {
      return EmptyState(
        icon: Icons.lock_outline_rounded,
        title: 'Sign In Required',
        subtitle: 'Please sign in to view your wishlist.',
        actionLabel: 'Sign In',
        onAction: () => Get.toNamed(AppRoutes.login),
      );
    }

    if (_error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Something Went Wrong',
        subtitle: _error,
        actionLabel: 'Retry',
        onAction: _fetchWishlist,
      );
    }

    if (_products.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'Your Wishlist Is Empty',
        subtitle: 'Browse our collection and save the pieces you love.',
        actionLabel: 'Start Shopping',
        onAction: () => Get.toNamed(AppRoutes.shop),
      );
    }

    final width = MediaQuery.sizeOf(context).width;
    final cols = width > 900 ? 4 : (width > 600 ? 3 : 2);

    return FB5Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              eyebrow: 'Saved Items',
              title: 'Your Wishlist',
              subtitle:
                  '${_products.length} item${_products.length == 1 ? '' : 's'} saved.',
            ),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: 0.68,
              ),
              itemCount: _products.length,
              itemBuilder: (_, i) => _WishlistProductCard(
                product: _products[i],
                onRemove: () => _removeFromWishlist(_products[i].id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WishlistProductCard
// ─────────────────────────────────────────────────────────────────────────────

class _WishlistProductCard extends StatefulWidget {
  const _WishlistProductCard({
    required this.product,
    required this.onRemove,
  });

  final ProductModel product;
  final VoidCallback onRemove;

  @override
  State<_WishlistProductCard> createState() => _WishlistProductCardState();
}

class _WishlistProductCardState extends State<_WishlistProductCard> {
  bool _hovered = false;
  bool _addingToCart = false;

  Future<void> _addToCart() async {
    if (_addingToCart) return;
    // Navigate to product detail so user can select size/colour.
    Get.toNamed('/app/product/${widget.product.id}');
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ─────────────────────────────────────────────────
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Product image with zoom
                    AnimatedScale(
                      scale: _hovered ? 1.06 : 1.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      child: GestureDetector(
                        onTap: () => Get.toNamed(
                          '/app/product/${widget.product.id}',
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.product.primaryImageUrl ??
                              'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=400&q=60',
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: const Color(0xFFEDE8DF),
                            highlightColor: const Color(0xFFF5F0E8),
                            child: const ColoredBox(color: Colors.white),
                          ),
                          errorWidget: (_, __, ___) =>
                              const ColoredBox(color: kCream),
                        ),
                      ),
                    ),

                    // Remove button (top-right)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: widget.onRemove,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(230),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 16,
                            color: kRed,
                          ),
                        ),
                      ),
                    ),

                    // Add to Cart overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        opacity: _hovered ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: GestureDetector(
                          onTap: _addToCart,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            color: kNavy,
                            child: Center(
                              child: _addingToCart
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'ADD TO CART',
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Product name ───────────────────────────────────────────
            Text(
              widget.product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kNavy,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),

            // ── Price ──────────────────────────────────────────────────
            Text(
              widget.product.basePrice.toJOD(),
              style: const TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kNavy,
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _WishlistSkeleton
// ─────────────────────────────────────────────────────────────────────────────

class _WishlistSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cols = width > 900 ? 4 : (width > 600 ? 3 : 2);

    return FB5Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
          childAspectRatio: 0.68,
          children: List.generate(
            8,
            (_) => Shimmer.fromColors(
              baseColor: const Color(0xFFEDE8DF),
              highlightColor: const Color(0xFFF5F0E8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const ColoredBox(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
