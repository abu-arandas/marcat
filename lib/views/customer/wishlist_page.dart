// lib/views/customer/wishlist_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/product_controller.dart';
import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/core/constants/app_text_styles.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/models/product_model.dart';

import 'scaffold/app_scaffold.dart';
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
    if (mounted) setState(() => _isLoading = true);
    try {
      await _productCtrl.loadWishlist(uid);
      final ids = _productCtrl.wishlistItems.map((w) => w.productId).toList();
      final products = <ProductModel>[];
      for (final id in ids) {
        try {
          final p = await _productCtrl.fetchProductById(id);
          products.add(p);
        } catch (_) {
          // Skip products that failed to load.
        }
      }
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
      await _productCtrl.removeFromWishlist(uid, productId);
      if (mounted) {
        setState(() => _products.removeWhere((p) => p.id == productId));
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.marcatNavy, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) => CustomerScaffold(
        page: 'Wishlist',
        pageImage:
            'https://images.unsplash.com/photo-1445205170230-053b83016050?w=1600&q=80',
        body: _WishlistBody(
          products: _products,
          isLoading: _isLoading,
          error: _error,
          onRemove: _removeFromWishlist,
          onRefresh: _fetchWishlist,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _WishlistBody
// ─────────────────────────────────────────────────────────────────────────────

class _WishlistBody extends StatelessWidget {
  const _WishlistBody({
    required this.products,
    required this.isLoading,
    required this.error,
    required this.onRemove,
    required this.onRefresh,
  });

  final List<ProductModel> products;
  final bool isLoading;
  final String? error;
  final Future<void> Function(int) onRemove;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cols = width > 1024 ? 4 : (width > 576 ? 2 : 1);

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.marcatGold),
        ),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 40, color: AppColors.marcatSlate),
              const SizedBox(height: 12),
              Text(error!,
                  style: const TextStyle(color: AppColors.marcatSlate)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.marcatNavy),
              ),
            ],
          ),
        ),
      );
    }

    return FB5Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              eyebrow: 'Saved Items',
              title: 'My Wishlist',
              subtitle: products.isEmpty
                  ? null
                  : '${products.length} item${products.length != 1 ? 's' : ''}',
            ),
            const SizedBox(height: 32),
            if (products.isEmpty)
              EmptyState(
                icon: Icons.favorite_border_rounded,
                title: 'Your Wishlist Is Empty',
                subtitle:
                    'Save items you love by tapping the heart icon on any product.',
                actionLabel: 'Start Shopping',
                onAction: () => Get.toNamed(AppRoutes.shop),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.65,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) => _WishlistCard(
                  product: products[i],
                  onRemove: () => onRemove(products[i].id),
                  onViewProduct: () =>
                      Get.toNamed(AppRoutes.productOf(products[i].id)),
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
              // ── Image ────────────────────────────────────────────────────
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
                                placeholder: (_, __) => const ColoredBox(
                                    color: AppColors.marcatCream),
                                errorWidget: (_, __, ___) => const ColoredBox(
                                    color: AppColors.marcatCream),
                              )
                            : const ColoredBox(
                                color: AppColors.marcatCream,
                                child: Icon(Icons.image_not_supported_outlined,
                                    color: AppColors.marcatSlate),
                              ),
                      ),

                      // Hover overlay
                      AnimatedOpacity(
                        opacity: _hovered ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: ColoredBox(
                          color: AppColors.marcatNavy.withOpacity(0.12),
                        ),
                      ),

                      // Remove button
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Product name ─────────────────────────────────────────────
              Text(
                widget.product.name,
                style: AppTextStyles.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.product.basePrice.toJOD(),
                style: AppTextStyles.priceSmall
                    .copyWith(color: AppColors.marcatGold),
              ),
            ],
          ),
        ),
      );
}
