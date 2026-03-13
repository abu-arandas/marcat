// lib/controllers/search_controller.dart
//
// Absorbs: marcat_search_controller.dart
//
// Delegates all data reads to ProductController — no direct Supabase calls
// here, so search always uses the same cached categories list and product
// fetch path as the shop screen.
//
// Delete marcat_search_controller.dart.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/product_controller.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/models/category_model.dart';
import 'package:marcat/models/product_model.dart';

class SearchController extends GetxController {
  // Resolved lazily so the controller can be registered before ProductController
  // is initialised (e.g. inside a binding).
  ProductController get _products => Get.find<ProductController>();

  final textController = TextEditingController();

  final suggestions            = <CategoryModel>[].obs;
  final results                = <ProductModel>[].obs;
  final isLoadingSuggestions   = false.obs;
  final isSearching            = false.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _loadSuggestions();
    textController.addListener(_onTextChanged);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    textController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUGGESTIONS  (top-level categories)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _loadSuggestions() async {
    isLoadingSuggestions.value = true;
    try {
      // Prefer already-loaded categories; fetch only if empty.
      List<CategoryModel> cats = _products.categories
          .where((c) => c.parentId == null)
          .toList();

      if (cats.isEmpty) {
        cats = await _products.loadCategories();
        cats = cats.where((c) => c.parentId == null).toList();
      }
      suggestions.assignAll(cats.take(8));
    } catch (_) {
      // Sheet is still usable without suggestions.
    } finally {
      isLoadingSuggestions.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIVE SEARCH  (350 ms debounce, max 6 preview results)
  // ═══════════════════════════════════════════════════════════════════════════

  void _onTextChanged() {
    final q = textController.text.trim();
    if (q.isEmpty) {
      _debounce?.cancel();
      results.clear();
      return;
    }
    _debounce?.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 350), () => _search(q));
  }

  Future<void> _search(String q) async {
    isSearching.value = true;
    try {
      // updateState: false — must NOT overwrite the main shop product list.
      final (items, _) = await _products.fetchProducts(
        query:       q,
        pageSize:    6,
        updateState: false,
      );
      results.assignAll(items);
    } catch (_) {
      results.clear();
    } finally {
      isSearching.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════════

  void submitQuery(String q) {
    if (q.trim().isEmpty) return;
    Get.back();
    Get.toNamed(AppRoutes.shop, arguments: {'query': q.trim()});
  }

  void submitCategory(CategoryModel cat) {
    Get.back();
    Get.toNamed(AppRoutes.shop, arguments: {'categoryId': cat.id});
  }

  void submitProduct(ProductModel product) {
    Get.back();
    Get.toNamed(AppRoutes.product, arguments: product.id);
  }

  void clearSearch() {
    textController.clear();
    results.clear();
  }
}
