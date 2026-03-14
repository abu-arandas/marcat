// lib/controllers/shop_controller.dart
//
// FIX: ShopController was defined inside lib/views/customer/shop_page.dart,
// mixing business logic with UI code. Extracted to its own file under
// lib/controllers/ to respect the project's controller-first architecture.
// shop_page.dart now imports this file.

import 'package:get/get.dart';

import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/controllers/product_controller.dart';
import 'package:marcat/core/router/app_router.dart';
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
      wishlistedIds.value =
          _productCtrl.wishlistItems.map((w) => w.productId).toSet();
    } catch (_) {}
  }

  Future<void> toggleWishlist(int productId) async {
    final user = _auth.state.value.user;
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

  // ─────────────────────────────────────────────────────────────────────────────
  // PRODUCTS — FETCH & FILTER
  // ─────────────────────────────────────────────────────────────────────────────

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

  /// Applies new filter / sort values and reloads from page 0.
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

  /// Updates the search query and reloads from page 0.
  void search(String q) {
    searchQuery.value = q;
    fetchProducts(reset: true);
  }
}
