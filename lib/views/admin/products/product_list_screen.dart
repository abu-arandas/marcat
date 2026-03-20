// lib/views/admin/products/product_list_screen.dart
//
// Displays all products in a searchable, scrollable list.
// Supports pull-to-refresh and navigates to the product form on tap.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/product_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/currency_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../models/enums.dart';
import '../../../models/product_model.dart';
import '../shared/admin_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminProductListScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Scrollable product catalogue for admin management.
///
/// - Loads all products on first mount with a shimmer placeholder.
/// - Supports live client-side search / filtering by name or SKU.
/// - Status badge colours match [ProductStatusBadge] from admin_widgets.
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

  // ── Lifecycle ─────────────────────────────────────────────────────────────

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

  // ── Data ──────────────────────────────────────────────────────────────────

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // pageSize 200 covers typical catalogue sizes; add pagination later
      // if the product count grows significantly.
      await _productCtrl.fetchProducts(page: 0, pageSize: 200);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<ProductModel> _filter(List<ProductModel> all) {
    final q = _searchQuery.toLowerCase().trim();
    if (q.isEmpty) return all;
    return all.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.sku.toLowerCase().contains(q);
    }).toList();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Product',
            onPressed: () => Get.toNamed(AppRoutes.adminProductsCreate),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        color: AppColors.marcatGold,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const AdminListSkeleton();

    if (_error != null) {
      return AdminErrorRetry(message: _error!, onRetry: _loadProducts);
    }

    return Obx(() {
      final filtered = _filter(_productCtrl.products);
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Search bar ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePaddingH,
                AppDimensions.space16,
                AppDimensions.pagePaddingH,
                AppDimensions.space8,
              ),
              child: _SearchBar(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),

          // ── Count label ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePaddingH,
                vertical: AppDimensions.space4,
              ),
              child: Text(
                '${filtered.length} product${filtered.length == 1 ? '' : 's'}',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),

          // ── Empty state ─────────────────────────────────────────────────
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: AdminEmptyState(
                icon: Icons.inventory_2_outlined,
                title: _searchQuery.isEmpty
                    ? 'No Products Yet'
                    : 'No Results for "$_searchQuery"',
                subtitle: _searchQuery.isEmpty
                    ? 'Tap + to create your first product.'
                    : 'Try a different search term.',
                actionLabel: _searchQuery.isEmpty ? 'Add Product' : null,
                onAction: _searchQuery.isEmpty
                    ? () => Get.toNamed(AppRoutes.adminProductsCreate)
                    : null,
              ),
            )
          else
            // ── Product list ──────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePaddingH,
                AppDimensions.space8,
                AppDimensions.pagePaddingH,
                AppDimensions.space64,
              ),
              sliver: SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppDimensions.space8),
                itemBuilder: (_, i) => _ProductCard(product: filtered[i]),
              ),
            ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SearchBar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search by name or SKU…',
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textDisabled, size: AppDimensions.iconM),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      size: AppDimensions.iconS),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceWhite,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            borderSide:
                const BorderSide(color: AppColors.marcatNavy, width: 1.5),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProductCard
// ─────────────────────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final status = ProductStatusX.fromDb(product.status?.toString());

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        onTap: () => Get.toNamed(AppRoutes.adminProductEditOf(product.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space12),
          child: Row(
            children: [
              // ── Thumbnail ───────────────────────────────────────────────
              _ProductThumbnail(imageUrl: product.primaryImageUrl),
              const SizedBox(width: AppDimensions.space12),

              // ── Info ────────────────────────────────────────────────────
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
                    const SizedBox(height: AppDimensions.space4),
                    Text(
                      'SKU: ${product.sku}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimensions.space4),
                    Row(
                      children: [
                        Text(
                          product.basePrice.toJOD(),
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.marcatGold,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        ProductStatusBadge(status: status),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Chevron ─────────────────────────────────────────────────
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textDisabled,
                size: AppDimensions.iconM,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProductThumbnail
// ─────────────────────────────────────────────────────────────────────────────

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        child: SizedBox(
          width: 56,
          height: 56,
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      const ColoredBox(color: AppColors.marcatCream),
                  errorWidget: (_, __, ___) => _Placeholder(),
                )
              : _Placeholder(),
        ),
      );
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: AppColors.surfaceGrey,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.textDisabled,
          size: AppDimensions.iconM,
        ),
      );
}
