// lib/views/customer/cart_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/core/constants/app_text_styles.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/models/cart_item_model.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/buttons.dart';
import 'shared/empty_state.dart';
import 'shared/section_header.dart';

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
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: kGold,
              ),
            ),
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
                  ? _DesktopLayout(ctrl: ctrl)
                  : _MobileLayout(ctrl: ctrl),
            ),
          );
        });
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DesktopLayout
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.ctrl});
  final CartController ctrl;

  @override
  Widget build(BuildContext context) => FB5Row(
        children: [
          // ── Cart items (left) ─────────────────────────────────────────
          FB5Col(
            classNames: 'col-lg-8 col-12',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  eyebrow: 'Shopping',
                  title: 'Your Bag',
                ),
                const SizedBox(height: 24),
                _CartItemsList(ctrl: ctrl),
              ],
            ),
          ),

          // ── Order summary (right) ─────────────────────────────────────
          FB5Col(
            classNames: 'col-lg-4 col-12',
            child: _OrderSummary(ctrl: ctrl),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _MobileLayout
// ─────────────────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.ctrl});
  final CartController ctrl;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Shopping',
            title: 'Your Bag',
          ),
          const SizedBox(height: 24),
          _CartItemsList(ctrl: ctrl),
          const SizedBox(height: 32),
          _OrderSummary(ctrl: ctrl),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _CartItemsList
// ─────────────────────────────────────────────────────────────────────────────

class _CartItemsList extends StatelessWidget {
  const _CartItemsList({required this.ctrl});
  final CartController ctrl;

  @override
  Widget build(BuildContext context) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ctrl.items.length,
        separatorBuilder: (_, __) => const Divider(
          color: kBorder,
          height: 1,
        ),
        itemBuilder: (_, i) {
          final item = ctrl.items[i];
          return _CartItemRow(
            item: item,
            onRemove: () => ctrl.removeItem(item.productSizeId, item.colorId),
            onIncrement: () => ctrl.updateQuantity(item.productSizeId, item.colorId, item.quantity + 1),
            onDecrement: () => ctrl.updateQuantity(item.productSizeId, item.colorId, item.quantity - 1),
          );
        },
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _CartItemRow
// ─────────────────────────────────────────────────────────────────────────────

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({
    required this.item,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartItemModel item;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ─────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 88,
                height: 110,
                child: item.primaryImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.primaryImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            const ColoredBox(color: kCream),
                        errorWidget: (_, __, ___) =>
                            const ColoredBox(color: kCream),
                      )
                    : const ColoredBox(color: kCream),
              ),
            ),
            const SizedBox(width: 16),

            // ── Details ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    item.productName,
                    style: AppTextStyles.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Size + colour meta
                  Text(
                    '${item.sizeLabel}  ·  ${item.colorName}',
                    style:
                        AppTextStyles.bodySmall.copyWith(color: kSlate),
                  ),
                  const SizedBox(height: 12),

                  // Quantity stepper + remove
                  Row(
                    children: [
                      _QtyStepper(
                        qty: item.quantity,
                        onDecrement: onDecrement,
                        onIncrement: onIncrement,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onRemove,
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: kSlate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Line total
                  Text(
                    (item.unitPrice * item.quantity).toJOD(),
                    style: AppTextStyles.priceMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _QtyStepper
// ─────────────────────────────────────────────────────────────────────────────

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepBtn(
              icon: Icons.remove,
              onTap: qty > 1 ? onDecrement : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                '$qty',
                style: const TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kNavy,
                ),
              ),
            ),
            _StepBtn(
              icon: Icons.add,
              onTap: onIncrement,
            ),
          ],
        ),
      );
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 16,
            color: onTap == null ? kBorder : kNavy,
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kNavy,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: kBorder, height: 1),
            const SizedBox(height: 16),

            // Subtotal
            _SummaryRow(
              label: 'Subtotal',
              value: ctrl.subtotal.toJOD(),
            ),
            const SizedBox(height: 8),

            // Delivery
            _SummaryRow(
              label: 'Delivery',
              value: 0.0.toJODOrFree(),
            ),

            const SizedBox(height: 16),
            const Divider(color: kBorder, height: 1),
            const SizedBox(height: 16),

            // Total
            _SummaryRow(
              label: 'Total',
              value: ctrl.grandTotal.toJOD(),
              bold: true,
            ),
            const SizedBox(height: 24),

            // Checkout CTA
            PrimaryButton(
              label: 'Proceed to Checkout',
              onPressed: () => Get.toNamed(AppRoutes.checkout),
            ),

            const SizedBox(height: 12),

            // Continue shopping
            Center(
              child: GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.shop),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 13,
                    color: kSlate,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: kSlate),
          ),
          Text(
            value,
            style: bold
                ? AppTextStyles.priceMedium
                : AppTextStyles.bodyMedium,
          ),
        ],
      );
}
