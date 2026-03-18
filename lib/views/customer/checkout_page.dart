// lib/views/customer/checkout_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/account_controller.dart';
import 'package:marcat/controllers/admin_controller.dart';
import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/core/constants/app_text_styles.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/models/cart_item_model.dart';
import 'package:marcat/models/customer_address_model.dart';
import 'package:marcat/models/enums.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart'; // ✅ single source of colour constants
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
  int _step = 0; // 0 = address, 1 = review, 2 = success
  bool _isLoadingAddresses = false;
  bool _isPlacingOrder = false;
  bool _showAddressForm = false;
  String _label = 'Home';

  // ── Address form controllers ───────────────────────────────────────────────
  final _line1Ctrl = TextEditingController();
  final _line2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _addressFormKey = GlobalKey<FormState>();

  CartController get _cart => Get.find<CartController>();
  AccountController get _account => Get.find<AccountController>();
  AuthController get _auth => Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    final user = _auth.state.value.user;
    if (user == null) return;
    if (mounted) setState(() => _isLoadingAddresses = true);
    try {
      await _account.fetchAddresses(user.id);
      if (mounted) {
        setState(() {
          _addresses
            ..clear()
            ..addAll(_account.addresses);
          if (_addresses.isNotEmpty) {
            _selectedAddressId = _addresses.first.id;
          }
        });
      }
    } catch (_) {
      // Non-critical — user can still add a new address
    } finally {
      if (mounted) setState(() => _isLoadingAddresses = false);
    }
  }

  Future<void> _addAddress() async {
    if (!(_addressFormKey.currentState?.validate() ?? false)) return;
    final user = _auth.state.value.user;
    if (user == null) return;
    try {
      final newAddr = await _account.addAddress(user.id, {
        'label': _label,
        'full_address': _line1Ctrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'country': 'Jordan',
        'is_default': false,
        'latitude': 0,
        'longitude': 0,
      });
      if (mounted) {
        setState(() {
          _addresses.add(newAddr);
          _selectedAddressId = newAddr.id;
          _showAddressForm = false;
        });
        _line1Ctrl.clear();
        _line2Ctrl.clear();
        _cityCtrl.clear();
        _postalCtrl.clear();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.errorRed, colorText: Colors.white);
    }
  }

  Future<void> _placeOrder() async {
    final user = _auth.state.value.user;
    if (user == null) {
      Get.toNamed(AppRoutes.login);
      return;
    }
    if (_selectedAddressId == null) {
      Get.snackbar(
        'Address Required',
        'Please select or add a delivery address.',
        backgroundColor: AppColors.statusAmber,
        colorText: Colors.white,
      );
      return;
    }
    if (mounted) setState(() => _isPlacingOrder = true);
    try {
      final adminCtrl = Get.find<AdminController>();
      if (adminCtrl.stores.isEmpty) await adminCtrl.fetchStores();
      final storeId =
          adminCtrl.stores.isNotEmpty ? adminCtrl.stores.first.id : 1;

      final saleId = await _cart.createOrder(
        storeId: storeId,
        shippingAddressId: _selectedAddressId!,
        cartItems: _cart.items,
        channel: SaleChannel.online.dbValue,
        customerId: user.id,
        discountTotalAmt: _cart.discountTotal,
        shippingCostAmt: 0.0,
        subtotalAmt: _cart.subtotal,
        taxTotalAmt: 0.0,
        offerId: _cart.appliedOffer.value?.offerId,
      );

      if (mounted) setState(() => _step = 2);
      Get.snackbar(
        'Order Placed!',
        'Your order #$saleId has been placed successfully.',
        backgroundColor: AppColors.successGreen,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.errorRed, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) => CustomerScaffold(
        page: 'Checkout',
        body: FB5Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: _step == 2
                ? _SuccessStep(
                    onContinue: () => Get.toNamed(AppRoutes.orders),
                  )
                : _step == 1
                    ? _ReviewStep(
                        addresses: _addresses,
                        selectedAddressId: _selectedAddressId,
                        isPlacingOrder: _isPlacingOrder,
                        onPlaceOrder: _placeOrder,
                        onStepChanged: (s) => setState(() => _step = s),
                      )
                    : _AddressStep(
                        addresses: _addresses,
                        selectedAddressId: _selectedAddressId,
                        isLoading: _isLoadingAddresses,
                        showAddressForm: _showAddressForm,
                        label: _label,
                        line1Ctrl: _line1Ctrl,
                        line2Ctrl: _line2Ctrl,
                        cityCtrl: _cityCtrl,
                        postalCtrl: _postalCtrl,
                        formKey: _addressFormKey,
                        onSelectAddress: (id) =>
                            setState(() => _selectedAddressId = id),
                        onToggleForm: () => setState(
                            () => _showAddressForm = !_showAddressForm),
                        onLabelChanged: (l) => setState(() => _label = l),
                        onAddAddress: _addAddress,
                        onContinue: () {
                          if (_selectedAddressId == null) {
                            Get.snackbar(
                              'Address Required',
                              'Please select or add a delivery address.',
                              backgroundColor: AppColors.statusAmber,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          setState(() => _step = 1);
                        },
                      ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _AddressStep — step 0
// ─────────────────────────────────────────────────────────────────────────────

class _AddressStep extends StatelessWidget {
  const _AddressStep({
    required this.addresses,
    required this.selectedAddressId,
    required this.isLoading,
    required this.showAddressForm,
    required this.label,
    required this.line1Ctrl,
    required this.line2Ctrl,
    required this.cityCtrl,
    required this.postalCtrl,
    required this.formKey,
    required this.onSelectAddress,
    required this.onToggleForm,
    required this.onLabelChanged,
    required this.onAddAddress,
    required this.onContinue,
  });

  final List<CustomerAddressModel> addresses;
  final int? selectedAddressId;
  final bool isLoading;
  final bool showAddressForm;
  final String label;
  final TextEditingController line1Ctrl;
  final TextEditingController line2Ctrl;
  final TextEditingController cityCtrl;
  final TextEditingController postalCtrl;
  final GlobalKey<FormState> formKey;
  final ValueChanged<int> onSelectAddress;
  final VoidCallback onToggleForm;
  final ValueChanged<String> onLabelChanged;
  final VoidCallback onAddAddress;
  final VoidCallback onContinue;

  static const _labels = ['Home', 'Work', 'Other'];

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Step 1',
            title: 'Delivery Address',
            subtitle: 'Choose where you want your order delivered.',
          ),
          const SizedBox(height: 28),

          // ── Saved addresses ──────────────────────────────────────────────
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: kGold),
            )
          else ...[
            if (addresses.isNotEmpty)
              ...addresses.map((addr) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AddressTile(
                      address: addr,
                      selected: addr.id == selectedAddressId,
                      onTap: () => onSelectAddress(addr.id),
                    ),
                  )),

            // ── Add address toggle ─────────────────────────────────────
            TextButton.icon(
              onPressed: onToggleForm,
              icon: Icon(
                showAddressForm
                    ? Icons.remove_circle_outline_rounded
                    : Icons.add_circle_outline_rounded,
                size: 18,
              ),
              label: Text(
                showAddressForm ? 'Hide Form' : 'Add New Address',
                style: const TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(foregroundColor: kNavy),
            ),

            // ── Address form ───────────────────────────────────────────
            if (showAddressForm)
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'Label',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kSlate,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _labels.map((l) {
                        final isSelected = l == label;
                        return ChoiceChip(
                          label: Text(
                            l,
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : kNavy,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) => onLabelChanged(l),
                          selectedColor: kNavy,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: kBorder),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    _CheckoutField(
                      controller: line1Ctrl,
                      label: 'Address Line 1',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _CheckoutField(
                      controller: line2Ctrl,
                      label: 'Address Line 2 (optional)',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _CheckoutField(
                            controller: cityCtrl,
                            label: 'City',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CheckoutField(
                            controller: postalCtrl,
                            label: 'Postal Code',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Save Address',
                      onPressed: onAddAddress,
                      height: 46,
                    ),
                  ],
                ),
              ),
          ],

          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Continue to Review',
            onPressed: onContinue,
            icon: Icons.arrow_forward_rounded,
          ),
        ],
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? kNavy.withAlpha(13) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? kNavy : kBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: selected ? kNavy : kSlate,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label,
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${address.fullAddress}, ${address.city}',
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 12,
                        color: kSlate,
                      ),
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
// _ReviewStep — step 1
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.addresses,
    required this.selectedAddressId,
    required this.isPlacingOrder,
    required this.onPlaceOrder,
    required this.onStepChanged,
  });

  final List<CustomerAddressModel> addresses;
  final int? selectedAddressId;
  final bool isPlacingOrder;
  final VoidCallback onPlaceOrder;
  final ValueChanged<int> onStepChanged;

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final addr = addresses.where((a) => a.id == selectedAddressId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          eyebrow: 'Step 2',
          title: 'Review Your Order',
          subtitle: 'Confirm everything looks right before placing.',
        ),
        const SizedBox(height: 24),

        // ── Delivery address ─────────────────────────────────────────────
        if (addr != null)
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: kGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(addr.label, style: AppTextStyles.titleSmall),
                      Text(
                        '${addr.fullAddress}, ${addr.city}',
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 12,
                          color: kSlate,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => onStepChanged(0),
                  child: const Text(
                    'Change',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // ── Cart items ───────────────────────────────────────────────────
        Obx(() => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ReviewItem(item: cart.items[i]),
            )),

        const SizedBox(height: 24),

        // ── Totals ───────────────────────────────────────────────────────
        Obx(() {
          final subtotal = cart.subtotal;
          final discount = cart.discountTotal;
          final total = cart.grandTotal;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              children: [
                _TotalRow(label: 'Subtotal', value: subtotal.toJOD()),
                if (discount > 0)
                  _TotalRow(
                    label: 'Discount',
                    value: '-${discount.toJOD()}',
                    color: kRed,
                  ),
                _TotalRow(
                  label: 'Shipping',
                  value: 'Free',
                  color: AppColors.successGreen,
                ),
                const Divider(color: kBorder, height: 20),
                _TotalRow(
                  label: 'Total',
                  value: total.toJOD(),
                  bold: true,
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 32),

        PrimaryButton(
          label: 'Place Order',
          onPressed: isPlacingOrder ? null : onPlaceOrder,
          loading: isPlacingOrder,
          icon: Icons.check_circle_outline_rounded,
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => onStepChanged(0),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            side: const BorderSide(color: kBorder),
            foregroundColor: kNavy,
          ),
          child: const Text(
            'Back to Address',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 68,
              decoration: BoxDecoration(
                color: kCream,
                borderRadius: BorderRadius.circular(6),
              ),
              child: item.primaryImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        item.primaryImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const ColoredBox(color: AppColors.marcatCream),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName,
                      style: AppTextStyles.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    'Qty: ${item.quantity}',
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 12,
                      color: kSlate,
                    ),
                  ),
                ],
              ),
            ),
            Text(item.lineTotal.toJOD(), style: AppTextStyles.priceMedium),
          ],
        ),
      );
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.color,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: bold
                  ? AppTextStyles.titleSmall
                  : AppTextStyles.bodyMedium.copyWith(color: kSlate),
            ),
            Text(
              value,
              style:
                  (bold ? AppTextStyles.priceMedium : AppTextStyles.bodyMedium)
                      .copyWith(color: color),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _SuccessStep — step 2
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessStep extends StatelessWidget {
  const _SuccessStep({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.successGreenLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 40,
                color: AppColors.successGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Order Placed!',
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: kNavy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "Thank you for your order.\nWe'll notify you when it ships.",
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 15,
                color: kSlate,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: PrimaryButton(
                label: 'View My Orders',
                onPressed: onContinue,
                icon: Icons.receipt_long_outlined,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _CheckoutField — shared form input
// ─────────────────────────────────────────────────────────────────────────────

class _CheckoutField extends StatelessWidget {
  const _CheckoutField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 14,
          color: kNavy,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 13,
            color: kSlate,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kNavy, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.errorRed),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
