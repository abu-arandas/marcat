// lib/controllers/search_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/product_controller.dart';
import 'package:marcat/models/category_model.dart';
import 'package:marcat/models/product_model.dart';
import 'package:marcat/core/router/app_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MarcatSearchController
// ─────────────────────────────────────────────────────────────────────────────

/// Thin controller that delegates product search to [ProductController].
/// Keeps search state (query, results, loading) reactive and isolated
/// from the main product catalogue state.
class MarcatSearchController extends GetxController {
  // ── Dependencies ──────────────────────────────────────────────────────────
  ProductController get _productCtrl => Get.find<ProductController>();

  // ── Text input ────────────────────────────────────────────────────────────
  late final TextEditingController textController;

  // ── Observable state ──────────────────────────────────────────────────────
  final query = ''.obs;
  final results = <ProductModel>[].obs;
  final suggestions = <CategoryModel>[].obs;
  final isLoading = false.obs;
  final isSearching = false.obs;
  final isLoadingSuggestions = false.obs;
  final hasSearched = false.obs;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    textController = TextEditingController();
    textController.addListener(_onTextChanged);
    _loadSuggestions();
  }

  @override
  void onClose() {
    textController.removeListener(_onTextChanged);
    textController.dispose();
    super.onClose();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _onTextChanged() {
    final text = textController.text;
    if (text.trim().isEmpty) {
      results.clear();
      hasSearched.value = false;
      isSearching.value = false;
    }
  }

  Future<void> _loadSuggestions() async {
    isLoadingSuggestions.value = true;
    try {
      final cats = _productCtrl.categories;
      if (cats.isNotEmpty) {
        suggestions.assignAll(cats.take(8).toList());
      }
    } catch (_) {
      // Non-critical
    } finally {
      isLoadingSuggestions.value = false;
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Called when the user submits the search field.
  Future<void> submitQuery(String q) async => search(q);

  /// Navigate to a category from suggestion chips.
  void submitCategory(CategoryModel cat) {
    Get.back(); // close search dialog
    Get.toNamed(AppRoutes.categoryOf(cat.id));
  }

  /// Navigate to a product detail from results.
  void submitProduct(ProductModel product) {
    Get.back(); // close search dialog
    Get.toNamed(AppRoutes.productOf(product.id));
  }

  /// Execute a search. Call with an empty string to clear results.
  Future<void> search(String q) async {
    final trimmed = q.trim();
    query.value = trimmed;

    if (trimmed.isEmpty) {
      results.clear();
      hasSearched.value = false;
      isSearching.value = false;
      return;
    }

    isLoading.value = true;
    isSearching.value = true;
    hasSearched.value = true;

    try {
      final found = await _productCtrl.fetchProducts(
        query: trimmed,
        updateState: false,
      );
      results.assignAll(found.$1);
    } catch (_) {
      results.clear();
      // Swallow error — search is non-critical; UI shows empty state.
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    textController.clear();
    query.value = '';
    results.clear();
    hasSearched.value = false;
    isSearching.value = false;
  }
}
