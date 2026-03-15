// lib/views/pos/terminal/pos_terminal_screen.dart

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
    super.dispose();
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
                          onChanged: (q) {
                            if (q.trim().isEmpty) {
                              _products.fetchProducts();
                            } else {
                              _products.fetchProducts(query: q.trim());
                            }
                          },
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
                        crossAxisCount: 4,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: AppDimensions.space16,
                        mainAxisSpacing: AppDimensions.space16,
                      ),
                      itemCount: prods.length,
                      itemBuilder: (ctx, idx) => _buildProductCard(prods[idx]),
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

  // ── Product card ─────────────────────────────────────────────────────────

  Widget _buildProductCard(ProductModel product) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        onTap: () {
          // TODO: open size/color selection bottom sheet then add to cart
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusS)),
                child: product.primaryImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.primaryImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppColors.shimmerBase),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.shimmerBase,
                          child: const Center(
                            child: Icon(Icons.image_not_supported,
                                color: AppColors.textDisabled),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.shimmerBase,
                        child: const Center(
                          child: Icon(Icons.checkroom,
                              size: 32, color: AppColors.textDisabled),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium,
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  Text(
                    product.basePrice.toJOD(),
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Cart item row ─────────────────────────────────────────────────────────

  Widget _buildCartItem({
    required String title,
    required String subtitle,
    required String qty,
    required double price,
    VoidCallback? onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.space8, horizontal: AppDimensions.space16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelMedium),
                Text(subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('× $qty',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: AppDimensions.space16),
          Text(price.toJOD(), style: AppTextStyles.labelMedium),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.close,
                  size: AppDimensions.iconS, color: AppColors.textDisabled),
              onPressed: onRemove,
              tooltip: 'Remove',
            ),
        ],
      ),
    );
  }

  // ── Ticket totals ─────────────────────────────────────────────────────────

  Widget _buildTicketTotals() {
    return Obx(() {
      final subtotal = _cart.subtotal;
      final discount = _cart.discountTotal;
      final total = _cart.grandTotal;

      return Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: Column(
          children: [
            _totalRow('Subtotal', subtotal.toJOD()),
            if (discount > 0)
              _totalRow('Discount', '- ${discount.toJOD()}',
                  color: AppColors.successGreen),
            const Divider(height: AppDimensions.space16),
            _totalRow('Total', total.toJOD(), isBold: true),
            const SizedBox(height: AppDimensions.space12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.point_of_sale_outlined),
                label: const Text('Charge'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.marcatGold,
                  foregroundColor: AppColors.marcatBlack,
                  minimumSize: const Size(
                      double.infinity, AppDimensions.buttonHeightPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                ),
                onPressed: _cart.items.isEmpty
                    ? null
                    : () {
                        // TODO: confirm & process POS sale
                      },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _totalRow(String label, String value,
      {Color? color, bool isBold = false}) {
    final style = isBold ? AppTextStyles.titleMedium : AppTextStyles.bodyMedium;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value,
              style: style.copyWith(
                  color: color, fontWeight: isBold ? FontWeight.w700 : null)),
        ],
      ),
    );
  }
}
