// lib/views/customer/checkout_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/account_controller.dart';
import 'package:marcat/controllers/admin_controller.dart';
import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/core/constants/app_text_styles.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/models/cart_item_model.dart';
import 'package:marcat/models/customer_address_model.dart';
import 'package:marcat/models/enums.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/buttons.dart';
import 'shared/section_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CheckoutPage
// ─────────────────────────────────────────────────────────────────────────────

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // ── State ─────────────────────────────────────────────────────────────────
  final _addresses = <CustomerAddressModel>[];
  int? _selectedAddressId;
  DeliveryMethod? _selectedDelivery;
  bool _isPlacingOrder = false;
  bool _loadingAddresses = true;

  // ── Controllers ───────────────────────────────────────────────────────────
  CartController get _cart => Get.find<CartController>();
  AccountController get _account => Get.find<AccountController>();
  AuthController get _auth => Get.find<AuthController>();
  AdminController get _admin => Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final uid = _auth.state.value.user?.id;
    if (uid == null) return;
    try {
      await _account.loadAddresses(uid);
      if (mounted) {
        setState(() {
          _addresses.addAll(_account.addresses);
          final def = _addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => _addresses.isEmpty
                ? throw StateError('empty')
                : _addresses.first,
          );
          _selectedAddressId = def.id;
          _loadingAddresses = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAddresses = false);
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedAddressId == null) {
      Get.snackbar('Missing Address', 'Please select a delivery address.');
      return;
    }
    if (_cart.items.isEmpty) return;

    setState(() => _isPlacingOrder = true);
    try {
      final uid = _auth.state.value.user!.id;
      await _cart.placeOrder(
        customerId: uid,
        addressId: _selectedAddressId!,
        deliveryMethod: _selectedDelivery,
      );
      Get.offAllNamed(AppRoutes.orders);
      Get.snackbar(
        'Order Placed!',
        'Your order has been confirmed.',
        backgroundColor: kNavy,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 900;

    return CustomerScaffold(
      page: 'Checkout',
      pageImage:
          'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=1600&q=80',
      body: FB5Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                eyebrow: 'Checkout',
                title: 'Complete Your Order',
              ),
              const SizedBox(height: 32),
              isDesktop
                  ? FB5Row(
                      children: [
                        FB5Col(
                          classNames: 'col-lg-7 col-12',
                          child: _CheckoutForm(
                            addresses: _addresses,
                            selectedAddressId: _selectedAddressId,
                            selectedDelivery: _selectedDelivery,
                            loadingAddresses: _loadingAddresses,
                            onAddressSelected: (id) => setState(
                              () => _selectedAddressId = id,
                            ),
                            onDeliverySelected: (d) => setState(
                              () => _selectedDelivery = d,
                            ),
                          ),
                        ),
                        FB5Col(
                          classNames: 'col-lg-5 col-12',
                          child: _CheckoutSummary(
                            cart: _cart,
                            onPlaceOrder: _placeOrder,
                            isPlacing: _isPlacingOrder,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _CheckoutForm(
                          addresses: _addresses,
                          selectedAddressId: _selectedAddressId,
                          selectedDelivery: _selectedDelivery,
                          loadingAddresses: _loadingAddresses,
                          onAddressSelected: (id) =>
                              setState(() => _selectedAddressId = id),
                          onDeliverySelected: (d) =>
                              setState(() => _selectedDelivery = d),
                        ),
                        const SizedBox(height: 32),
                        _CheckoutSummary(
                          cart: _cart,
                          onPlaceOrder: _placeOrder,
                          isPlacing: _isPlacingOrder,
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CheckoutForm
// ─────────────────────────────────────────────────────────────────────────────

class _CheckoutForm extends StatelessWidget {
  const _CheckoutForm({
    required this.addresses,
    required this.selectedAddressId,
    required this.selectedDelivery,
    required this.loadingAddresses,
    required this.onAddressSelected,
    required this.onDeliverySelected,
  });

  final List<CustomerAddressModel> addresses;
  final int? selectedAddressId;
  final DeliveryMethod? selectedDelivery;
  final bool loadingAddresses;
  final ValueChanged<int> onAddressSelected;
  final ValueChanged<DeliveryMethod?> onDeliverySelected;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Delivery Address ──────────────────────────────────────────
          _SectionCard(
            title: 'Delivery Address',
            child: loadingAddresses
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(
                        color: kGold,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : addresses.isEmpty
                    ? const _AddAddressPrompt()
                    : Column(
                        children: addresses
                            .map(
                              (a) => _AddressTile(
                                address: a,
                                selected: a.id == selectedAddressId,
                                onTap: () => onAddressSelected(a.id),
                              ),
                            )
                            .toList(),
                      ),
          ),
          const SizedBox(height: 20),

          // ── Delivery Method ───────────────────────────────────────────
          _SectionCard(
            title: 'Delivery Method',
            child: Column(
              children: DeliveryMethod.values.map((method) {
                final selected = selectedDelivery == method;
                return _DeliveryMethodTile(
                  method: method,
                  selected: selected,
                  onTap: () => onDeliverySelected(method),
                );
              }).toList(),
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _CheckoutSummary
// ─────────────────────────────────────────────────────────────────────────────

class _CheckoutSummary extends StatelessWidget {
  const _CheckoutSummary({
    required this.cart,
    required this.onPlaceOrder,
    required this.isPlacing,
  });

  final CartController cart;
  final VoidCallback onPlaceOrder;
  final bool isPlacing;

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
            Text('Order Summary', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            const Divider(color: kBorder, height: 1),
            const SizedBox(height: 12),

            // Items preview
            Obx(() => Column(
                  children: cart.items
                      .map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.productName}  ×${item.quantity}',
                                    style: AppTextStyles.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  (item.unitPrice * item.quantity).toJOD(),
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                )),

            const SizedBox(height: 12),
            const Divider(color: kBorder, height: 1),
            const SizedBox(height: 12),

            // Totals
            _Row('Subtotal', cart.subtotal.toJOD()),
            const SizedBox(height: 6),
            _Row('Delivery', cart.deliveryFee.toJODOrFree()),
            const SizedBox(height: 12),
            const Divider(color: kBorder, height: 1),
            const SizedBox(height: 12),
            _Row('Total', cart.grandTotal.toJOD(), bold: true),
            const SizedBox(height: 24),

            PrimaryButton(
              label: 'Place Order',
              onPressed: onPlaceOrder,
              loading: isPlacing,
            ),
          ],
        ),
      );
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall.copyWith(color: kSlate)),
          Text(
            value,
            style: bold ? AppTextStyles.priceMedium : AppTextStyles.bodyMedium,
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionCard
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            child,
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _AddressTile
// ─────────────────────────────────────────────────────────────────────────────

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final CustomerAddressModel address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? kNavy.withAlpha(10) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? kNavy : kBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selected ? kNavy : kSlate,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label ?? 'Address',
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        address.addressLine1,
                        address.city,
                      ].where((s) => s != null && s.isNotEmpty).join(', '),
                      style: AppTextStyles.bodySmall.copyWith(color: kSlate),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _DeliveryMethodTile
// ─────────────────────────────────────────────────────────────────────────────

class _DeliveryMethodTile extends StatelessWidget {
  const _DeliveryMethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final DeliveryMethod method;
  final bool selected;
  final VoidCallback onTap;

  String get _label => switch (method) {
        DeliveryMethod.standard => 'Standard Delivery (3–5 days)',
        DeliveryMethod.express => 'Express Delivery (1–2 days)',
        DeliveryMethod.pickup => 'Store Pickup',
      };

  String get _price => switch (method) {
        DeliveryMethod.standard => 'JD 2.000',
        DeliveryMethod.express => 'JD 5.000',
        DeliveryMethod.pickup => 'Free',
      };

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? kNavy.withAlpha(10) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? kNavy : kBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selected ? kNavy : kSlate,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(_label, style: AppTextStyles.bodyMedium),
              ),
              Text(
                _price,
                style: AppTextStyles.priceSmall,
              ),
            ],
          ),
        ),
      );
}

class _AddAddressPrompt extends StatelessWidget {
  const _AddAddressPrompt();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.add_location_alt_outlined,
                size: 20, color: kSlate),
            const SizedBox(width: 12),
            Text(
              'No saved addresses. Go to Profile to add one.',
              style: AppTextStyles.bodySmall.copyWith(color: kSlate),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// DeliveryMethod enum (local to checkout — not a DB enum)
// ─────────────────────────────────────────────────────────────────────────────

enum DeliveryMethod { standard, express, pickup }
