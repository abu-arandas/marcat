// lib/views/customer/cart_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/core/constants/app_text_styles.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';
import 'package:marcat/models/cart_item_model.dart';
import 'package:marcat/core/router/app_router.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/empty_state.dart';
import 'shared/marcat_buttons.dart';
import 'shared/section_header.dart';

// ── Local constants ────────────────────────────────────────────────────────────
const _kNavy = AppColors.marcatNavy;
const _kCream = AppColors.marcatCream;
const _kSlate = AppColors.marcatSlate;
const _kRed = AppColors.saleRed;
const _kBorder = AppColors.borderLight;

// ─────────────────────────────────────────────────────────────────────────────
// CartPage
// ─────────────────────────────────────────────────────────────────────────────

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) => CustomerScaffold(
        page: 'Shopping Bag',
        pageImage:
            'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=1600&q=80',
        body: const _CartBody(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _CartBody
// ─────────────────────────────────────────────────────────────────────────────

class _CartBody extends StatelessWidget {
  const _CartBody();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (ctrl) {
        if (ctrl.isCartLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final isDesktop = MediaQuery.sizeOf(context).width > 900;

        return Obx(() {
          if (ctrl.items.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your Bag Is Empty',
              subtitle:
                  "Looks like you haven't added anything yet.\nStart shopping to fill it up.",
              actionLabel: 'Continue Shopping',
              onAction: () => Get.toNamed(AppRoutes.shop),
            );
          }

          return FB5Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _CartItemsList(ctrl: ctrl),
                        ),
                        const SizedBox(width: 40),
                        SizedBox(
                          width: 360,
                          child: _OrderSummary(ctrl: ctrl),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CartItemsList(ctrl: ctrl),
                        const SizedBox(height: 32),
                        _OrderSummary(ctrl: ctrl),
                      ],
                    ),
            ),
          );
        });
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CartItemsList
// ─────────────────────────────────────────────────────────────────────────────

class _CartItemsList extends StatelessWidget {
  const _CartItemsList({required this.ctrl});

  final CartController ctrl;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            eyebrow: 'Review',
            title: 'Your Items',
            action: TextButton(
              onPressed: () => _showClearConfirm(context),
              style: TextButton.styleFrom(foregroundColor: _kRed),
              child: const Text(
                'Clear All',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ctrl.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) =>
                  _CartItemRow(item: ctrl.items[i], ctrl: ctrl),
            ),
          ),
        ],
      );

  void _showClearConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _ClearCartDialog(ctrl: ctrl),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ClearCartDialog
// ─────────────────────────────────────────────────────────────────────────────

class _ClearCartDialog extends StatelessWidget {
  const _ClearCartDialog({required this.ctrl});

  final CartController ctrl;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text(
        'Clear Cart?',
        style: TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _kNavy,
        ),
      ),
      content: const Text(
        'This will remove all items from your bag. This action cannot be undone.',
        style: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          color: _kSlate,
          height: 1.5,
          fontSize: 14,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              color: _kSlate,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            ctrl.clearCart();
            Get.back();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _kRed,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            'Clear',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CartItemRow
// ─────────────────────────────────────────────────────────────────────────────

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.item, required this.ctrl});

  final CartItemModel item;
  final CartController ctrl;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ─────────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 90,
                height: 110,
                child: item.primaryImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.primaryImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            const ColoredBox(color: _kCream),
                        errorWidget: (_, __, ___) =>
                            const ColoredBox(color: _kCream),
                      )
                    : const ColoredBox(
                        color: _kCream,
                        child: Icon(Icons.image_not_supported_outlined,
                            color: _kSlate),
                      ),
              ),
            ),

            const SizedBox(width: 16),

            // ── Details ───────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: AppTextStyles.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Tag(item.colorName),
                      ...[
                        const SizedBox(width: 6),
                        _Tag(item.sizeLabel),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Quantity stepper
                      _QuantityStepper(item: item, ctrl: ctrl),
                      const Spacer(),
                      // Line total
                      Text(
                        (item.unitPrice * item.quantity).toJOD(),
                        style: AppTextStyles.priceMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Remove ────────────────────────────────────────────────────
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              color: _kSlate,
              tooltip: 'Remove',
              onPressed: () =>
                  ctrl.removeItem(item.productSizeId, item.colorId),
              splashRadius: 18,
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _QuantityStepper
// ─────────────────────────────────────────────────────────────────────────────

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.item, required this.ctrl});

  final CartItemModel item;
  final CartController ctrl;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: _kBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepBtn(
              icon: Icons.remove,
              onTap: item.quantity > 1
                  ? () => ctrl.updateQuantity(
                      item.productSizeId, item.colorId, item.quantity - 1)
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${item.quantity}',
                style: AppTextStyles.labelLarge,
              ),
            ),
            _StepBtn(
              icon: Icons.add,
              onTap: () => ctrl.updateQuantity(
                  item.productSizeId, item.colorId, item.quantity + 1),
            ),
          ],
        ),
      );
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 16,
            color: onTap != null ? _kNavy : _kBorder,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _Tag  (color / size chip)
