// lib/views/pos/terminal/pos_terminal_screen.dart

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/currency_extensions.dart';
import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/controllers/product_controller.dart';
import 'package:marcat/models/product_model.dart';

class PosTerminalScreen extends StatefulWidget {
  const PosTerminalScreen({super.key});

  @override
  State<PosTerminalScreen> createState() => _PosTerminalScreenState();
}

class _PosTerminalScreenState extends State<PosTerminalScreen> {
  final _searchCtrl = TextEditingController();

  Timer? _searchDebounce;

  AuthController get _auth => Get.find<AuthController>();
  CartController get _cart => Get.find<CartController>();
  ProductController get _products => Get.find<ProductController>();

  @override
  void initState() {
    super.initState();
    // Ensure the product list is loaded when the terminal opens.
    if (_products.products.isEmpty) {
      _products.fetchProducts();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (q.trim().isEmpty) {
        _products.fetchProducts();
      } else {
        _products.fetchProducts(query: q.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title: const Text('POS Terminal'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: AppDimensions.space16),
              child: Obx(() {
                final user = _auth.state.value.user;
                return Text(
                  user?.firstName ?? 'Staff',
                  style: AppTextStyles.labelMedium,
                );
              }),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _auth.signOut(),
          ),
        ],
      ),
      body: Row(
        children: [
          // ── Left: Active POS Cart / Ticket ────────────────────────────
          Expanded(
            flex: 3,
            child: Container(
              color: AppColors.surfaceWhite,
              child: Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      final items = _cart.items;
                      if (items.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shopping_bag_outlined,
                                  size: 48, color: AppColors.textDisabled),
                              SizedBox(height: AppDimensions.space8),
                              Text('Cart is empty',
                                  style:
                                      TextStyle(color: AppColors.textDisabled)),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(AppDimensions.space16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, idx) {
                          final item = items[idx];
                          return _buildCartItem(
                            title: item.productName,
                            subtitle: '${item.colorName} · ${item.sizeLabel}',
                            qty: '${item.quantity}',
                            price: item.lineTotal,
                            onRemove: () => _cart.removeItem(
                              item.productSizeId,
                              item.colorId,
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  _buildTicketTotals(),
                ],
              ),
            ),
          ),

          const VerticalDivider(
              width: 1, thickness: 1, color: AppColors.borderMedium),

          // ── Right: Product Catalogue ───────────────────────────────────
          Expanded(
            flex: 7,
            child: Column(
              children: [
                // ── Search / scan bar ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  color: AppColors.surfaceWhite,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Search or scan barcode…',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.qr_code_scanner),
                              onPressed: () {
                                // TODO: open mobile_scanner overlay
                              },
                            ),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space16),
                      TextButton.icon(
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('Add Customer'),
                        onPressed: () {
                          // TODO: open customer search bottom sheet
                        },
                      ),
                    ],
                  ),
                ),

                // ── Product grid ───────────────────────────────────────
                Expanded(
                  child: Obx(() {
                    final isLoading = _products.isLoadingProducts.value;
                    final prods = _products.products;

                    if (isLoading && prods.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.marcatGold),
                      );
                    }

                    if (prods.isEmpty) {
                      return const Center(
                        child: Text('No products found.'),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: AppDimensions.space12,
                        mainAxisSpacing: AppDimensions.space12,
                      ),
                      itemCount: prods.length,
                      itemBuilder: (_, i) => _buildProductTile(prods[i]),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(ProductModel product) {
    return GestureDetector(
      onTap: () {
        // For POS: add with default size/color — open a quick-select dialog
        _cart.addItem(
          // NOTE: In production, show a bottom sheet to select size & color first.
          // Placeholder: uses productId as productSizeId which is incorrect.
          // TODO: implement size/color selection bottom sheet for POS add-to-cart.
          _buildDefaultCartItem(product),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: product.primaryImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: product.primaryImageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) =>
                          Container(color: AppColors.shimmerBase),
                      errorWidget: (_, __, ___) =>
                          Container(color: AppColors.shimmerBase),
                    )
                  : Container(
                      color: AppColors.shimmerBase,
                      child: const Icon(Icons.image_outlined,
                          color: AppColors.textDisabled),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.basePrice.toJOD(),
                    style: AppTextStyles.priceSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem({
    required String title,
    required String subtitle,
    required String qty,
    required double price,
    required VoidCallback onRemove,
  }) {
    return ListTile(
      title: Text(title, style: AppTextStyles.labelMedium),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('×$qty  ${price.toJOD()}', style: AppTextStyles.priceSmall),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 18),
            onPressed: onRemove,
            color: AppColors.errorRed,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketTotals() {
    return Obx(() {
      final subtotal = _cart.subtotal;
      return Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: Column(
          children: [
            _TotalRow(label: 'Subtotal', value: subtotal.toJOD()),
            const SizedBox(height: AppDimensions.space8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cart.items.isEmpty
                    ? null
                    : () {
                        // TODO: open POS checkout flow
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.marcatGold,
                  foregroundColor: AppColors.marcatBlack,
                  padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.space16),
                ),
                child: Text(
                  'Charge ${subtotal.toJOD()}',
                  style: AppTextStyles.buttonPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // Temporary placeholder — replace with proper size/color selection UX
  dynamic _buildDefaultCartItem(ProductModel product) {
    // This is a stub. In production use a size/color selector bottom sheet.
    return null;
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value, style: AppTextStyles.priceMedium),
        ],
      );
}
