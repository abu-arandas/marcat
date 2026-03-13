// lib/views/customer/wishlist_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';
// FIX: wishlist_repository.dart → product_controller.dart (merged)
import 'package:marcat/controllers/product_controller.dart';
// FIX: product_repository.dart merged into ProductController
// FIX: cart_repository.dart → cart_controller.dart
import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/controllers/auth_controller.dart'; // FIX: auth_provider.dart → auth_controller.dart
import 'package:marcat/models/product_model.dart';
import 'package:marcat/models/cart_item_model.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/empty_state.dart';
import 'shared/section_header.dart';
import 'package:marcat/core/router/app_router.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final products = <ProductModel>[];
  bool isLoading = true;

  ProductController get _productCtrl => Get.find<ProductController>();
  CartController get _cart => Get.find<CartController>();
  AuthController get _auth => Get.find<AuthController>();

  String? get _userId => _auth.currentAuthUser?.id;

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
          products.clear();
          products.addAll(fetched);
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
        setState(() {
          products.removeWhere((p) => p.id == productId);
        });
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void addToCart(ProductModel product) {
    _cart.addItem(CartItemModel(
      productSizeId: product.id, // placeholder
      productId: product.id,
      productName: product.name,
      sizeLabel: '',
      colorName: '',
      colorId: 0,
      primaryImageUrl: product.primaryImageUrl,
      unitPrice: product.basePrice,
      quantity: 1,
    ));
    Get.snackbar(
      'Added to Bag',
      '${product.name} has been added to your bag.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: kNavy,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomerScaffold(
      page: 'Wishlist',
      pageImage:
          'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1600&q=80',
      body: _WishlistBody(
        products: products,
        isLoading: isLoading,
        onRemove: removeFromWishlist,
        onAddToCart: addToCart,
      ),
    );
  }
}

class _WishlistBody extends StatelessWidget {
  final List<ProductModel> products;
  final bool isLoading;
  final Function(int) onRemove;
  final Function(ProductModel) onAddToCart;

  const _WishlistBody({
    required this.products,
    required this.isLoading,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      // Not logged in
      if (auth.currentAuthUser == null) {
        return EmptyState(
          icon: Icons.favorite_outline_rounded,
          title: 'Sign In to See Your Wishlist',
          subtitle:
              'Create an account or sign in to save your favourite pieces.',
          actionLabel: 'Sign In',
          onAction: () => Get.toNamed(AppRoutes.login),
        );
      }

      // Loading
      if (isLoading) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: Center(
            child: CircularProgressIndicator(color: kNavy, strokeWidth: 2),
          ),
        );
      }

      // Empty
      if (products.isEmpty) {
        return EmptyState(
          icon: Icons.favorite_border_rounded,
          title: 'Your Wishlist Is Empty',
          subtitle:
              'Save your favourite pieces here to come back to them later.',
          actionLabel: 'Start Shopping',
          onAction: () => Get.toNamed(AppRoutes.shop),
        );
      }

      final isDesktop = MediaQuery.sizeOf(context).width > 768;

      return FB5Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SectionHeader(
                    eyebrow: 'Saved Items',
                    title: 'My Wishlist',
                    subtitle:
                        '${products.length} item${products.length == 1 ? '' : 's'} saved',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.shop),
                    style: TextButton.styleFrom(foregroundColor: kNavy),
                    child: const Row(
                      children: [
                        Text('Continue Shopping',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.55,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) => _WishlistCard(
                  product: products[i],
                  onRemove: onRemove,
                  onAddToCart: onAddToCart,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _WishlistCard extends StatefulWidget {
  final ProductModel product;
  final Function(int) onRemove;
  final Function(ProductModel) onAddToCart;

  const _WishlistCard({
    required this.product,
    required this.onRemove,
    required this.onAddToCart,
  });

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(fit: StackFit.expand, children: [
                  GestureDetector(
                    onTap: () =>
                        Get.toNamed('/app/product/${widget.product.id}'),
                    child: AnimatedScale(
                      scale: _hovered ? 1.06 : 1.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      child: widget.product.primaryImageUrl != null
                          ? Image.network(
                              widget.product.primaryImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: kCream,
                                child: const Icon(Icons.image_outlined,
                                    color: kSlate, size: 32),
                              ),
                            )
                          : Container(color: kCream),
                    ),
                  ),

                  // Remove button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => widget.onRemove(widget.product.id),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_rounded,
                            size: 16, color: kRed),
                      ),
                    ),
                  ),

                  // Add to bag overlay
                  AnimatedOpacity(
                    opacity: _hovered ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => widget.onAddToCart(widget.product),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          color: kNavy,
                          child: const Center(
                            child: Text(
                              'ADD TO BAG',
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
            const Text('COLLECTION',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: kSlate,
                    letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(
              widget.product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kNavy,
                  height: 1.3),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'JOD ${widget.product.basePrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700, color: kNavy),
                ),
                const Spacer(),
                // Quick add
                GestureDetector(
                  onTap: () => widget.onAddToCart(widget.product),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kNavy,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined,
                        size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
