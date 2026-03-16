// lib/controllers/search_controller.dart

import 'package:get/get.dart';

import 'package:marcat/controllers/product_controller.dart';
import 'package:marcat/models/product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MarcatSearchController
// ─────────────────────────────────────────────────────────────────────────────

/// Thin controller that delegates product search to [ProductController].
/// Keeps search state (query, results, loading) reactive and isolated
/// from the main product catalogue state.
class MarcatSearchController extends GetxController {
  // ── Dependencies ─────────────────────────────────────────────────────────────
  ProductController get _productCtrl => Get.find<ProductController>();

  // ── Observable state ─────────────────────────────────────────────────────────
  final query = ''.obs;
  final results = <ProductModel>[].obs;
  final isLoading = false.obs;
  final hasSearched = false.obs;

  // ── Public API ────────────────────────────────────────────────────────────────

  /// Execute a search. Call with an empty string to clear results.
  Future<void> search(String q) async {
    final trimmed = q.trim();
    query.value = trimmed;

    if (trimmed.isEmpty) {
      results.clear();
      hasSearched.value = false;
      return;
    }

    isLoading.value = true;
    hasSearched.value = true;

    try {
      final found = await _productCtrl.fetchProducts(query: trimmed);
      results.assignAll(found.$1);
    } catch (e) {
      results.clear();
      // Swallow error here — search is non-critical; the UI should show empty
      // state rather than an error page.
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    query.value = '';
    results.clear();
    hasSearched.value = false;
  }
}
