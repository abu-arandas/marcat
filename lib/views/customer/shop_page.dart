// lib/views/customer/shop_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';
import 'package:marcat/models/product_model.dart';
import 'package:marcat/controllers/product_controller.dart';
import 'package:marcat/controllers/auth_controller.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/empty_state.dart';
import 'package:marcat/core/router/app_router.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  ShopController
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ShopController extends GetxController {
  ShopController({this.initialCategoryId});
  final int? initialCategoryId;

  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final hasMore = true.obs;
  final wishlistedIds = <int>{}.obs;

  final sortBy = 'created_at'.obs;
  final ascending = false.obs;
  final minPrice = Rxn<double>();
  final maxPrice = Rxn<double>();
  final selectedCategoryId = Rxn<int>();
  final searchQuery = ''.obs;

  int _page = 0;
  static const _pageSize = 20;

  ProductController get _productCtrl => Get.find<ProductController>();

  @override
  void onInit() {
    super.onInit();
    // Apply initial category filter if provided (e.g. from category page)
    if (initialCategoryId != null) {
      selectedCategoryId.value = initialCategoryId;
    }
    fetchProducts(reset: true);
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final user = Get.find<AuthController>().state.value.user;
    if (user == null) return;
    try {
      final items = _productCtrl.wishlistItems;
      wishlistedIds.value = items.map((w) => w.productId).toSet();
    } catch (_) {}
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (reset) {
      _page = 0;
      products.clear();
      hasMore.value = true;
    }
    if (!hasMore.value) return;
    isLoading.value = true;
    try {
      final (items, total) = await _productCtrl.fetchProducts(
        page: _page,
        pageSize: _pageSize,
        query: searchQuery.value.isEmpty ? null : searchQuery.value,
        categoryId: selectedCategoryId.value,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        sortBy: sortBy.value,
        ascending: ascending.value,
      );
      products.addAll(items);
      _page++;
      hasMore.value = products.length < total;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters({
    String? sort,
    bool? asc,
    double? minP,
    double? maxP,
    int? catId,
  }) {
    sortBy.value = sort ?? sortBy.value;
    ascending.value = asc ?? ascending.value;
    minPrice.value = minP;
    maxPrice.value = maxP;
    selectedCategoryId.value = catId;
    fetchProducts(reset: true);
  }

  void search(String q) {
    searchQuery.value = q;
    fetchProducts(reset: true);
  }

  Future<void> toggleWishlist(int productId) async {
    final user = Get.find<AuthController>().state.value.user;
    if (user == null) {
      Get.toNamed(AppRoutes.login);
      return;
    }
    try {
      if (wishlistedIds.contains(productId)) {
        await _productCtrl.removeFromWishlist(user.id, productId);
        wishlistedIds.remove(productId);
      } else {
        await _productCtrl.addToWishlist(user.id, productId);
        wishlistedIds.add(productId);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  ShopPage
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ShopPage extends StatefulWidget {
  const ShopPage({super.key, this.initialCategoryId});

  /// When set, the shop will be pre-filtered to this category on first load.
  final int? initialCategoryId;

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final products = <ProductModel>[];
  bool isLoading = false;
  bool hasMore = true;
  final wishlistedIds = <int>{};

  String sortBy = 'created_at';
  bool ascending = false;
  double? minPrice;
  double? maxPrice;
  int? selectedCategoryId;
  String searchQuery = '';

  int _page = 0;
  static const _pageSize = 20;

  ProductController get _productCtrl => Get.find<ProductController>();
  AuthController get _auth => Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategoryId != null) {
      selectedCategoryId = widget.initialCategoryId;
    }
    fetchProducts(reset: true);
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final user = _auth.user;
    if (user == null) return;
    try {
      final items = _productCtrl.wishlistItems;
      if (mounted) {
        setState(() {
          wishlistedIds.clear();
          wishlistedIds.addAll(items.map((w) => w.productId));
        });
      }
    } catch (_) {}
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (reset) {
      _page = 0;
      products.clear();
      hasMore = true;
    }
    if (!hasMore) return;
    if (mounted) setState(() => isLoading = true);
    try {
      final (items, total) = await _productCtrl.fetchProducts(
        page: _page,
        pageSize: _pageSize,
        query: searchQuery.isEmpty ? null : searchQuery,
        categoryId: selectedCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        ascending: ascending,
      );
      if (mounted) {
        setState(() {
          products.addAll(items);
          _page++;
          hasMore = products.length < total;
        });
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void applyFilters({
    String? sort,
    bool? asc,
    double? minP,
    double? maxP,
    int? catId,
  }) {
    setState(() {
      sortBy = sort ?? sortBy;
      ascending = asc ?? ascending;
      minPrice = minP;
      maxPrice = maxP;
      selectedCategoryId = catId;
    });
    fetchProducts(reset: true);
  }

  void search(String q) {
    setState(() {
      searchQuery = q;
    });
    fetchProducts(reset: true);
  }

  Future<void> toggleWishlist(int productId) async {
    final user = _auth.user;
    if (user == null) {
      Get.toNamed(AppRoutes.login);
      return;
    }
    try {
      if (wishlistedIds.contains(productId)) {
        await _productCtrl.removeFromWishlist(user.id, productId);
        if (mounted) {
          setState(() {
            wishlistedIds.remove(productId);
          });
        }
      } else {
        await _productCtrl.addToWishlist(user.id, productId);
        if (mounted) {
          setState(() {
            wishlistedIds.add(productId);
          });
        }
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomerScaffold(
      page: 'Shop',
      pageImage:
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=1600&q=80',
      filterDrawer: _FilterDrawerContent(
        onApply: applyFilters,
        initialMinPrice: minPrice,
        initialMaxPrice: maxPrice,
        initialCategoryId: selectedCategoryId,
      ),
      body: _ShopBody(
        products: products,
        isLoading: isLoading,
        hasMore: hasMore,
        sortBy: sortBy,
        wishlistedIds: wishlistedIds,
        onFetchMore: fetchProducts,
        onApplyFilters: applyFilters,
        onToggleWishlist: toggleWishlist,
      ),
    );
  }
}

// â”€â”€â”€ Shop Body â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ShopBody extends StatelessWidget {
  final List<ProductModel> products;
  final bool isLoading;
  final bool hasMore;
  final String sortBy;
  final Set<int> wishlistedIds;
  final VoidCallback onFetchMore;
  final Function({String? sort, bool? asc, double? minP, double? maxP, int? catId}) onApplyFilters;
  final Function(int) onToggleWishlist;

  const _ShopBody({
    required this.products,
    required this.isLoading,
    required this.hasMore,
    required this.sortBy,
    required this.wishlistedIds,
    required this.onFetchMore,
    required this.onApplyFilters,
    required this.onToggleWishlist,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 1024;

    return FB5Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // â”€â”€ Toolbar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _ShopToolbar(
              productCount: products.length,
              sortBy: sortBy,
              onApplyFilters: onApplyFilters,
            ),
            const SizedBox(height: 32),

            // â”€â”€ Product grid â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Builder(builder: (context) {
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
                  onAction: () => onApplyFilters(),
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
                      childAspectRatio: 0.62,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) {
                      final p = products[i];
                      return _ShopProductCard(
                        product: p,
                        isWishlisted: wishlistedIds.contains(p.id),
                        onWishlistToggle: () => onToggleWishlist(p.id),
                      );
                    },
                  ),
                  if (hasMore) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: OutlinedButton(
                        onPressed: onFetchMore,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kNavy,
                          side: const BorderSide(color: kNavy),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: kNavy))
                            : const Text('Load More',
                                style: TextStyle(fontWeight: FontWeight.w700)),
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

// â”€â”€â”€ Toolbar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ShopToolbar extends StatelessWidget {
  final int productCount;
  final String sortBy;
  final Function({String? sort, bool? asc, double? minP, double? maxP, int? catId}) onApplyFilters;

  const _ShopToolbar({
    required this.productCount,
    required this.sortBy,
    required this.onApplyFilters,
  });

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
          // Sort dropdown
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

// â”€â”€â”€ Shop Product Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ShopProductCard extends StatefulWidget {
  final ProductModel product;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;
  const _ShopProductCard({
    required this.product,
    required this.isWishlisted,
    required this.onWishlistToggle,
  });

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
          onTap: () => Get.toNamed('/app/product/${widget.product.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(fit: StackFit.expand, children: [
                    AnimatedScale(
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

                    // Wishlist
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

                    // Quick add
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        opacity: _hovered ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
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
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'COLLECTION',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: kSlate,
                    letterSpacing: 1.5),
              ),
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
              Text(
                'JOD ${widget.product.basePrice.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: kNavy),
              ),
            ],
          ),
        ),
      );
}

// â”€â”€â”€ Loading skeleton grid â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _LoadingGrid extends StatelessWidget {
  final int cols;
  const _LoadingGrid({required this.cols});

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
          childAspectRatio: 0.62,
        ),
        itemCount: 8,
        itemBuilder: (_, __) => Column(
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
            const SizedBox(height: 12),
            Container(width: 60, height: 10, color: kCream),
            const SizedBox(height: 6),
            Container(height: 14, color: kCream),
            const SizedBox(height: 4),
            Container(width: 80, height: 14, color: kCream),
          ],
        ),
      );
}

