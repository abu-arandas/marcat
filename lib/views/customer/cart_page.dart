// lib/views/customer/cart_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// FIX: cart_repository.dart → cart_controller.dart
import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/models/cart_item_model.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/empty_state.dart';
import 'shared/marcat_buttons.dart';
import 'shared/section_header.dart';
import 'package:marcat/core/router/app_router.dart';

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

class _CartBody extends StatelessWidget {
  const _CartBody();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (ctrl) {
        // FIX: was ctrl.isCartLoading — renamed to isLoading in merged CartController
        if (ctrl.isCartLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: CircularProgressIndicator(strokeWidth: 2),
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
                  'Looks like you haven\'t added anything yet.\nStart shopping to fill it up.',
              actionLabel: 'Continue Shopping',
              onAction: () => Get.toNamed(AppRoutes.shop),
            );
          }

          return Container(
            constraints: const BoxConstraints(maxWidth: 1140),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: _CartItemsList(ctrl: ctrl)),
                        const SizedBox(width: 40),
                        SizedBox(width: 360, child: _OrderSummary(ctrl: ctrl)),
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

// ── Cart Items List ────────────────────────────────────────────────────────────

class _CartItemsList extends StatelessWidget {
  final CartController ctrl;
  const _CartItemsList({required this.ctrl});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            eyebrow: 'Review',
            title: 'Your Items',
            action: TextButton(
              onPressed: () => _showClearConfirm(context),
              style: TextButton.styleFrom(foregroundColor: kRed),
              child: const Text('Clear All',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ctrl.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) =>
                _CartItemRow(item: ctrl.items[index], ctrl: ctrl),
          ),
        ],
      );

  void _showClearConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Clear Cart?',
            style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kNavy)),
        content: const Text(
            'This will remove all items from your bag. This action cannot be undone.',
            style: TextStyle(color: kSlate, height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel',
                  style:
                      TextStyle(color: kSlate, fontWeight: FontWeight.w600))),
          ElevatedButton(
            onPressed: () {
              ctrl.clearCart();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Clear',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItemModel item;
  final CartController ctrl;
  const _CartItemRow({required this.item, required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 90,
                height: 110,
                child: item.primaryImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.primaryImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: kCream),
                      )
                    : Container(
                        color: kCream,
                        child: const Icon(Icons.image_outlined, color: kSlate)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item.productName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kNavy)),
                  const SizedBox(height: 4),
                  Text('Size: ${item.sizeLabel}',
                      style: const TextStyle(fontSize: 12, color: kSlate)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _QtyStepper(
                        qty: item.quantity,
                        onDecrement: () => ctrl.updateQuantity(
                          item.productSizeId,
                          item.colorId,
                          item.quantity - 1,
                        ),
                        onIncrement: () => ctrl.updateQuantity(
                          item.productSizeId,
                          item.colorId,
                          item.quantity + 1,
                        ),
                      ),
                      Text(
                        'JOD ${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: kNavy),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () =>
                  ctrl.removeItem(item.productSizeId, item.colorId),
              icon: const Icon(Icons.close_rounded, size: 18, color: kSlate),
              style: IconButton.styleFrom(
                backgroundColor: kCream,
                padding: const EdgeInsets.all(6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ],
        ),
      );
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  const _QtyStepper(
      {required this.qty,
      required this.onDecrement,
      required this.onIncrement});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: kBorderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepBtn(icon: Icons.remove_rounded, onTap: onDecrement),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('$qty',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: kNavy)),
            ),
            _StepBtn(icon: Icons.add_rounded, onTap: onIncrement),
          ],
        ),
      );
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          color: Colors.transparent,
          child: Icon(icon, size: 16, color: kNavy),
        ),
      );
}

// ── Order Summary ──────────────────────────────────────────────────────────────

class _OrderSummary extends StatefulWidget {
  final CartController ctrl;
  const _OrderSummary({required this.ctrl});

  @override
  State<_OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<_OrderSummary> {
  final _couponCtrl = TextEditingController();
  bool _applyingCoupon = false;
  String? _couponError;

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _applyingCoupon = true;
      _couponError = null;
    });
    try {
      await widget.ctrl.applyCoupon(code);
    } catch (e) {
      setState(() => _couponError = 'Invalid or expired coupon code.');
    } finally {
      setState(() => _applyingCoupon = false);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Summary',
                style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kNavy)),
            const SizedBox(height: 24),
            Obx(() => _SummaryRow(
                  label: 'Subtotal',
                  value: 'JOD ${widget.ctrl.subtotal.toStringAsFixed(2)}',
                )),
            const SizedBox(height: 10),
            Obx(() {
              final offer = widget.ctrl.appliedOffer.value;
              if (offer == null) return const SizedBox.shrink();
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SummaryRow(
                    label: '${offer.offerName} (Coupon)',
                    value: '- JOD ${widget.ctrl.discountTotal.toStringAsFixed(2)}',
                    accent: true,
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }),
            _SummaryRow(
                label: 'Shipping',
                value: 'Calculated at checkout',
                muted: true),
            const SizedBox(height: 16),
            const Divider(color: kBorderColor),
            const SizedBox(height: 16),
            Obx(() => Row(children: [
                  const Text('Total',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kNavy)),
                  const Spacer(),
                  Text(
                    'JOD ${widget.ctrl.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: kNavy),
                  ),
                ])),
            const SizedBox(height: 24),
            Obx(() {
              if (widget.ctrl.appliedOffer.value == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Have a coupon?',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: kSlate)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _couponCtrl,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(fontSize: 13, color: kNavy),
                          decoration: InputDecoration(
                            hintText: 'Enter code',
                            hintStyle:
                                const TextStyle(color: kSlate, fontSize: 13),
                            errorText: _couponError,
                            filled: true,
                            fillColor: kCream,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _applyingCoupon ? null : _applyCoupon,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kNavy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _applyingCoupon
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Apply',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                  ],
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.ctrl.appliedOffer.value!.offerName,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.ctrl.removeCoupon,
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: kSlate),
                    ),
                  ]),
                );
              }
            }),
            PrimaryButton(
              label: 'Proceed to Checkout',
              onPressed: () => Get.toNamed(AppRoutes.checkout),
              icon: Icons.lock_outline_rounded,
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Get.toNamed(AppRoutes.shop),
                style: TextButton.styleFrom(foregroundColor: kSlate),
                child: const Text('Continue Shopping',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: kBorderColor),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _TrustBadge(icon: Icons.lock_outline_rounded, label: 'Secure'),
                _TrustBadge(
                    icon: Icons.local_shipping_outlined,
                    label: 'Free Shipping'),
                _TrustBadge(icon: Icons.replay_outlined, label: 'Easy Returns'),
              ],
            ),
          ],
        ),
      );
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool accent;
  final bool muted;
  const _SummaryRow(
      {required this.label,
      required this.value,
      this.accent = false,
      this.muted = false});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: muted ? kSlate : kNavy,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  color: accent ? Colors.green : (muted ? kSlate : kNavy),
                  fontWeight: FontWeight.w700)),
        ],
      );
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: kSlate),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: kSlate, fontWeight: FontWeight.w500)),
        ],
      );
}
