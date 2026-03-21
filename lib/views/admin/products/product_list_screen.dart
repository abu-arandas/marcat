// lib/views/admin/products/product_list_screen.dart
//
// Displays all products in a searchable, scrollable list.
//
// ✅ REFACTORED: uses brand.dart color aliases, consistent with codebase.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/product_controller.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/currency_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../models/product_model.dart';
import '../shared/admin_widgets.dart';
import '../shared/brand.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminProductListScreen
// ─────────────────────────────────────────────────────────────────────────────

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  final _searchController = TextEditingController();

  ProductController get _productCtrl => Get.find<ProductController>();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _productCtrl.fetchProducts(page: 0, pageSize: 200);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<ProductModel> get _filtered {
    final all = _productCtrl.products;
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            (p.sku.toLowerCase().contains(q)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Product',
            onPressed: () => Get.toNamed(AppRoutes.adminProductsCreate),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search products by name or SKU…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const AdminListSkeleton();

    if (_error != null) {
      return AdminErrorRetry(message: _error!, onRetry: _loadProducts);
    }

    final products = _filtered;

    if (products.isEmpty) {
      return AdminEmptyState(
        icon: Icons.inventory_2_outlined,
        title: _searchQuery.isEmpty ? 'No Products' : 'No Results',
        subtitle: _searchQuery.isEmpty
            ? 'Start by adding your first product.'
            : 'Try a different search term.',
        actionLabel: _searchQuery.isEmpty ? 'Add Product' : null,
        onAction: _searchQuery.isEmpty
            ? () => Get.toNamed(AppRoutes.adminProductsCreate)
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: kGold,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
        ),
        itemCount: products.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.space12),
        itemBuilder: (_, i) => _ProductCard(product: products[i]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProductCard
// ─────────────────────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          onTap: () => Get.toNamed(AppRoutes.adminProductEditOf(product.id)),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space12),
            child: Row(
              children: [
                // ── Thumbnail ─────────────────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: product.primaryImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: product.primaryImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                const ColoredBox(color: kSurface),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.image_not_supported_outlined,
                              color: kTextDisabled,
                              size: AppDimensions.iconM,
                            ),
                          )
                        : Container(
                            color: kSurface,
                            child: const Icon(
                              Icons.image_outlined,
                              color: kTextDisabled,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),

                // ── Info ──────────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTextStyles.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.sku,
                        style: AppTextStyles.skuText,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.space8),

                // ── Price + status ────────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      product.basePrice.toJOD(),
                      style: AppTextStyles.priceSmall,
                    ),
                    const SizedBox(height: 4),
                    ProductStatusBadge(status: product.status),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
