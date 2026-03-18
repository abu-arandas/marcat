// lib/views/customer/wishlist_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/controllers/product_controller.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/core/constants/app_text_styles.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/models/product_model.dart';

import '../../models/cart_item_model.dart';
import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart'; // ✅ single source of colour constants
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

      // ✅ FIXED: was O(N) serial await inside a for-loop.
      //    All product fetches now run concurrently via Future.wait,
      //    reducing load time from N×RTT to ~1×RTT.
      final results = await Future.wait(
        ids.map((id) => _productCtrl
            .fetchProductById(id)
            .then<ProductModel?>(
              (p) => p,
            )
            .onError<Object>((_, __) => null)),
      );

      if (mounted) {
        setState(() {
          _products
            ..clear()
            ..addAll(results.whereType<ProductModel>());
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFromWishlist(int productId) async {
    final uid = _userId;
    if (uid == null) return;
    setState(() => _products.removeWhere((p) => p.id == productId));
    try {
      await _productCtrl.removeFromWishlist(uid, productId);
    } catch (_) {
      // Optimistic removal failed — refetch to restore accurate state.
      await _fetchWishlist();
    }
  }

  @override
  Widget build(BuildContext context) => CustomerScaffold(
        page: 'Wishlist',
        pageImage:
            'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=1600&q=80',
        body: _buildBody(),
      );

  Widget _buildBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.marcatGold,
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: EmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Could Not Load Wishlist',
          subtitle: _error,
          actionLabel: 'Retry',
          onAction: _fetchWishlist,
        ),
      );
    }

    if (_userId == null) {
      return EmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'Sign In to See Your Wishlist',
        subtitle: 'Save items you love and come back to them any time.',
        actionLabel: 'Sign In',
        onAction: () => Get.toNamed(AppRoutes.login),
      );
    }

    if (_products.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'Your Wishlist Is Empty',
        subtitle: "Browse our collection and save the pieces you love.",
        actionLabel: 'Start Shopping',
        onAction: () => Get.toNamed(AppRoutes.shop),
      );
    }

    final isDesktop = MediaQuery.sizeOf(context).width > 900;

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
                crossAxisCount: isDesktop ? 4 : 2,
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

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────────────────────────────
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Product image
                    AnimatedScale(
                      scale: _hovered ? 1.04 : 1.0,
                      duration: const Duration(milliseconds: 320),
                      child: widget.product.primaryImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: widget.product.primaryImageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const ColoredBox(
                                  color: AppColors.marcatCream),
                              errorWidget: (_, __, ___) => const ColoredBox(
                                  color: AppColors.marcatCream),
                            )
                          : const ColoredBox(color: AppColors.marcatCream),
                    ),

                    // Remove (heart) button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: widget.onRemove,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 16,
                            color: AppColors.saleRed,
                          ),
                        ),
                      ),
                    ),

                    // Quick-add overlay on hover
                    if (_hovered)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _addingToCart ? null : _quickAddToCart,
                          child: Container(
                            height: 40,
                            color: kNavy.withAlpha(217),
                            alignment: Alignment.center,
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
                                    'ADD TO BAG',
                                    style: TextStyle(
                                      fontFamily: 'IBMPlexSansArabic',
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
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

            // ── Product info ───────────────────────────────────────────────
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.productOf(widget.product.id)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product.basePrice.toJOD(),
                    style: AppTextStyles.priceMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Future<void> _quickAddToCart() async {
    if (mounted) setState(() => _addingToCart = true);
    try {
      final cart = Get.find<CartController>();
      // Quick-add uses the first available size — navigates to PDP if none.
      cart.addItem(
        CartItemModel(
          productId: widget.product.id,
          productName: widget.product.name,

          primaryImageUrl: widget.product.primaryImageUrl,

          colorId: 0, // TODO: implement color selection
          colorName: "", // TODO: implement color selection
          quantity: 1, // TODO: implement quantity selection
          productSizeId: 0, // TODO: implement size selection
          sizeLabel: "", // TODO: implement size selection
          unitPrice: widget.product.basePrice,
          discountAmount: 0, // TODO: implement discount amount selection
        ),
      );
      Get.snackbar(
        'Added',
        '${widget.product.name} added to bag.',
        backgroundColor: AppColors.marcatNavy,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (_) {
      Get.toNamed(AppRoutes.productOf(widget.product.id));
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }
}
