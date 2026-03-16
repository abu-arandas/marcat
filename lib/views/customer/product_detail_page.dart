// lib/views/customer/product_detail_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/product_controller.dart';
import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/models/product_model.dart';
import 'package:marcat/models/product_color_model.dart';
import 'package:marcat/models/product_size_model.dart';
import 'package:marcat/models/product_image_model.dart';
import 'package:marcat/models/cart_item_model.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'shared/empty_state.dart';
import 'shared/product_card.dart';
import 'shared/section_header.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final int productId;

  // -- Data --
  ProductModel? product;
  List<ProductColorModel> colors = [];
  List<ProductSizeModel> sizes = [];
  List<ProductImageModel> images = [];
  List<ProductModel> relatedProducts = [];

  /// sizeId → total quantity across all stores
  Map<int, int> stockBySizeId = {};

  // -- Loading / error --
  bool isLoading = true;
  String? errorMessage;

  // -- UI state --
  int selectedColorIndex = 0;
  int? selectedSizeId;
  int quantity = 1;
  int activeImageIndex = 0;
  bool isWishlisted = false;
  bool isAddingToCart = false;
  int activeTab = 0; // 0=Description 1=Details 2=Care

  // -- Controllers --
  ProductController get _productCtrl => Get.find<ProductController>();
  CartController get _cart => Get.find<CartController>();
  AuthController get _auth => Get.find<AuthController>();

  String? get _userId => _auth.state.value.user?.id;

  // -- Convenience getters --
  ProductColorModel? get selectedColor =>
      colors.isEmpty ? null : colors[selectedColorIndex];

  bool isSizeInStock(int sizeId) => (stockBySizeId[sizeId] ?? 0) > 0;

  bool get canAddToCart =>
      selectedSizeId != null &&
      isSizeInStock(selectedSizeId!) &&
      !isAddingToCart;

  @override
  void initState() {
    super.initState();

    final rawId = Get.parameters['id'];
    final parsed = rawId != null ? int.tryParse(rawId) : null;

    if (parsed == null) {
      // Must navigate away after first frame — cannot call Get.back() in initState
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar(
          'Invalid Link',
          'The product link is invalid.',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      return;
    }

    productId = parsed;
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetched = await _productCtrl.fetchProductById(productId);
      final fetchedColors = await _productCtrl.fetchColors(productId);
      final fetchedSizes = await _productCtrl.fetchSizes(productId);
      final fetchedImages = await _productCtrl.fetchImages(productId);
      final availability =
          await _productCtrl.fetchProductAvailability(productId);

      // Build stockBySizeId map
      final stockMap = <int, int>{};
      for (final inv in availability) {
        stockMap[inv.productSizeId] =
            (stockMap[inv.productSizeId] ?? 0) + inv.trulyAvailable;
      }

      if (!mounted) return;
      setState(() {
        product = fetched;
        colors = fetchedColors;
        sizes = fetchedSizes;
        images = fetchedImages;
        stockBySizeId = stockMap;
        isLoading = false;
      });

      if (fetched.categoryId != null) {
        _loadRelatedProducts(fetched.categoryId!, fetched.id);
      }

      // Check wishlist status
      if (_userId != null) {
        final wishlisted = _productCtrl.isProductInWishlist(productId);
        if (mounted) setState(() => isWishlisted = wishlisted);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadRelatedProducts(int categoryId, int excludeId) async {
    try {
      final related =
          await _productCtrl.fetchProducts(categoryId: categoryId).then(
                (list) => list.$1.where((p) => p.id != excludeId).toList(),
              );
      final filtered = related.where((p) => p.id != excludeId).toList();
      if (mounted) setState(() => relatedProducts = filtered);
    } catch (_) {
      // Non-critical — silently ignore
    }
  }

  Future<void> _addToCart() async {
    final sizeId = selectedSizeId;
    final color = selectedColor;
    final prod = product;

    if (sizeId == null || color == null || prod == null) return;

    final size = sizes.firstWhere((s) => s.id == sizeId);

    if (!mounted) return;
    setState(() => isAddingToCart = true);

    try {
      _cart.addItem(
        CartItemModel(
          productId: prod.id,
          productName: prod.name,
          productSizeId: sizeId, // ✅ correct: sizeId from user selection
          sizeLabel: size.label,
          colorId: color.id,
          colorName: color.name,
          unitPrice: prod.basePrice,
          quantity: quantity,
          primaryImageUrl: prod.primaryImageUrl,
        ),
      );
      if (mounted) {
        Get.snackbar(
          'Added to Cart',
          '${prod.name} added to your cart.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (mounted) Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => isAddingToCart = false);
    }
  }

  Future<void> _toggleWishlist() async {
    final uid = _userId;
    if (uid == null) {
      Get.toNamed(AppRoutes.login);
      return;
    }
    try {
      final nowIn = await _productCtrl.toggleWishlist(uid, productId); 
      if (mounted) setState(() => isWishlisted = nowIn);
    } catch (e) {
      if (mounted) Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppColors.marcatGold)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load product',
          subtitle: errorMessage,
          actionLabel: 'Go Back',
          onAction: () => Get.back(),
        ),
      );
    }

    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.search_off,
          title: 'Product not found',
        ),
      );
    }

    return CustomerScaffold(
      page: product!.name,
      body: _ProductDetailBody(
        product: product!,
        colors: colors,
        sizes: sizes,
        images: images,
        relatedProducts: relatedProducts,
        selectedColorIndex: selectedColorIndex,
        selectedSizeId: selectedSizeId,
        quantity: quantity,
        activeImageIndex: activeImageIndex,
        isWishlisted: isWishlisted,
        isAddingToCart: isAddingToCart,
        isSizeInStock: isSizeInStock,
        canAddToCart: canAddToCart,
        activeTab: activeTab,
        onColorSelected: (i) => setState(() => selectedColorIndex = i),
        onSizeSelected: (id) => setState(() => selectedSizeId = id),
        onQuantityChanged: (q) => setState(() => quantity = q),
        onImageChanged: (i) => setState(() => activeImageIndex = i),
        onWishlistToggle: _toggleWishlist,
        onAddToCart: _addToCart,
        onTabChanged: (t) => setState(() => activeTab = t),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Extracted UI body widget (keeps ProductDetailPage lean)
// ─────────────────────────────────────────────────────────────────────────────

class _ProductDetailBody extends StatelessWidget {
  const _ProductDetailBody({
    required this.product,
    required this.colors,
    required this.sizes,
    required this.images,
    required this.relatedProducts,
    required this.selectedColorIndex,
    required this.selectedSizeId,
    required this.quantity,
    required this.activeImageIndex,
    required this.isWishlisted,
    required this.isAddingToCart,
    required this.isSizeInStock,
    required this.canAddToCart,
    required this.activeTab,
    required this.onColorSelected,
    required this.onSizeSelected,
    required this.onQuantityChanged,
    required this.onImageChanged,
    required this.onWishlistToggle,
    required this.onAddToCart,
    required this.onTabChanged,
  });

  final ProductModel product;
  final List<ProductColorModel> colors;
  final List<ProductSizeModel> sizes;
  final List<ProductImageModel> images;
  final List<ProductModel> relatedProducts;
  final int selectedColorIndex;
  final int? selectedSizeId;
  final int quantity;
  final int activeImageIndex;
  final bool isWishlisted;
  final bool isAddingToCart;
  final bool Function(int sizeId) isSizeInStock;
  final bool canAddToCart;
  final int activeTab;
  final ValueChanged<int> onColorSelected;
  final ValueChanged<int?> onSizeSelected;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<int> onImageChanged;
  final VoidCallback onWishlistToggle;
  final VoidCallback onAddToCart;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return FB5Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name & price
            Text(product.name,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(product.basePrice.toJOD(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: kGold,
                    )),
            const SizedBox(height: 24),

            // Image gallery placeholder
            if (images.isNotEmpty)
              SizedBox(
                height: 320,
                child: CachedNetworkImage(
                  imageUrl: images[activeImageIndex].imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) =>
                      Container(color: AppColors.shimmerBase),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.shimmerBase,
                    child: const Icon(Icons.broken_image,
                        color: AppColors.textDisabled),
                  ),
                ),
              )
            else if (product.primaryImageUrl != null)
              SizedBox(
                height: 320,
                child: CachedNetworkImage(
                  imageUrl: product.primaryImageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) =>
                      Container(color: AppColors.shimmerBase),
                  errorWidget: (_, __, ___) =>
                      Container(color: AppColors.shimmerBase),
                ),
              ),

            const SizedBox(height: 24),

            // Colors
            if (colors.isNotEmpty) ...[
              const Text('Color',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(colors.length, (i) {
                  final c = colors[i];
                  return GestureDetector(
                    onTap: () => onColorSelected(i),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse('0xFF${c.hexCode.replaceAll('#', '')}'),
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: i == selectedColorIndex
                              ? kGold
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
            ],

            // Sizes
            if (sizes.isNotEmpty) ...[
              const Text('Size', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sizes.map((s) {
                  final inStock = isSizeInStock(s.id);
                  final selected = selectedSizeId == s.id;
                  return ChoiceChip(
                    label: Text(s.label),
                    selected: selected,
                    onSelected: inStock ? (_) => onSizeSelected(s.id) : null,
                    selectedColor: kGold.withOpacity(0.2),
                    disabledColor: AppColors.shimmerBase,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Add to cart
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canAddToCart ? onAddToCart : null,
                    icon: isAddingToCart
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.shopping_bag_outlined),
                    label: Text(isAddingToCart ? 'Adding...' : 'Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.outlined(
                  onPressed: onWishlistToggle,
                  icon: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? AppColors.saleRed : null,
                  ),
                ),
              ],
            ),

            // Related products
            if (relatedProducts.isNotEmpty) ...[
              const SizedBox(height: 40),
              const SectionHeader(
                title: 'You Might Also Like',
                eyebrow: 'Based on your interest',
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 280,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: relatedProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => SizedBox(
                    width: 180,
                    child: ProductCard(product: relatedProducts[i]),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
