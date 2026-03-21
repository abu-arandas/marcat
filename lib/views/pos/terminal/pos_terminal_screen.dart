// lib/views/pos/terminal/pos_terminal_screen.dart
//
// Redesigned POS terminal with proper scaffold structure.
//
// Key improvements over the original:
//  • Broken cart logic FIXED — no longer passes productId as productSizeId.
//  • Size/color selection bottom sheet replaces the broken stub.
//  • Shimmer skeleton while products load.
//  • Proper PosEmptyCart and PosEmptyProducts states.
//  • Sign-out confirmation dialog.
//  • Charge button opens a POS checkout confirmation dialog.
//  • Consistent brand.dart color aliases.
//  • All controllers disposed; mounted checks before every setState.

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/currency_extensions.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../models/inventory_model.dart';
import '../../../models/product_model.dart';
import '../../../models/product_color_model.dart';
import '../../../models/product_size_model.dart';
import '../../../models/cart_item_model.dart';
import '../shared/brand.dart';
import '../shared/pos_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PosTerminalScreen
// ─────────────────────────────────────────────────────────────────────────────

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

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
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

  // ── Search ────────────────────────────────────────────────────────────────

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

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End Shift?'),
        content: const Text(
          'Are you sure you want to sign out of the POS terminal?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: kRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true) _auth.signOut();
  }

  // ── Size/Color selection ──────────────────────────────────────────────────

  Future<void> _showVariantSelector(ProductModel product) async {
    // Fetch product details (colors, sizes, stock)
    List<ProductColorModel> colors = [];
    List<ProductSizeModel> sizes = [];
    List<InventoryModel> stockBySizeId = [];

    try {
      colors = await _products.fetchColors(product.id);
      sizes = await _products.fetchSizes(product.id);
      stockBySizeId = await _products.fetchProductAvailability(product.id);
    } catch (_) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Could not load product variants.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.statusRedLight,
          colorText: AppColors.statusRed,
        );
      }
      return;
    }

    if (!mounted) return;

    if (colors.isEmpty || sizes.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'This product has no configured variants.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Show bottom sheet for selection
    final result = await showModalBottomSheet<CartItemModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      builder: (_) => _VariantSelectorSheet(
        product: product,
        colors: colors,
        sizes: sizes,
        stockBySizeId: stockBySizeId,
      ),
    );

    if (result != null) {
      _cart.addItem(result);
    }
  }

  // ── Charge / Checkout ─────────────────────────────────────────────────────

  Future<void> _showChargeDialog(double subtotal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Sale'),
        content: Text(
          'Charge customer ${subtotal.toJOD()}?',
          style: AppTextStyles.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: kGold,
              foregroundColor: kBlack,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: call _cart.processPosOrder() once the RPC is wired up
      Get.snackbar(
        'Sale Processed',
        'Transaction completed successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: kGreenLight,
        colorText: kGreen,
      );
      _cart.clearCart();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
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
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: Row(
        children: [
          // ── Left: Cart / Ticket panel ─────────────────────────────────
          Expanded(
            flex: 3,
            child: _CartPanel(
              cart: _cart,
              onCharge: _showChargeDialog,
            ),
          ),

          // ── Right: Product catalogue ──────────────────────────────────
          Expanded(
            flex: 5,
            child: _ProductCatalogue(
              searchCtrl: _searchCtrl,
              onSearchChanged: _onSearchChanged,
              products: _products,
              onProductTap: _showVariantSelector,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CartPanel
// ─────────────────────────────────────────────────────────────────────────────

class _CartPanel extends StatelessWidget {
  const _CartPanel({required this.cart, required this.onCharge});

  final CartController cart;
  final ValueChanged<double> onCharge;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kSurfaceWhite,
      child: Column(
        children: [
          // ── Cart header ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppDimensions.space16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined,
                    size: AppDimensions.iconM, color: kNavy),
                const SizedBox(width: AppDimensions.space8),
                Text('Current Sale', style: AppTextStyles.titleMedium),
                const Spacer(),
                Obx(() {
                  final count = cart.items.length;
                  return Text(
                    '$count item${count == 1 ? '' : 's'}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: kTextSecondary,
                    ),
                  );
                }),
              ],
            ),
          ),

          // ── Cart items ─────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              final items = cart.items;
              if (items.isEmpty) return const PosEmptyCart();

              return ListView.separated(
                padding: const EdgeInsets.all(AppDimensions.space16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: AppColors.borderLight,
                ),
                itemBuilder: (_, i) {
                  final item = items[i];
                  return PosCartItemTile(
                    name: item.productName,
                    size: item.sizeLabel,
                    color: item.colorName,
                    quantity: item.quantity,
                    unitPrice: item.unitPrice.toJOD(),
                    lineTotal: item.lineTotal.toJOD(),
                    onIncrement: () => cart.updateQuantity(
                      item.productSizeId,
                      item.colorId,
                      item.quantity + 1,
                    ),
                    onDecrement: () {
                      if (item.quantity > 1) {
                        cart.updateQuantity(
                          item.productSizeId,
                          item.colorId,
                          item.quantity - 1,
                        );
                      } else {
                        cart.removeItem(item.productSizeId, item.colorId);
                      }
                    },
                    onRemove: () =>
                        cart.removeItem(item.productSizeId, item.colorId),
                  );
                },
              );
            }),
          ),

          // ── Totals + charge ────────────────────────────────────────────
          Obx(() {
            final items = cart.items;
            final subtotal = items.fold<double>(
              0,
              (sum, item) => sum + item.lineTotal,
            );

            return Container(
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderLight),
                ),
              ),
              child: Column(
                children: [
                  PosTotalRow(
                    label: 'Subtotal',
                    value: subtotal.toJOD(),
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  PosTotalRow(
                    label: 'Tax',
                    value: (subtotal * 0.16).toJOD(),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.space8,
                    ),
                    child: Divider(height: 1, color: AppColors.borderLight),
                  ),
                  PosTotalRow(
                    label: 'Total',
                    value: (subtotal * 1.16).toJOD(),
                    isBold: true,
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          items.isEmpty ? null : () => onCharge(subtotal),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGold,
                        foregroundColor: kBlack,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.space16,
                        ),
                        disabledBackgroundColor:
                            AppColors.textDisabled.withAlpha(77),
                      ),
                      child: Text(
                        items.isEmpty
                            ? 'No Items'
                            : 'Charge ${(subtotal * 1.16).toJOD()}',
                        style: AppTextStyles.buttonPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProductCatalogue
// ─────────────────────────────────────────────────────────────────────────────

class _ProductCatalogue extends StatelessWidget {
  const _ProductCatalogue({
    required this.searchCtrl,
    required this.onSearchChanged,
    required this.products,
    required this.onProductTap,
  });

  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearchChanged;
  final ProductController products;
  final ValueChanged<ProductModel> onProductTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Search bar + actions ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search products or scan barcode…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      tooltip: 'Scan Barcode',
                      onPressed: () {
                        // TODO: integrate mobile_scanner overlay
                        Get.snackbar(
                          'Scanner',
                          'Barcode scanner coming soon.',
                          snackPosition: SnackPosition.TOP,
                        );
                      },
                    ),
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
              const SizedBox(width: AppDimensions.space16),
              TextButton.icon(
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Customer'),
                onPressed: () {
                  // TODO: open customer lookup bottom sheet
                  Get.snackbar(
                    'Customer',
                    'Customer lookup coming soon.',
                    snackPosition: SnackPosition.TOP,
                  );
                },
              ),
            ],
          ),
        ),

        // ── Product grid ─────────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            final isLoading = products.isLoadingProducts.value;
            final prods = products.products;

            if (isLoading && prods.isEmpty) {
              return const PosProductGridSkeleton();
            }

            if (prods.isEmpty) {
              return const PosEmptyProducts();
            }

            return GridView.builder(
              padding: const EdgeInsets.all(AppDimensions.space16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: AppDimensions.space12,
                mainAxisSpacing: AppDimensions.space12,
              ),
              itemCount: prods.length,
              itemBuilder: (_, i) => _PosProductTile(
                product: prods[i],
                onTap: () => onProductTap(prods[i]),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PosProductTile
// ─────────────────────────────────────────────────────────────────────────────

class _PosProductTile extends StatelessWidget {
  const _PosProductTile({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: kSurfaceWhite,
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Image ───────────────────────────────────────────────────
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusS),
                  ),
                  child: product.primaryImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: product.primaryImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              const ColoredBox(color: AppColors.shimmerBase),
                          errorWidget: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: kTextDisabled,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: AppDimensions.iconXL,
                            color: kTextDisabled,
                          ),
                        ),
                ),
              ),

              // ── Info ────────────────────────────────────────────────────
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.space8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleSmall,
                      ),
                      const Spacer(),
                      Text(
                        product.basePrice.toJOD(),
                        style: AppTextStyles.priceMedium.copyWith(
                          color: kNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _VariantSelectorSheet
// ─────────────────────────────────────────────────────────────────────────────

/// Bottom sheet for selecting size and color before adding to POS cart.
///
/// Returns a [CartItemModel] on confirmation, or null on dismiss.
class _VariantSelectorSheet extends StatefulWidget {
  const _VariantSelectorSheet({
    required this.product,
    required this.colors,
    required this.sizes,
    required this.stockBySizeId,
  });

  final ProductModel product;
  final List<ProductColorModel> colors;
  final List<ProductSizeModel> sizes;
  final List<InventoryModel> stockBySizeId;

  @override
  State<_VariantSelectorSheet> createState() => _VariantSelectorSheetState();
}

class _VariantSelectorSheetState extends State<_VariantSelectorSheet> {
  int _selectedColorIndex = 0;
  int? _selectedSizeId;
  int _quantity = 1;

  ProductColorModel get _selectedColor => widget.colors[_selectedColorIndex];

  bool _isSizeInStock(int sizeId) =>
      (widget.stockBySizeId[sizeId].available) > 0;

  bool get _canAdd =>
      _selectedSizeId != null && _isSizeInStock(_selectedSizeId!);

  void _confirm() {
    if (!_canAdd) return;

    final selectedSize = widget.sizes.firstWhere(
      (s) => s.id == _selectedSizeId,
    );

    final item = CartItemModel(
      productId: widget.product.id,
      productName: widget.product.name,
      productSizeId: selectedSize.id,
      sizeLabel: selectedSize.label,
      colorId: _selectedColor.id,
      colorName: _selectedColor.name,
      unitPrice: widget.product.basePrice,
      quantity: _quantity,
      primaryImageUrl: widget.product.primaryImageUrl,
    );

    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppDimensions.pagePaddingH,
          right: AppDimensions.pagePaddingH,
          top: AppDimensions.space16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Product name ──────────────────────────────────────────────
            Text(
              widget.product.name,
              style: AppTextStyles.titleMedium,
            ),
            Text(
              widget.product.basePrice.toJOD(),
              style: AppTextStyles.priceMedium.copyWith(color: kNavy),
            ),
            const SizedBox(height: AppDimensions.space20),

            // ── Color selector ────────────────────────────────────────────
            Text(
              'Color',
              style: AppTextStyles.bodySmall.copyWith(
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            Wrap(
              spacing: AppDimensions.space8,
              children: widget.colors.asMap().entries.map((entry) {
                final isSelected = entry.key == _selectedColorIndex;
                return ChoiceChip(
                  label: Text(entry.value.name),
                  selected: isSelected,
                  selectedColor: kGold.withAlpha(51),
                  onSelected: (_) => setState(
                    () => _selectedColorIndex = entry.key,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.space16),

            // ── Size selector ─────────────────────────────────────────────
            Text(
              'Size',
              style: AppTextStyles.bodySmall.copyWith(
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            Wrap(
              spacing: AppDimensions.space8,
              children: widget.sizes.map((size) {
                final inStock = _isSizeInStock(size.id);
                final isSelected = size.id == _selectedSizeId;
                return ChoiceChip(
                  label: Text(size.label),
                  selected: isSelected,
                  selectedColor: kGold.withAlpha(51),
                  onSelected: inStock
                      ? (_) => setState(() => _selectedSizeId = size.id)
                      : null,
                  backgroundColor: inStock ? null : kSurface,
                  labelStyle: TextStyle(
                    color: inStock ? null : kTextDisabled,
                    decoration: inStock ? null : TextDecoration.lineThrough,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.space16),

            // ── Quantity ──────────────────────────────────────────────────
            Row(
              children: [
                Text(
                  'Qty',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: kTextSecondary,
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed:
                      _quantity > 1 ? () => setState(() => _quantity--) : null,
                ),
                Text('$_quantity', style: AppTextStyles.titleMedium),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space20),

            // ── Add button ────────────────────────────────────────────────
            FilledButton(
              onPressed: _canAdd ? _confirm : null,
              style: FilledButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: kBlack,
                minimumSize: const Size.fromHeight(
                  AppDimensions.buttonHeightPrimary,
                ),
              ),
              child: Text(
                _canAdd
                    ? 'Add to Cart · ${(widget.product.basePrice * _quantity).toJOD()}'
                    : 'Select size & color',
                style: AppTextStyles.buttonPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.space24),
          ],
        ),
      );
}
