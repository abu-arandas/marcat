// lib/views/customer/shop_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import 'package:marcat/controllers/shop_controller.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/models/product_model.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/empty_state.dart';
import 'shared/section_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShopPage
// ─────────────────────────────────────────────────────────────────────────────

class ShopPage extends StatelessWidget {
  const ShopPage({super.key, this.initialCategoryId});

  /// When set, pre-filters the shop to this category on first load.
  final int? initialCategoryId;

  @override
  Widget build(BuildContext context) {
    // Tag-per-category so each category keeps its own controller instance.
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
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width > 1024;
    final cols = isDesktop ? 4 : (width > 600 ? 3 : 2);

    return FB5Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section header ────────────────────────────────────────────
            const SectionHeader(
              eyebrow: 'Browse',
              title: 'All Products',
              subtitle: 'Find your perfect style.',
            ),
            const SizedBox(height: 24),

            // ── Toolbar ───────────────────────────────────────────────────
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
            const SizedBox(height: 24),

            // ── Product grid ──────────────────────────────────────────────
            Obx(() {
              final products = ctrl.products;
              final isLoading = ctrl.isLoading.value;
              final hasMore = ctrl.hasMore.value;

              if (isLoading && products.isEmpty) {
                return _LoadingGrid(cols: cols);
              }

              if (products.isEmpty) {
                return EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No Products Found',
                  subtitle:
                      'Try adjusting your filters or search for something else.',
                  actionLabel: 'Clear Filters',
                  onAction: ctrl.applyFilters,
                );
              }

              return Column(
                children: [
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
                    itemBuilder: (_, i) {
                      final product = products[i];
                      return _ShopProductCard(
                        product: product,
                        isWishlisted:
                            ctrl.wishlistedIds.contains(product.id),
                        onWishlistToggle: () =>
                            ctrl.toggleWishlist(product.id),
                      );
                    },
                  ),
                  if (hasMore) ...[
                    const SizedBox(height: 32),
                    Center(
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: kGold, strokeWidth: 2)
                          : OutlinedButton(
                              onPressed: ctrl.fetchProducts,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kNavy,
                                side: const BorderSide(color: kBorder),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Load More',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexSansArabic',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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
  final void Function({
    String? sort,
    bool? asc,
    double? minP,
    double? maxP,
    int? catId,
  }) onApplyFilters;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(
            '$productCount Products',
            style: const TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 13,
              color: kSlate,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: sortBy == 'base_price_desc' ? 'base_price_desc' : sortBy,
              style: const TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                color: kNavy,
                fontWeight: FontWeight.w600,
              ),
              borderRadius: BorderRadius.circular(8),
              items: const [
                DropdownMenuItem(value: 'created_at', child: Text('Newest')),
                DropdownMenuItem(
                  value: 'base_price',
                  child: Text('Price: Low → High'),
                ),
                DropdownMenuItem(
                  value: 'base_price_desc',
                  child: Text('Price: High → Low'),
                ),
                DropdownMenuItem(value: 'name', child: Text('Name A – Z')),
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
              // ── Image ─────────────────────────────────────────────────
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image with zoom on hover
                      AnimatedScale(
                        scale: _hovered ? 1.06 : 1.0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
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



                      // Wishlist toggle
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: widget.onWishlistToggle,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: widget.isWishlisted
                                  ? kNavy
                                  : Colors.white.withAlpha(230),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(20),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.isWishlisted
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline_rounded,
                              size: 18,
                              color: widget.isWishlisted ? Colors.white : kNavy,
                            ),
                          ),
                        ),
                      ),

                      // Quick Add overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedOpacity(
                          opacity: _hovered ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: GestureDetector(
                            onTap: () => Get.toNamed(
                              AppRoutes.productOf(widget.product.id),
                            ),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Metadata ──────────────────────────────────────────────
              const Text(
                'COLLECTION',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: kSlate,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),

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

              // Price row
              Row(
                children: [
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
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _LoadingGrid  (skeleton)
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid({required this.cols});
  final int cols;

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.65,
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

  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _minPrice = widget.initialMinPrice;
    _maxPrice = widget.initialMaxPrice;
    _minCtrl.text = _minPrice?.toStringAsFixed(3) ?? '';
    _maxCtrl.text = _maxPrice?.toStringAsFixed(3) ?? '';
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              children: [
                const Text(
                  'FILTERS',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: kNavy,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: kSlate),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: kBorder, height: 1),
          const SizedBox(height: 24),

          // ── Price range ───────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'PRICE RANGE (JOD)',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: kSlate,
                letterSpacing: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min',
                      prefixText: 'JD ',
                    ),
                    onChanged: (v) =>
                        _minPrice = double.tryParse(v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max',
                      prefixText: 'JD ',
                    ),
                    onChanged: (v) =>
                        _maxPrice = double.tryParse(v),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ── Apply button ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onApply(
                    minP: _minPrice,
                    maxP: _maxPrice,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNavy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ),
        ],
      );
}
