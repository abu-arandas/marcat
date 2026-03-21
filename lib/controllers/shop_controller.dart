// lib/controllers/shop_controller.dart

import 'package:get/get.dart';

import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/controllers/product_controller.dart';
import 'package:marcat/models/product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShopController
// ─────────────────────────────────────────────────────────────────────────────

class ShopController extends GetxController {
  ShopController({this.initialCategoryId});

  /// When non-null, the shop is pre-filtered to this category on first load.
  final int? initialCategoryId;

  // ── Observable state ─────────────────────────────────────────────────────────
  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final hasMore = true.obs;
  final wishlistedIds = <int>{}.obs;

  // ── Filter / sort state ──────────────────────────────────────────────────────
  final sortBy = 'created_at'.obs;
  final ascending = false.obs;
  final minPrice = Rxn<double>();
  final maxPrice = Rxn<double>();
  final selectedCategoryId = Rxn<int>();
  final searchQuery = ''.obs;

  // ── Pagination ───────────────────────────────────────────────────────────────
  int _page = 0;
  static const int _pageSize = 20;

  // ── Dependencies ─────────────────────────────────────────────────────────────
  ProductController get _productCtrl => Get.find<ProductController>();
  AuthController get _auth => Get.find<AuthController>();

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    if (initialCategoryId != null) {
      selectedCategoryId.value = initialCategoryId;
    }
    fetchProducts(reset: true);
    _loadWishlist();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // WISHLIST
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _loadWishlist() async {
    final user = _auth.state.value.user;
    if (user == null) return;
    try {
      // Reads the already-loaded wishlist from ProductController's memory —
      // no extra network request.
      wishlistedIds.assignAll(
        _productCtrl.wishlistItems.map((w) => w.productId).toSet(),
      );
    } catch (_) {
      // Non-critical
    }
  }

  Future<void> toggleWishlist(int productId) async {
    final user = _auth.state.value.user;
    if (user == null) return;

    try {
      final nowIn = await _productCtrl.toggleWishlist(user.id, productId);
      if (nowIn) {
        wishlistedIds.add(productId);
      } else {
        wishlistedIds.remove(productId);
      }
    } catch (_) {
      // Non-critical
    }
  }

  bool isWishlisted(int productId) => wishlistedIds.contains(productId);

  // ─────────────────────────────────────────────────────────────────────────────
  // PRODUCTS
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> fetchProducts({bool reset = false}) async {
    if (isLoading.value) return;

    if (reset) {
      _page = 0;
      hasMore.value = true;
      products.clear();
    }

    if (!hasMore.value) return;

    isLoading.value = true;

    try {
      final fetched = await _productCtrl.fetchProducts(
        page: _page,
        pageSize: _pageSize,
        categoryId: selectedCategoryId.value,
        sortBy: sortBy.value,
        ascending: ascending.value,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        query: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        updateState: false, // prevent clobbering ProductController's shared lists
      );

      if (fetched.$1.length < _pageSize) {
        hasMore.value = false;
      }

      if (reset) {
        products.assignAll(fetched.$1);
      } else {
        products.addAll(fetched.$1);
      }

      _page++;
    } catch (e) {
      // Surface error — let views decide how to display
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void loadMore() => fetchProducts(reset: false);

  // ── Filter helpers ─────────────────────────────────────────────────────────

  void applyFilters({
    int? categoryId,
    double? minP,
    double? maxP,
    String? sort,
    bool? asc,
  }) {
    selectedCategoryId.value = categoryId;
    minPrice.value = minP;
    maxPrice.value = maxP;
    if (sort != null) sortBy.value = sort;
    if (asc != null) ascending.value = asc;
    fetchProducts(reset: true);
  }

  void clearFilters() {
    selectedCategoryId.value = initialCategoryId;
    minPrice.value = null;
    maxPrice.value = null;
    sortBy.value = 'created_at';
    ascending.value = false;
    fetchProducts(reset: true);
  }

  void setSearchQuery(String q) {
    searchQuery.value = q;
    fetchProducts(reset: true);
  }
}