// â”€â”€â”€ Filter Drawer Content â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _FilterDrawerContent extends StatefulWidget {
  final Function({String? sort, bool? asc, double? minP, double? maxP, int? catId}) onApply;
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final int? initialCategoryId;

  const _FilterDrawerContent({
    required this.onApply,
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialCategoryId,
  });

  @override
  State<_FilterDrawerContent> createState() => _FilterDrawerContentState();
}

class _FilterDrawerContentState extends State<_FilterDrawerContent> {
  late double _minP;
  late double _maxP;
  int? _catId;

  @override
  void initState() {
    super.initState();
    _minP = widget.initialMinPrice ?? 0;
    _maxP = widget.initialMaxPrice ?? 500;
    _catId = widget.initialCategoryId;
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // â”€â”€ Price range â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          const Text(
            'PRICE RANGE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kSlate,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('JOD ${_minP.toInt()}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: kNavy)),
              const Spacer(),
              Text('JOD ${_maxP.toInt()}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: kNavy)),
            ],
          ),
          RangeSlider(
            values: RangeValues(_minP, _maxP),
            min: 0,
            max: 500,
            divisions: 50,
            activeColor: kNavy,
            inactiveColor: kCream,
            onChanged: (v) => setState(() {
              _minP = v.start;
              _maxP = v.end;
            }),
          ),

          const SizedBox(height: 24),

          // â”€â”€ Category â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          const Text(
            'CATEGORY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kSlate,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildCategoryChips(),

          const SizedBox(height: 32),

          // Apply button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(
                  minP: _minP > 0 ? _minP : null,
                  maxP: _maxP < 500 ? _maxP : null,
                  catId: _catId,
                );
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Apply Filters',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _minP = 0;
                  _maxP = 500;
                  _catId = null;
                });
                widget.onApply();
                Get.back();
              },
              style: TextButton.styleFrom(foregroundColor: kSlate),
              child: const Text('Clear All',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );

  List<Widget> _buildCategoryChips() {
    const cats = [
      (id: 1, label: 'Women'),
      (id: 2, label: 'Men'),
      (id: 3, label: 'Kids'),
      (id: 4, label: 'Sale'),
    ];
    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: cats.map((c) {
          final isSelected = _catId == c.id;
          return GestureDetector(
            onTap: () => setState(() => _catId = isSelected ? null : c.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? kNavy : kCream,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? kNavy : kBorderColor),
              ),
              child: Text(
                c.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : kNavy,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ];
  }
}