// ─────────────────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _kCream,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: _kBorder),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _kNavy,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _OrderSummary
// ─────────────────────────────────────────────────────────────────────────────

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.ctrl});

  final CartController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final subtotal = ctrl.subtotal;
      final discount = ctrl.discountTotal;
      final total = ctrl.grandTotal;
      final offer = ctrl.appliedOffer.value;

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ORDER SUMMARY',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: _kSlate,
              ),
            ),
            const SizedBox(height: 20),

            // Subtotal
            _SummaryRow(label: 'Subtotal', value: subtotal.toJOD()),
            if (discount > 0) ...[
              const SizedBox(height: 8),
              _SummaryRow(
                label: 'Discount',
                value: '-${discount.toJOD()}',
                valueColor: AppColors.successGreen,
              ),
            ],
            if (offer != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.local_offer_outlined,
                      size: 13, color: AppColors.marcatGold),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      offer.offerId.toString(),
                      style: const TextStyle(
                        fontFamily: 'IBMPlexMono',
                        fontSize: 11,
                        color: AppColors.marcatGold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: ctrl.removeCoupon,
                    child: const Icon(Icons.close_rounded,
                        size: 14, color: _kSlate),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            _SummaryRow(label: 'Shipping', value: 'Free'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: _kBorder),
            ),
            _SummaryRow(
              label: 'Total',
              value: total.toJOD(),
              bold: true,
            ),

            // Promo code
            const SizedBox(height: 20),
            _PromoCodeField(ctrl: ctrl),

            const SizedBox(height: 20),

            // Checkout CTA
            PrimaryButton(
              label: 'Proceed to Checkout',
              onPressed: () => Get.toNamed(AppRoutes.checkout),
              icon: Icons.lock_outline_rounded,
            ),

            const SizedBox(height: 12),
            const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.security_outlined, size: 13, color: _kSlate),
                  SizedBox(width: 4),
                  Text(
                    'Secure Checkout',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 11,
                      color: _kSlate,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PromoCodeField
// ─────────────────────────────────────────────────────────────────────────────

class _PromoCodeField extends StatefulWidget {
  const _PromoCodeField({required this.ctrl});

  final CartController ctrl;

  @override
  State<_PromoCodeField> createState() => _PromoCodeFieldState();
}

class _PromoCodeFieldState extends State<_PromoCodeField> {
  final _codeCtrl = TextEditingController();
  bool _applying = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() => _applying = true);
    try {
      await widget.ctrl.applyCoupon(code);
      _codeCtrl.clear();
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _codeCtrl,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 13,
                letterSpacing: 1,
              ),
              decoration: InputDecoration(
                hintText: 'Promo code',
                hintStyle: const TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 13,
                  color: _kSlate,
                ),
                filled: true,
                fillColor: _kCream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kNavy, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          OutlineButton(
            label: _applying ? '…' : 'Apply',
            onPressed: _applying ? null : _apply,
            height: 46,
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _SummaryRow
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: bold
                ? AppTextStyles.titleMedium
                : AppTextStyles.bodyMedium.copyWith(color: _kSlate),
          ),
          Text(
            value,
            style: (bold ? AppTextStyles.priceMedium : AppTextStyles.bodyMedium)
                .copyWith(
              color: valueColor,
            ),
          ),
        ],
      );
}
