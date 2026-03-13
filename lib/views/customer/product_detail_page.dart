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

import '../../models/enums.dart';
import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'shared/empty_state.dart';
import 'shared/product_card.dart';
import 'shared/section_header.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';

// ──────────────────────────────────────────────────────────────────────────────
//  ProductDetailPage
// ──────────────────────────────────────────────────────────────────────────────

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

  // -- Repositories --
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
    productId = int.parse(Get.parameters['id']!);
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Fire product, colours, sizes and images in parallel
      final results = await Future.wait([
        _productCtrl.fetchProductById(productId),
        _productCtrl.fetchColors(productId),
        _productCtrl.fetchSizes(productId),
        _productCtrl.fetchImages(productId),
      ]);

      if (!mounted) return;

      setState(() {
        product = results[0] as ProductModel;
        colors = results[1] as List<ProductColorModel>;
        sizes = results[2] as List<ProductSizeModel>;
        images = results[3] as List<ProductImageModel>;
      });

      // Availability is fetched separately
      try {
        final inventoryList =
            await _productCtrl.fetchProductAvailability(productId);
        final stockMap = <int, int>{};
        for (final inv in inventoryList) {
          final qty = inv.available - inv.reserved;
          stockMap[inv.productSizeId] =
              (stockMap[inv.productSizeId] ?? 0) + qty;
        }
        if (mounted) setState(() => stockBySizeId = stockMap);
      } catch (_) {
        if (mounted) {
          setState(() {
            stockBySizeId = {
              for (final s in sizes) s.id: 99,
            };
          });
        }
      }

      // Auto-select first in-stock size
      if (sizes.isNotEmpty && mounted) {
        final firstInStock = sizes.firstWhereOrNull(
          (s) => isSizeInStock(s.id),
        );
        setState(() => selectedSizeId = firstInStock?.id ?? sizes.first.id);
      }

      // Check wishlist status
      _checkWishlist();

      // Load related products
      _loadRelated();
    } catch (e) {
      if (mounted) setState(() => errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _checkWishlist() async {
    final uid = _userId;
    if (uid == null) return;
    try {
      final inWishlist = await _productCtrl.checkIsInWishlist(uid, productId);
      if (mounted) setState(() => isWishlisted = inWishlist);
    } catch (e) {
      debugPrint('[ProductDetail] checkWishlist error: $e');
    }
  }

  Future<void> _loadRelated() async {
    final cat = product?.categoryId;
    if (cat == null) return;
    try {
      final (items, _) = await _productCtrl.fetchProducts(
        categoryId: cat,
        pageSize: 5,
      );
      if (mounted) {
        setState(() {
          relatedProducts =
              items.where((p) => p.id != productId).take(4).toList();
        });
      }
    } catch (e) {
      debugPrint('[ProductDetail] loadRelated error: $e');
    }
  }

  void selectColor(int index) {
    setState(() {
      selectedColorIndex = index;
      activeImageIndex = 0;
    });
  }

  void selectSize(int sizeId) {
    setState(() => selectedSizeId = sizeId);
  }

  void incrementQuantity() {
    final maxQty = stockBySizeId[selectedSizeId!] ?? 10;
    if (quantity < maxQty) setState(() => quantity++);
  }

  void decrementQuantity() {
    if (quantity > 1) setState(() => quantity--);
  }

  Future<void> toggleWishlist() async {
    final uid = _userId;
    if (uid == null) {
      Get.toNamed(AppRoutes.login);
      return;
    }
    try {
      if (isWishlisted) {
        await _productCtrl.removeFromWishlist(uid, productId);
        if (mounted) setState(() => isWishlisted = false);
        Get.snackbar(
          'Removed',
          'Item removed from your wishlist.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.surfaceWhite,
          colorText: AppColors.marcatNavy,
          duration: const Duration(seconds: 2),
        );
      } else {
        await _productCtrl.addToWishlist(uid, productId);
        if (mounted) setState(() => isWishlisted = true);
        Get.snackbar(
          'Saved to Wishlist',
          '${product?.name ?? 'Item'} added to your wishlist.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: kNavy,
          colorText: Colors.white,
          icon: const Icon(Icons.favorite_rounded, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> addToCart() async {
    final p = product;
    final sizeId = selectedSizeId;
    if (p == null || sizeId == null) return;

    final selectedSize = sizes.firstWhereOrNull((s) => s.id == sizeId);
    final color = selectedColor;

    setState(() => isAddingToCart = true);
    try {
      _cart.addItem(CartItemModel(
        productSizeId: sizeId,
        productId: p.id,
        productName: p.name,
        sizeLabel: selectedSize?.label ?? '',
        colorName: color?.name ?? '',
        colorId: color?.id ?? 0,
        primaryImageUrl: p.primaryImageUrl,
        unitPrice: p.basePrice,
        quantity: quantity,
      ));

      // Brief delay for visual feedback
      await Future.delayed(const Duration(milliseconds: 400));

      Get.snackbar(
        'Added to Bag',
        '${p.name} — ${selectedSize?.label ?? ''} has been added.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: kNavy,
        colorText: Colors.white,
        icon:
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
        mainButton: TextButton(
          onPressed: () => Get.toNamed(AppRoutes.cart),
          child: const Text(
            'VIEW BAG',
            style: TextStyle(
              color: kGold,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => isAddingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomerScaffold(
      page: 'Product',
      body: _ProductBody(
        isLoading: isLoading,
        errorMessage: errorMessage,
        product: product,
        colors: colors,
        sizes: sizes,
        images: images,
        relatedProducts: relatedProducts,
        stockBySizeId: stockBySizeId,
        selectedColorIndex: selectedColorIndex,
        selectedSizeId: selectedSizeId,
        quantity: quantity,
        activeImageIndex: activeImageIndex,
        isWishlisted: isWishlisted,
        isAddingToCart: isAddingToCart,
        activeTab: activeTab,
        onReload: _loadAll,
        onSelectColor: selectColor,
        onSelectSize: selectSize,
        onIncrementQuantity: incrementQuantity,
        onDecrementQuantity: decrementQuantity,
        onToggleWishlist: toggleWishlist,
        onAddToCart: addToCart,
        onTabChanged: (index) => setState(() => activeTab = index),
        onImageIndexChanged: (index) => setState(() => activeImageIndex = index),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  _ProductBody
// ──────────────────────────────────────────────────────────────────────────────

class _ProductBody extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final ProductModel? product;
  final List<ProductColorModel> colors;
  final List<ProductSizeModel> sizes;
  final List<ProductImageModel> images;
  final List<ProductModel> relatedProducts;
  final Map<int, int> stockBySizeId;
  final int selectedColorIndex;
  final int? selectedSizeId;
  final int quantity;
  final int activeImageIndex;
  final bool isWishlisted;
  final bool isAddingToCart;
  final int activeTab;
  final VoidCallback onReload;
  final Function(int) onSelectColor;
  final Function(int) onSelectSize;
  final VoidCallback onIncrementQuantity;
  final VoidCallback onDecrementQuantity;
  final VoidCallback onToggleWishlist;
  final VoidCallback onAddToCart;
  final Function(int) onTabChanged;
  final Function(int) onImageIndexChanged;

  const _ProductBody({
    required this.isLoading,
    required this.errorMessage,
    required this.product,
    required this.colors,
    required this.sizes,
    required this.images,
    required this.relatedProducts,
    required this.stockBySizeId,
    required this.selectedColorIndex,
    required this.selectedSizeId,
    required this.quantity,
    required this.activeImageIndex,
    required this.isWishlisted,
    required this.isAddingToCart,
    required this.activeTab,
    required this.onReload,
    required this.onSelectColor,
    required this.onSelectSize,
    required this.onIncrementQuantity,
    required this.onDecrementQuantity,
    required this.onToggleWishlist,
    required this.onAddToCart,
    required this.onTabChanged,
    required this.onImageIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _LoadingSkeleton();
    }

    if (errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Something Went Wrong',
        subtitle: errorMessage,
        actionLabel: 'Try Again',
        onAction: onReload,
      );
    }

    final p = product;
    if (p == null) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Product Not Found',
        subtitle: 'This product may have been removed or is unavailable.',
        actionLabel: 'Browse Shop',
        onAction: () => Get.toNamed(AppRoutes.shop),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _Breadcrumb(product: p),
        const SizedBox(height: 24),
        _MainSection(
          product: p,
          colors: colors,
          sizes: sizes,
          images: images,
          stockBySizeId: stockBySizeId,
          selectedColorIndex: selectedColorIndex,
          selectedSizeId: selectedSizeId,
          quantity: quantity,
          activeImageIndex: activeImageIndex,
          isWishlisted: isWishlisted,
          isAddingToCart: isAddingToCart,
          onSelectColor: onSelectColor,
          onSelectSize: onSelectSize,
          onIncrementQuantity: onIncrementQuantity,
          onDecrementQuantity: onDecrementQuantity,
          onToggleWishlist: onToggleWishlist,
          onAddToCart: onAddToCart,
          onImageIndexChanged: onImageIndexChanged,
        ),
        const SizedBox(height: 64),
        _ProductTabs(
          product: p,
          activeTab: activeTab,
          onTabChanged: onTabChanged,
        ),
        const SizedBox(height: 72),
        _RelatedProducts(
          relatedProducts: relatedProducts,
          onProductTap: (id) => Get.toNamed('/app/product/$id'),
        ),
        const SizedBox(height: 72),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Breadcrumb
// ──────────────────────────────────────────────────────────────────────────────

class _Breadcrumb extends StatelessWidget {
  final ProductModel product;
  const _Breadcrumb({required this.product});

  @override
  Widget build(BuildContext context) => FB5Container(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            _BreadcrumbItem(
                label: 'Home', onTap: () => Get.toNamed(AppRoutes.home)),
            const _BreadcrumbSep(),
            _BreadcrumbItem(
                label: 'Shop', onTap: () => Get.toNamed(AppRoutes.shop)),
            const _BreadcrumbSep(),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 12,
                color: kNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}

class _BreadcrumbItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _BreadcrumbItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: kSlate,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
}

class _BreadcrumbSep extends StatelessWidget {
  const _BreadcrumbSep();
  @override
  Widget build(BuildContext context) => const Icon(
        Icons.chevron_right_rounded,
        size: 14,
        color: kSlate,
      );
}

// ──────────────────────────────────────────────────────────────────────────────
//  Main Section (image gallery + product info)
// ──────────────────────────────────────────────────────────────────────────────

class _MainSection extends StatelessWidget {
  final ProductModel product;
  final List<ProductColorModel> colors;
  final List<ProductSizeModel> sizes;
  final List<ProductImageModel> images;
  final Map<int, int> stockBySizeId;
  final int selectedColorIndex;
  final int? selectedSizeId;
  final int quantity;
  final int activeImageIndex;
  final bool isWishlisted;
  final bool isAddingToCart;
  final Function(int) onSelectColor;
  final Function(int) onSelectSize;
  final VoidCallback onIncrementQuantity;
  final VoidCallback onDecrementQuantity;
  final VoidCallback onToggleWishlist;
  final VoidCallback onAddToCart;
  final Function(int) onImageIndexChanged;

  const _MainSection({
    required this.product,
    required this.colors,
    required this.sizes,
    required this.images,
    required this.stockBySizeId,
    required this.selectedColorIndex,
    required this.selectedSizeId,
    required this.quantity,
    required this.activeImageIndex,
    required this.isWishlisted,
    required this.isAddingToCart,
    required this.onSelectColor,
    required this.onSelectSize,
    required this.onIncrementQuantity,
    required this.onDecrementQuantity,
    required this.onToggleWishlist,
    required this.onAddToCart,
    required this.onImageIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 900;

    return FB5Container(
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 55,
                  child: _DesktopGallery(
                    product: product,
                    images: images,
                    activeImageIndex: activeImageIndex,
                    onImageIndexChanged: onImageIndexChanged,
                  ),
                ),
                const SizedBox(width: 56),
                Expanded(
                  flex: 45,
                  child: _ProductInfo(
                    product: product,
                    colors: colors,
                    sizes: sizes,
                    stockBySizeId: stockBySizeId,
                    selectedColorIndex: selectedColorIndex,
                    selectedSizeId: selectedSizeId,
                    quantity: quantity,
                    isWishlisted: isWishlisted,
                    isAddingToCart: isAddingToCart,
                    onSelectColor: onSelectColor,
                    onSelectSize: onSelectSize,
                    onIncrementQuantity: onIncrementQuantity,
                    onDecrementQuantity: onDecrementQuantity,
                    onToggleWishlist: onToggleWishlist,
                    onAddToCart: onAddToCart,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MobileCarousel(
                  product: product,
                  images: images,
                  activeImageIndex: activeImageIndex,
                  onImageIndexChanged: onImageIndexChanged,
                ),
                const SizedBox(height: 32),
                _ProductInfo(
                  product: product,
                  colors: colors,
                  sizes: sizes,
                  stockBySizeId: stockBySizeId,
                  selectedColorIndex: selectedColorIndex,
                  selectedSizeId: selectedSizeId,
                  quantity: quantity,
                  isWishlisted: isWishlisted,
                  isAddingToCart: isAddingToCart,
                  onSelectColor: onSelectColor,
                  onSelectSize: onSelectSize,
                  onIncrementQuantity: onIncrementQuantity,
                  onDecrementQuantity: onDecrementQuantity,
                  onToggleWishlist: onToggleWishlist,
                  onAddToCart: onAddToCart,
                ),
              ],
            ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Desktop Gallery
// ──────────────────────────────────────────────────────────────────────────────

class _DesktopGallery extends StatelessWidget {
  final ProductModel product;
  final List<ProductImageModel> images;
  final int activeImageIndex;
  final Function(int) onImageIndexChanged;

  const _DesktopGallery({
    required this.product,
    required this.images,
    required this.activeImageIndex,
    required this.onImageIndexChanged,
  });

  List<String> _allImages() {
    final fromImages = images.map((i) => i.imageUrl).toList();
    if (fromImages.isEmpty && product.primaryImageUrl != null) {
      return [product.primaryImageUrl!];
    }
    return fromImages;
  }

  @override
  Widget build(BuildContext context) {
    final imgs = _allImages();
    final active = activeImageIndex.clamp(0, (imgs.length - 1).clamp(0, 999));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imgs.length > 1)
          Column(
            children: List.generate(imgs.length, (i) {
              final isActive = i == active;
              return GestureDetector(
                onTap: () => onImageIndexChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  width: 72,
                  height: 88,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isActive ? kNavy : kBorderColor,
                      width: isActive ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: CachedNetworkImage(
                      imageUrl: imgs[i],
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: kCream),
                      errorWidget: (_, __, ___) => Container(color: kCream),
                    ),
                  ),
                ),
              );
            }),
          ),
        if (imgs.length > 1) const SizedBox(width: 16),
        Expanded(
          child: _ZoomableImage(
            imageUrl: imgs.isNotEmpty
                ? imgs[active]
                : (product.primaryImageUrl ?? ''),
            productName: product.name,
          ),
        ),
      ],
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  final String imageUrl;
  final String productName;
  const _ZoomableImage({required this.imageUrl, required this.productName});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  bool _hovered = false;

  void _openFullscreen() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.zoomIn,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: _openFullscreen,
          child: AspectRatio(
            aspectRatio: 0.72,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AnimatedScale(
                scale: _hovered ? 1.07 : 1.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: kCream),
                  errorWidget: (_, __, ___) => Container(
                    color: kCream,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.image_outlined, color: kSlate, size: 48),
                        SizedBox(height: 8),
                        Text('Image unavailable',
                            style: TextStyle(color: kSlate, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

// ──────────────────────────────────────────────────────────────────────────────
//  Mobile Carousel
// ──────────────────────────────────────────────────────────────────────────────

class _MobileCarousel extends StatelessWidget {
  final ProductModel product;
  final List<ProductImageModel> images;
  final int activeImageIndex;
  final Function(int) onImageIndexChanged;

  const _MobileCarousel({
    required this.product,
    required this.images,
    required this.activeImageIndex,
    required this.onImageIndexChanged,
  });

  List<String> _allImages() {
    final fromImages = images.map((i) => i.imageUrl).toList();
    if (fromImages.isEmpty && product.primaryImageUrl != null) {
      return [product.primaryImageUrl!];
    }
    return fromImages;
  }

  @override
  Widget build(BuildContext context) {
    final imgs = _allImages();
    if (imgs.isEmpty) {
      return AspectRatio(
        aspectRatio: 0.9,
        child: Container(
          color: kCream,
          child: const Center(
            child: Icon(Icons.image_outlined, color: kSlate, size: 48),
          ),
        ),
      );
    }

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 0.9,
          child: PageView.builder(
            itemCount: imgs.length,
            onPageChanged: onImageIndexChanged,
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: imgs[i],
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: kCream),
              errorWidget: (_, __, ___) => Container(color: kCream),
            ),
          ),
        ),
        if (imgs.length > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kNavy.withOpacity(0.75),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${activeImageIndex + 1} / ${imgs.length}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        if (imgs.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imgs.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: activeImageIndex == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: activeImageIndex == i ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Product Info Panel
// ──────────────────────────────────────────────────────────────────────────────

class _ProductInfo extends StatelessWidget {
  final ProductModel product;
  final List<ProductColorModel> colors;
  final List<ProductSizeModel> sizes;
  final Map<int, int> stockBySizeId;
  final int selectedColorIndex;
  final int? selectedSizeId;
  final int quantity;
  final bool isWishlisted;
  final bool isAddingToCart;
  final Function(int) onSelectColor;
  final Function(int) onSelectSize;
  final VoidCallback onIncrementQuantity;
  final VoidCallback onDecrementQuantity;
  final VoidCallback onToggleWishlist;
  final VoidCallback onAddToCart;

  const _ProductInfo({
    required this.product,
    required this.colors,
    required this.sizes,
    required this.stockBySizeId,
    required this.selectedColorIndex,
    required this.selectedSizeId,
    required this.quantity,
    required this.isWishlisted,
    required this.isAddingToCart,
    required this.onSelectColor,
    required this.onSelectSize,
    required this.onIncrementQuantity,
    required this.onDecrementQuantity,
    required this.onToggleWishlist,
    required this.onAddToCart,
  });

  bool isSizeInStock(int sizeId) => (stockBySizeId[sizeId] ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    final canAddToCart = selectedSizeId != null &&
        isSizeInStock(selectedSizeId!) &&
        !isAddingToCart;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.status == ProductStatus.active) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            color: kNavy,
            child: const Text(
              'NEW ARRIVAL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          product.name,
          style: const TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: kNavy,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'SKU: ${product.sku}',
          style: const TextStyle(
              fontSize: 11, color: kSlate, letterSpacing: 0.5),
        ),
        const SizedBox(height: 16),
        Text(
          product.basePrice.toJOD(),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: kNavy,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Including VAT · Free delivery over JOD 50',
          style: TextStyle(fontSize: 12, color: kSlate),
        ),
        const SizedBox(height: 24),
        const Divider(color: kBorderColor, height: 1),
        const SizedBox(height: 24),
        if (colors.isNotEmpty) ...[
          _ColorPicker(
            colors: colors,
            selectedColorIndex: selectedColorIndex,
            onSelectColor: onSelectColor,
          ),
          const SizedBox(height: 24),
        ],
        if (sizes.isNotEmpty) ...[
          _SizePicker(
            sizes: sizes,
            selectedSizeId: selectedSizeId,
            stockBySizeId: stockBySizeId,
            onSelectSize: onSelectSize,
          ),
          const SizedBox(height: 24),
        ],
        _QuantityStepper(
          quantity: quantity,
          onIncrement: onIncrementQuantity,
          onDecrement: onDecrementQuantity,
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: canAddToCart ? onAddToCart : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: kNavy,
              foregroundColor: Colors.white,
              disabledBackgroundColor: kNavy.withOpacity(0.35),
              minimumSize: const Size(double.infinity, 54),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 2,
              ),
            ),
            child: isAddingToCart
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    selectedSizeId == null ? 'SELECT A SIZE' : 'ADD TO BAG',
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: onToggleWishlist,
            icon: Icon(
              isWishlisted
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded,
              size: 18,
              color: isWishlisted ? kRed : kNavy,
            ),
            label: Text(
              isWishlisted ? 'SAVED TO WISHLIST' : 'SAVE TO WISHLIST',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: kNavy,
              side: const BorderSide(color: kBorderColor, width: 1.5),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const _TrustBadges(),
        const SizedBox(height: 24),
        const Divider(color: kBorderColor, height: 1),
        const SizedBox(height: 16),
        _QuickAccordion(
          icon: Icons.local_shipping_outlined,
          title: 'Delivery & Returns',
          child: const Text(
            'Free standard delivery on orders over JOD 50. Express delivery '
            'available at checkout. Returns accepted within 30 days — '
            'items must be unworn and in original packaging.',
            style: TextStyle(fontSize: 13, color: kSlate, height: 1.7),
          ),
        ),
        const Divider(color: kBorderColor, height: 1),
        _QuickAccordion(
          icon: Icons.lock_outline_rounded,
          title: 'Secure Payment',
          child: const Text(
            'All transactions are encrypted with SSL. We accept Visa, '
            'Mastercard, and cash on delivery.',
            style: TextStyle(fontSize: 13, color: kSlate, height: 1.7),
          ),
        ),
        const Divider(color: kBorderColor, height: 1),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Color Picker
// ──────────────────────────────────────────────────────────────────────────────

class _ColorPicker extends StatelessWidget {
  final List<ProductColorModel> colors;
  final int selectedColorIndex;
  final Function(int) onSelectColor;

  const _ColorPicker({
    required this.colors,
    required this.selectedColorIndex,
    required this.onSelectColor,
  });

  Color _parseHex(String hex) {
    try {
      final h = hex.replaceAll('#', '').trim();
      if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
      if (h.length == 8) return Color(int.parse(h, radix: 16));
    } catch (_) {}
    return kSlate;
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'COLOUR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kSlate,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 12, color: kBorderColor),
              const SizedBox(width: 8),
              Text(
                colors.isEmpty ? '' : colors[selectedColorIndex].name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              colors.length,
              (i) {
                final color = colors[i];
                final isSelected = i == selectedColorIndex;
                final parsed = _parseHex(color.hexCode);

                return GestureDetector(
                  onTap: () => onSelectColor(i),
                  child: Tooltip(
                    message: color.name,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: parsed,
                        border: Border.all(
                          color: isSelected ? kNavy : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: parsed.computeLuminance() > 0.5
                                  ? kNavy
                                  : Colors.white,
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
}

// ──────────────────────────────────────────────────────────────────────────────
//  Size Picker
// ──────────────────────────────────────────────────────────────────────────────

class _SizePicker extends StatelessWidget {
  final List<ProductSizeModel> sizes;
  final int? selectedSizeId;
  final Map<int, int> stockBySizeId;
  final Function(int) onSelectSize;

  const _SizePicker({
    required this.sizes,
    required this.selectedSizeId,
    required this.stockBySizeId,
    required this.onSelectSize,
  });

  bool isSizeInStock(int sizeId) => (stockBySizeId[sizeId] ?? 0) > 0;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'SIZE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kSlate,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showSizeGuide(context),
                child: const Row(
                  children: [
                    Icon(Icons.straighten_outlined, size: 14, color: kSlate),
                    SizedBox(width: 4),
                    Text(
                      'Size Guide',
                      style: TextStyle(
                        fontSize: 12,
                        color: kSlate,
                        decoration: TextDecoration.underline,
                        decorationColor: kSlate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sizes.map((size) {
              final isSelected = selectedSizeId == size.id;
              final inStock = isSizeInStock(size.id);

              return GestureDetector(
                onTap: inStock ? () => onSelectSize(size.id) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 52,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? kNavy : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? kNavy
                          : inStock
                              ? kBorderColor
                              : kBorderColor.withOpacity(0.5),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        size.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : inStock
                                  ? kNavy
                                  : kSlate.withOpacity(0.45),
                        ),
                      ),
                      if (!inStock)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _StrikethroughPainter(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          if (stockBySizeId.isNotEmpty &&
              sizes.any((s) => !isSizeInStock(s.id)))
            const Text(
              '✕ Out of stock',
              style: TextStyle(fontSize: 11, color: kSlate),
            ),
        ],
      );

  void _showSizeGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _SizeGuideSheet(),
    );
  }
}

class _StrikethroughPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kSlate.withOpacity(0.3)
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(8, size.height - 8), Offset(size.width - 8, 8), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SizeGuideSheet extends StatelessWidget {
  const _SizeGuideSheet();

  static const _rows = [
    ['XS', '6-8', '32-34"', '24-26"'],
    ['S', '8-10', '34-36"', '26-28"'],
    ['M', '10-12', '36-38"', '28-30"'],
    ['L', '12-14', '38-40"', '30-32"'],
    ['XL', '14-16', '40-42"', '32-34"'],
    ['XXL', '16-18', '42-44"', '34-36"'],
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Size Guide',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kNavy,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: kCream,
                      foregroundColor: kSlate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: kBorderColor, width: 1),
                children: [
                  const TableRow(
                    decoration: BoxDecoration(color: kNavy),
                    children: [
                      _TCell('SIZE', header: true),
                      _TCell('UK SIZE', header: true),
                      _TCell('BUST', header: true),
                      _TCell('WAIST', header: true),
                    ],
                  ),
                  ..._rows.map((r) => TableRow(
                        children: r.map((c) => _TCell(c)).toList(),
                      )),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Measurements are approximate. If between sizes, size up.',
                style: TextStyle(fontSize: 12, color: kSlate),
              ),
            ],
          ),
        ),
      );
}

class _TCell extends StatelessWidget {
  final String text;
  final bool header;
  const _TCell(this.text, {this.header = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: header ? FontWeight.w700 : FontWeight.w500,
            color: header ? Colors.white : kNavy,
            letterSpacing: header ? 0.5 : 0,
          ),
        ),
      );
}

// ──────────────────────────────────────────────────────────────────────────────
//  Quantity Stepper
// ──────────────────────────────────────────────────────────────────────────────

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUANTITY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kSlate,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: kBorderColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepButton(
                  icon: Icons.remove_rounded,
                  onPressed: quantity > 1 ? onDecrement : null,
                ),
                Container(
                  width: 52,
                  alignment: Alignment.center,
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kNavy,
                    ),
                  ),
                ),
                _StepButton(
                  icon: Icons.add_rounded,
                  onPressed: onIncrement,
                ),
              ],
            ),
          ),
        ],
      );
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _StepButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: onPressed == null ? kSlate.withOpacity(0.4) : kNavy,
          ),
        ),
      );
}

// ──────────────────────────────────────────────────────────────────────────────
//  Trust Badges
// ──────────────────────────────────────────────────────────────────────────────

class _TrustBadges extends StatelessWidget {
  const _TrustBadges();

  static const _badges = [
    (Icons.local_shipping_outlined, 'Free Delivery\nover JOD 50'),
    (Icons.replay_outlined, '30-Day\nFree Returns'),
    (Icons.verified_user_outlined, 'Secure\nCheckout'),
  ];

  @override
  Widget build(BuildContext context) => Row(
        children: _badges
            .map((b) => Expanded(
                  child: Column(
                    children: [
                      Icon(b.$1, size: 22, color: kNavy),
                      const SizedBox(height: 6),
                      Text(
                        b.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: kSlate,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      );
}

// ──────────────────────────────────────────────────────────────────────────────
//  Quick Accordion (delivery/returns, payment)
// ──────────────────────────────────────────────────────────────────────────────

class _QuickAccordion extends StatefulWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _QuickAccordion(
      {required this.icon, required this.title, required this.child});

  @override
  State<_QuickAccordion> createState() => _QuickAccordionState();
}

class _QuickAccordionState extends State<_QuickAccordion> {
  bool _open = false;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Icon(widget.icon, size: 18, color: kNavy),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kNavy,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: kSlate),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState:
                _open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 0, 14),
              child: widget.child,
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      );
}

// ──────────────────────────────────────────────────────────────────────────────
//  Product Tabs (Description / Details / Care)
// ──────────────────────────────────────────────────────────────────────────────

class _ProductTabs extends StatelessWidget {
  final ProductModel product;
  final int activeTab;
  final Function(int) onTabChanged;

  const _ProductTabs({
    required this.product,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        child: FB5Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Tab(
                      label: 'Description',
                      active: activeTab == 0,
                      onTap: () => onTabChanged(0)),
                  _Tab(
                      label: 'Details',
                      active: activeTab == 1,
                      onTap: () => onTabChanged(1)),
                  _Tab(
                      label: 'Care',
                      active: activeTab == 2,
                      onTap: () => onTabChanged(2)),
                ],
              ),
              Container(height: 1, color: kBorderColor),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _tabContent(activeTab),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );

  Widget _tabContent(int tab) {
    switch (tab) {
      case 0:
        return _DescriptionTab(key: const ValueKey(0), product: product);
      case 1:
        return _DetailsTab(key: const ValueKey(1), product: product);
      case 2:
        return _CareTab(key: const ValueKey(2));
      default:
        return const SizedBox.shrink();
    }
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 16, 28, 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? kNavy : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? kNavy : kSlate,
              letterSpacing: 0.3,
            ),
          ),
        ),
      );
}

class _DescriptionTab extends StatelessWidget {
  final ProductModel product;
  const _DescriptionTab({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 700;
    final desc = product.description?.isNotEmpty == true
        ? product.description!
        : 'A beautifully crafted piece from the MARCAT collection. '
            'Designed with care and attention to detail, this item brings '
            'together quality materials and timeless style for an '
            'effortlessly elegant look.';

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  desc,
                  style:
                      const TextStyle(fontSize: 14, color: kSlate, height: 1.9),
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 2,
                child: _DescHighlights(),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                desc,
                style:
                    const TextStyle(fontSize: 14, color: kSlate, height: 1.9),
              ),
              const SizedBox(height: 24),
              _DescHighlights(),
            ],
          );
  }
}

class _DescHighlights extends StatelessWidget {
  static const _points = [
    'Premium quality fabric',
    'Ethically sourced materials',
    'Versatile everyday style',
    'True-to-size fit',
    'Season-less design',
  ];

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HIGHLIGHTS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: kGold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          ..._points.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(right: 12, top: 2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: kGold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        p,
                        style: const TextStyle(
                            fontSize: 13, color: kSlate, height: 1.5),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      );
}

class _DetailsTab extends StatelessWidget {
  final ProductModel product;
  const _DetailsTab({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['SKU', product.sku],
      ['Category ID', product.categoryId?.toString() ?? '—'],
      ['Brand ID', product.brandId?.toString() ?? '—'],
      ['Base Price', product.basePrice.toJOD()],
      ['Status', product.status.name],
      ['Added', _formatDate(product.createdAt)],
    ];

    return SizedBox(
      width: double.infinity,
      child: Table(
        columnWidths: const {0: IntrinsicColumnWidth()},
        children: rows
            .map(
              (r) => TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: kBorderColor.withOpacity(0.6)),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      r[0].toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kNavy,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    child: Text(
                      r[1].toString(),
                      style: const TextStyle(fontSize: 13, color: kSlate),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}

class _CareTab extends StatelessWidget {
  const _CareTab({super.key});

  static const _instructions = [
    (
      Icons.local_laundry_service_outlined,
      'Machine wash cold (30°C)',
      'Turn inside out before washing'
    ),
    (
      Icons.block_outlined,
      'Do not tumble dry',
      'Air dry flat to maintain shape'
    ),
    (
      Icons.iron_outlined,
      'Cool iron if needed',
      'Iron on reverse, avoid prints or embellishments'
    ),
    (
      Icons.dry_cleaning_outlined,
      'Dry clean safe',
      'For delicate fabrics and special care garments'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 700;

    return isDesktop
        ? Wrap(
            spacing: 32,
            runSpacing: 24,
            children: _instructions
                .map((i) => SizedBox(
                      width: 260,
                      child: _CareItem(icon: i.$1, title: i.$2, subtitle: i.$3),
                    ))
                .toList(),
          )
        : Column(
            children: _instructions
                .map((i) => _CareItem(icon: i.$1, title: i.$2, subtitle: i.$3))
                .toList(),
          );
  }
}

class _CareItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _CareItem(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: kCream,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: kBorderColor),
              ),
              child: Icon(icon, size: 20, color: kNavy),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kNavy,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: kSlate, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ──────────────────────────────────────────────────────────────────────────────
//  Related Products
// ──────────────────────────────────────────────────────────────────────────────

class _RelatedProducts extends StatelessWidget {
  final List<ProductModel> relatedProducts;
  final Function(int) onProductTap;

  const _RelatedProducts({
    required this.relatedProducts,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (relatedProducts.isEmpty) return const SizedBox.shrink();

    final isDesktop = MediaQuery.sizeOf(context).width > 768;

    return FB5Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            eyebrow: 'You May Also Like',
            title: 'Related Products',
          ),
          const SizedBox(height: 36),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
              childAspectRatio: 0.58,
            ),
            itemCount: relatedProducts.length,
            itemBuilder: (_, i) => ProductCard(
              product: relatedProducts[i],
              onTap: () => onProductTap(relatedProducts[i].id),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Loading Skeleton
// ──────────────────────────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 900;

    return FB5Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 32),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 55,
                    child: Column(
                      children: [
                        SkeletonBox(height: 520),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(
                            4,
                            (_) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: SkeletonBox(height: 76),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 56),
                  Expanded(
                    flex: 45,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 80, height: 22),
                        const SizedBox(height: 16),
                        SkeletonBox(height: 38),
                        const SizedBox(height: 8),
                        SkeletonBox(width: 120, height: 20),
                        const SizedBox(height: 20),
                        SkeletonBox(width: 160, height: 32),
                        const SizedBox(height: 24),
                        SkeletonBox(height: 1),
                        const SizedBox(height: 24),
                        SkeletonBox(height: 48),
                        const SizedBox(height: 16),
                        SkeletonBox(height: 48),
                        const SizedBox(height: 16),
                        SkeletonBox(height: 54),
                        const SizedBox(height: 12),
                        SkeletonBox(height: 48),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  SkeletonBox(height: 380),
                  const SizedBox(height: 24),
                  SkeletonBox(width: 80, height: 20),
                  const SizedBox(height: 12),
                  SkeletonBox(height: 34),
                  const SizedBox(height: 8),
                  SkeletonBox(width: 140, height: 30),
                  const SizedBox(height: 20),
                  SkeletonBox(height: 48),
                  const SizedBox(height: 12),
                  SkeletonBox(height: 48),
                  const SizedBox(height: 16),
                  SkeletonBox(height: 54),
                ],
              ),
      ),
    );
  }
}
