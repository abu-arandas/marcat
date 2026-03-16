// lib/views/customer/shop_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/shop_controller.dart';
import 'package:marcat/models/product_model.dart';
import 'package:marcat/core/router/app_router.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/empty_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShopPage
// ─────────────────────────────────────────────────────────────────────────────

class ShopPage extends StatelessWidget {
  const ShopPage({super.key, this.initialCategoryId});

  /// When set, the shop will be pre-filtered to this category on first load.
  final int? initialCategoryId;

  @override
  Widget build(BuildContext context) {
    // GetX creates a new ShopController instance scoped to this page.
    // Using a tag based on the category ensures different category pages each
    // get their own controller with the correct initial filter.
    final tag = initialCategoryId?.toString() ?? 'all';
    final ctrl = Get.put(
      ShopController(initialCategoryId: initialCategoryId),
      tag: tag,
    );

    return CustomerScaffold(
      page: 'Shop',
      pageImage:
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=1600&q=80',
      filterDrawer: _FilterDrawerContent(
        onApply: ({asc, catId, maxP, minP, sort}) => ctrl.applyFilters(
          asc: asc,
          maxP: maxP,
          minP: minP,
          sort: sort,
        ),
        initialMinPrice: ctrl.minPrice.value,
        initialMaxPrice: ctrl.maxPrice.value,
        initialCategoryId: ctrl.selectedCategoryId.value,
      ),
      body: _ShopBody(ctrl: ctrl),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ShopBody
// ─────────────────────────────────────────────────────────────────────────────

class _ShopBody extends StatelessWidget {
  const _ShopBody({required this.ctrl});

  final ShopController ctrl;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 1024;

    return FB5Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Toolbar ──────────────────────────────────────────────────────
            Obx(() => _ShopToolbar(
                  productCount: ctrl.products.length,
                  sortBy: ctrl.sortBy.value,
                  onApplyFilters: ({asc, catId, maxP, minP, sort}) =>
                      ctrl.applyFilters(
                    asc: asc,
                    maxP: maxP,
                    minP: minP,
                    sort: sort,
                  ),
                )),
            const SizedBox(height: 32),

            // ── Product grid ─────────────────────────────────────────────────
            Obx(() {
              final products = ctrl.products;
              final isLoading = ctrl.isLoading.value;
              final hasMore = ctrl.hasMore.value;

              if (isLoading && products.isEmpty) {
                return _LoadingGrid(cols: isDesktop ? 4 : 2);
              }

              if (products.isEmpty) {
                return EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No Products Found',
                  subtitle:
                      'Try adjusting your filters or search for something else.',
                  actionLabel: 'Clear Filters',
                  onAction: () => ctrl.applyFilters(),
                );
              }

              return Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 4 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) {
                      final product = products[i];
                      return _ShopProductCard(
                        product: product,
                        isWishlisted: ctrl.wishlistedIds.contains(product.id),
                        onWishlistToggle: () => ctrl.toggleWishlist(product.id),
                      );
                    },
                  ),
                  if (hasMore) ...[
                    const SizedBox(height: 32),
                    Center(
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : OutlinedButton(
                              onPressed: ctrl.fetchProducts,
                              child: const Text('Load More'),
                            ),
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ShopToolbar
// ─────────────────────────────────────────────────────────────────────────────

class _ShopToolbar extends StatelessWidget {
  const _ShopToolbar({
    required this.productCount,
    required this.sortBy,
    required this.onApplyFilters,
  });

  final int productCount;
  final String sortBy;
  final void Function(
      {String? sort,
      bool? asc,
      double? minP,
      double? maxP,
      int? catId}) onApplyFilters;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(
            '$productCount Products',
            style: const TextStyle(
              fontSize: 13,
              color: kSlate,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: sortBy,
              style: const TextStyle(
                fontSize: 13,
                color: kNavy,
                fontWeight: FontWeight.w600,
              ),
              borderRadius: BorderRadius.circular(8),
              items: const [
                DropdownMenuItem(value: 'created_at', child: Text('Newest')),
                DropdownMenuItem(
                    value: 'base_price', child: Text('Price: Low to High')),
                DropdownMenuItem(
                    value: 'base_price_desc',
                    child: Text('Price: High to Low')),
                DropdownMenuItem(value: 'name', child: Text('Name A-Z')),
              ],
              onChanged: (v) {
                if (v == null) return;
                final asc = v != 'base_price_desc';
                final sort = v == 'base_price_desc' ? 'base_price' : v;
                onApplyFilters(sort: sort, asc: asc);
              },
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _ShopProductCard
// ─────────────────────────────────────────────────────────────────────────────

class _ShopProductCard extends StatefulWidget {
  const _ShopProductCard({
    required this.product,
    required this.isWishlisted,
    required this.onWishlistToggle,
  });

  final ProductModel product;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;

  @override
  State<_ShopProductCard> createState() => _ShopProductCardState();
}

class _ShopProductCardState extends State<_ShopProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.productOf(widget.product.id)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                                      color: kSlate, size: 32),
                                ),
                              )
                            : Container(
                                color: kCream,
                                child: const Icon(Icons.image_outlined,
                                    color: kSlate, size: 32),
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

                      // Quick view hover overlay
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
                                'Quick View',
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
                'JOD ${widget.product.basePrice.toStringAsFixed(2)}',
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

// ─────────────────────────────────────────────────────────────────────────────
// _LoadingGrid  — shimmer skeleton while first page is loading
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid({required this.cols});

  final int cols;

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
          childAspectRatio: 0.65,
        ),
        itemCount: cols * 2,
        itemBuilder: (_, __) => const _SkeletonCard(),
      );
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kCream,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
              width: 120,
              height: 12,
              decoration: BoxDecoration(
                  color: kCream, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 6),
          Container(
              width: 60,
              height: 12,
              decoration: BoxDecoration(
                  color: kCream, borderRadius: BorderRadius.circular(4))),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _FilterDrawerContent
// ─────────────────────────────────────────────────────────────────────────────

class _FilterDrawerContent extends StatefulWidget {
  const _FilterDrawerContent({
    required this.onApply,
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialCategoryId,
  });

  final void Function({
    String? sort,
    bool? asc,
    double? minP,
    double? maxP,
    int? catId,
  }) onApply;
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final int? initialCategoryId;

  @override
  State<_FilterDrawerContent> createState() => _FilterDrawerContentState();
}

class _FilterDrawerContentState extends State<_FilterDrawerContent> {
  late double? _minPrice;
  late double? _maxPrice;
  late int? _catId;

  @override
  void initState() {
    super.initState();
    _minPrice = widget.initialMinPrice;
    _maxPrice = widget.initialMaxPrice;
    _catId = widget.initialCategoryId;
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filters',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: kNavy)),
            const SizedBox(height: 24),

            // Min price
            const Text('Min Price (JOD)',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: kNavy)),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _minPrice?.toStringAsFixed(0),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '0'),
              onChanged: (v) => _minPrice = double.tryParse(v),
            ),
            const SizedBox(height: 16),

            // Max price
            const Text('Max Price (JOD)',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: kNavy)),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _maxPrice?.toStringAsFixed(0),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Any'),
              onChanged: (v) => _maxPrice = double.tryParse(v),
            ),
            const Spacer(),

            // Apply / Clear
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _minPrice = null;
                        _maxPrice = null;
                        _catId = null;
                      });
                      widget.onApply();
                      Get.back();
                    },
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(
                        minP: _minPrice,
                        maxP: _maxPrice,
                        catId: _catId,
                      );
                      Get.back();
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
