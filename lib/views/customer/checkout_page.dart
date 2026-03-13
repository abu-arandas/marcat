// lib/views/customer/checkout_page.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marcat/models/cart_item_model.dart';
import 'package:marcat/models/customer_address_model.dart';
// FIX: all repository/provider imports → merged controllers
import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/controllers/account_controller.dart';
import 'package:marcat/controllers/auth_controller.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/marcat_buttons.dart';
import 'package:marcat/core/router/app_router.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final addresses = <CustomerAddressModel>[];
  int? selectedAddressId;
  bool isLoadingAddresses = true;
  bool isPlacingOrder = false;
  int step = 0; // 0=address 1=review 2=success

  // New address form
  bool showAddressForm = false;
  String label = 'Home';
  late final TextEditingController addressLine1Ctrl;
  late final TextEditingController addressLine2Ctrl;
  late final TextEditingController cityCtrl;
  late final TextEditingController postalCodeCtrl;
  final formKey = GlobalKey<FormState>();

  AccountController get _accountCtrl => Get.find<AccountController>();
  CartController get _cart => Get.find<CartController>();
  AuthController get _auth => Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    addressLine1Ctrl = TextEditingController();
    addressLine2Ctrl = TextEditingController();
    cityCtrl = TextEditingController();
    postalCodeCtrl = TextEditingController();
    _loadAddresses();
  }

  @override
  void dispose() {
    addressLine1Ctrl.dispose();
    addressLine2Ctrl.dispose();
    cityCtrl.dispose();
    postalCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    final user = _auth.user;
    if (user == null) return;
    if (mounted) setState(() => isLoadingAddresses = true);
    try {
      await _accountCtrl.fetchAddresses(user.id);
      if (mounted) {
        setState(() {
          addresses.clear();
          addresses.addAll(_accountCtrl.addresses);
          final def = addresses.where((a) => a.isDefault).firstOrNull;
          selectedAddressId = def?.id ?? addresses.firstOrNull?.id;
          isLoadingAddresses = false;
        });
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      if (mounted) setState(() => isLoadingAddresses = false);
    }
  }

  Future<void> addAddress() async {
    if (!formKey.currentState!.validate()) return;
    final user = _auth.user;
    if (user == null) return;
    try {
      await _accountCtrl.addAddress(user.id, {
        'label': label,
        'full_address': [
          addressLine1Ctrl.text.trim(),
          if (addressLine2Ctrl.text.trim().isNotEmpty)
            addressLine2Ctrl.text.trim(),
        ].join(', '),
        'city': cityCtrl.text.trim(),
        'country': 'Jordan',
        'is_default': addresses.isEmpty,
      });
      if (mounted) {
        setState(() {
          addresses.clear();
          addresses.addAll(_accountCtrl.addresses);
          if (addresses.isNotEmpty) {
            selectedAddressId = addresses.last.id;
          }
          showAddressForm = false;
          _clearForm();
        });
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void _clearForm() {
    addressLine1Ctrl.clear();
    addressLine2Ctrl.clear();
    cityCtrl.clear();
    postalCodeCtrl.clear();
    label = 'Home';
  }

  Future<void> placeOrder() async {
    final user = _auth.user;
    if (user == null || selectedAddressId == null) return;
    if (mounted) setState(() => isPlacingOrder = true);
    try {
      const storeId = 1;
      final saleId = await _cart.createOrder(
        storeId: storeId,
        shippingAddressId: selectedAddressId!,
        cartItems: _cart.items,
        channel: 'Online',
        customerId: user.id,
        discountTotalAmt: _cart.discountTotal,
        shippingCostAmt: 0.0, // TODO
        subtotalAmt: _cart.subtotal,
        taxTotalAmt: 0.0, // TODO
        offerId: _cart.appliedOffer.value?.offerId,
      );
      if (mounted) {
        setState(() {
          step = 2;
        });
      }
      Get.snackbar(
          'Order Placed!', 'Your order #$saleId has been placed successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomerScaffold(
      page: 'Checkout',
      pageImage:
          'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=1600&q=80',
      body: _CheckoutBody(
        step: step,
        addresses: addresses,
        selectedAddressId: selectedAddressId,
        isLoadingAddresses: isLoadingAddresses,
        isPlacingOrder: isPlacingOrder,
        showAddressForm: showAddressForm,
        label: label,
        addressLine1Ctrl: addressLine1Ctrl,
        addressLine2Ctrl: addressLine2Ctrl,
        cityCtrl: cityCtrl,
        postalCodeCtrl: postalCodeCtrl,
        formKey: formKey,
        onPlaceOrder: placeOrder,
        onAddAddress: addAddress,
        onSelectAddress: (id) => setState(() => selectedAddressId = id),
        onStepChanged: (s) => setState(() => step = s),
        onShowAddressForm: (show) => setState(() => showAddressForm = show),
        onLabelChanged: (l) => setState(() => label = l),
      ),
    );
  }
}

class _CheckoutBody extends StatelessWidget {
  final int step;
  final List<CustomerAddressModel> addresses;
  final int? selectedAddressId;
  final bool isLoadingAddresses;
  final bool isPlacingOrder;
  final bool showAddressForm;
  final String label;
  final TextEditingController addressLine1Ctrl;
  final TextEditingController addressLine2Ctrl;
  final TextEditingController cityCtrl;
  final TextEditingController postalCodeCtrl;
  final GlobalKey<FormState> formKey;
  final VoidCallback onPlaceOrder;
  final VoidCallback onAddAddress;
  final ValueChanged<int?> onSelectAddress;
  final ValueChanged<int> onStepChanged;
  final ValueChanged<bool> onShowAddressForm;
  final ValueChanged<String> onLabelChanged;

  const _CheckoutBody({
    required this.step,
    required this.addresses,
    required this.selectedAddressId,
    required this.isLoadingAddresses,
    required this.isPlacingOrder,
    required this.showAddressForm,
    required this.label,
    required this.addressLine1Ctrl,
    required this.addressLine2Ctrl,
    required this.cityCtrl,
    required this.postalCodeCtrl,
    required this.formKey,
    required this.onPlaceOrder,
    required this.onAddAddress,
    required this.onSelectAddress,
    required this.onStepChanged,
    required this.onShowAddressForm,
    required this.onLabelChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (step == 2) return _SuccessState();

    final isDesktop = MediaQuery.sizeOf(context).width > 900;
    final cart = Get.find<CartController>();

    return Container(
      constraints: const BoxConstraints(maxWidth: 1140),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _CheckoutSteps(
                      step: step,
                      addresses: addresses,
                      selectedAddressId: selectedAddressId,
                      isLoadingAddresses: isLoadingAddresses,
                      isPlacingOrder: isPlacingOrder,
                      showAddressForm: showAddressForm,
                      label: label,
                      addressLine1Ctrl: addressLine1Ctrl,
                      addressLine2Ctrl: addressLine2Ctrl,
                      cityCtrl: cityCtrl,
                      postalCodeCtrl: postalCodeCtrl,
                      formKey: formKey,
                      onPlaceOrder: onPlaceOrder,
                      onAddAddress: onAddAddress,
                      onSelectAddress: onSelectAddress,
                      onStepChanged: onStepChanged,
                      onShowAddressForm: onShowAddressForm,
                      onLabelChanged: onLabelChanged,
                    ),
                  ),
                  const SizedBox(width: 40),
                  SizedBox(
                      width: 340, child: _CheckoutOrderSummary(cart: cart)),
                ],
              )
            : Column(
                children: [
                  _CheckoutSteps(
                    step: step,
                    addresses: addresses,
                    selectedAddressId: selectedAddressId,
                    isLoadingAddresses: isLoadingAddresses,
                    isPlacingOrder: isPlacingOrder,
                    showAddressForm: showAddressForm,
                    label: label,
                    addressLine1Ctrl: addressLine1Ctrl,
                    addressLine2Ctrl: addressLine2Ctrl,
                    cityCtrl: cityCtrl,
                    postalCodeCtrl: postalCodeCtrl,
                    formKey: formKey,
                    onPlaceOrder: onPlaceOrder,
                    onAddAddress: onAddAddress,
                    onSelectAddress: onSelectAddress,
                    onStepChanged: onStepChanged,
                    onShowAddressForm: onShowAddressForm,
                    onLabelChanged: onLabelChanged,
                  ),
                  const SizedBox(height: 32),
                  _CheckoutOrderSummary(cart: cart),
                ],
              ),
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────

class _CheckoutSteps extends StatelessWidget {
  final int step;
  final List<CustomerAddressModel> addresses;
  final int? selectedAddressId;
  final bool isLoadingAddresses;
  final bool isPlacingOrder;
  final bool showAddressForm;
  final String label;
  final TextEditingController addressLine1Ctrl;
  final TextEditingController addressLine2Ctrl;
  final TextEditingController cityCtrl;
  final TextEditingController postalCodeCtrl;
  final GlobalKey<FormState> formKey;
  final VoidCallback onPlaceOrder;
  final VoidCallback onAddAddress;
  final ValueChanged<int?> onSelectAddress;
  final ValueChanged<int> onStepChanged;
  final ValueChanged<bool> onShowAddressForm;
  final ValueChanged<String> onLabelChanged;

  const _CheckoutSteps({
    required this.step,
    required this.addresses,
    required this.selectedAddressId,
    required this.isLoadingAddresses,
    required this.isPlacingOrder,
    required this.showAddressForm,
    required this.label,
    required this.addressLine1Ctrl,
    required this.addressLine2Ctrl,
    required this.cityCtrl,
    required this.postalCodeCtrl,
    required this.formKey,
    required this.onPlaceOrder,
    required this.onAddAddress,
    required this.onSelectAddress,
    required this.onStepChanged,
    required this.onShowAddressForm,
    required this.onLabelChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepIndicator(current: step),
          const SizedBox(height: 32),
          if (step == 0)
            _AddressStep(
              addresses: addresses,
              selectedAddressId: selectedAddressId,
              isLoadingAddresses: isLoadingAddresses,
              showAddressForm: showAddressForm,
              label: label,
              addressLine1Ctrl: addressLine1Ctrl,
              addressLine2Ctrl: addressLine2Ctrl,
              cityCtrl: cityCtrl,
              postalCodeCtrl: postalCodeCtrl,
              formKey: formKey,
              onAddAddress: onAddAddress,
              onSelectAddress: onSelectAddress,
              onStepChanged: onStepChanged,
              onShowAddressForm: onShowAddressForm,
              onLabelChanged: onLabelChanged,
            ),
          if (step == 1)
            _ReviewStep(
              addresses: addresses,
              selectedAddressId: selectedAddressId,
              isPlacingOrder: isPlacingOrder,
              onPlaceOrder: onPlaceOrder,
              onStepChanged: onStepChanged,
            ),
        ],
      );
}

class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Step(index: 0, label: 'Address', current: current),
          _StepLine(active: current > 0),
          _Step(index: 1, label: 'Review', current: current),
        ],
      );
}

class _Step extends StatelessWidget {
  final int index, current;
  final String label;
  const _Step(
      {required this.index, required this.label, required this.current});

  @override
  Widget build(BuildContext context) {
    final done = index < current;
    final active = index == current;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: done || active ? kNavy : kCream,
            shape: BoxShape.circle,
            border: Border.all(color: done || active ? kNavy : kBorderColor),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : Text('${index + 1}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : kSlate)),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: active || done ? FontWeight.w700 : FontWeight.w500,
                color: active || done ? kNavy : kSlate)),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: active ? kNavy : kBorderColor,
      );
}

// ── Step 0: Address ───────────────────────────────────────────────────────────

class _AddressStep extends StatelessWidget {
  final List<CustomerAddressModel> addresses;
  final int? selectedAddressId;
  final bool isLoadingAddresses;
  final bool showAddressForm;
  final String label;
  final TextEditingController addressLine1Ctrl;
  final TextEditingController addressLine2Ctrl;
  final TextEditingController cityCtrl;
  final TextEditingController postalCodeCtrl;
  final GlobalKey<FormState> formKey;
  final VoidCallback onAddAddress;
  final ValueChanged<int?> onSelectAddress;
  final ValueChanged<int> onStepChanged;
  final ValueChanged<bool> onShowAddressForm;
  final ValueChanged<String> onLabelChanged;

  const _AddressStep({
    required this.addresses,
    required this.selectedAddressId,
    required this.isLoadingAddresses,
    required this.showAddressForm,
    required this.label,
    required this.addressLine1Ctrl,
    required this.addressLine2Ctrl,
    required this.cityCtrl,
    required this.postalCodeCtrl,
    required this.formKey,
    required this.onAddAddress,
    required this.onSelectAddress,
    required this.onStepChanged,
    required this.onShowAddressForm,
    required this.onLabelChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingAddresses) {
      return const Center(
          child: CircularProgressIndicator(color: kNavy, strokeWidth: 2));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Delivery Address',
            style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kNavy)),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: addresses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final addr = addresses[index];
            return _AddressCard(
              address: addr,
              selected: selectedAddressId == addr.id,
              onSelect: () => onSelectAddress(addr.id),
            );
          },
        ),
        if (showAddressForm) ...[
          const SizedBox(height: 16),
          _AddAddressForm(
            label: label,
            addressLine1Ctrl: addressLine1Ctrl,
            addressLine2Ctrl: addressLine2Ctrl,
            cityCtrl: cityCtrl,
            postalCodeCtrl: postalCodeCtrl,
            formKey: formKey,
            onAddAddress: onAddAddress,
            onShowAddressForm: onShowAddressForm,
            onLabelChanged: onLabelChanged,
          ),
        ] else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: OutlinedButton.icon(
              onPressed: () => onShowAddressForm(true),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add New Address',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: kNavy,
                side: const BorderSide(color: kNavy),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Continue to Review',
          onPressed: selectedAddressId == null ? null : () => onStepChanged(1),
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final CustomerAddressModel address;
  final bool selected;
  final VoidCallback onSelect;
  const _AddressCard(
      {required this.address, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? kNavy : kBorderColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? kNavy : Colors.transparent,
                  border:
                      Border.all(color: selected ? kNavy : kSlate, width: 2),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded,
                        size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(address.label,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: kNavy)),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: kGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('DEFAULT',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: kGold,
                                    letterSpacing: 1)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [address.fullAddress, address.city].join(', '),
                      style: const TextStyle(
                          fontSize: 13, color: kSlate, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _AddAddressForm extends StatelessWidget {
  final String label;
  final TextEditingController addressLine1Ctrl;
  final TextEditingController addressLine2Ctrl;
  final TextEditingController cityCtrl;
  final TextEditingController postalCodeCtrl;
  final GlobalKey<FormState> formKey;
  final VoidCallback onAddAddress;
  final ValueChanged<bool> onShowAddressForm;
  final ValueChanged<String> onLabelChanged;

  const _AddAddressForm({
    required this.label,
    required this.addressLine1Ctrl,
    required this.addressLine2Ctrl,
    required this.cityCtrl,
    required this.postalCodeCtrl,
    required this.formKey,
    required this.onAddAddress,
    required this.onShowAddressForm,
    required this.onLabelChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: kCream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderColor),
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('New Address',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kNavy)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => onShowAddressForm(false),
                    icon: const Icon(Icons.close_rounded,
                        size: 18, color: kSlate),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: ['Home', 'Work', 'Other'].map((l) {
                  final sel = label == l;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => onLabelChanged(l),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel ? kNavy : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sel ? kNavy : kBorderColor),
                        ),
                        child: Text(l,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : kNavy)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _CheckoutField(
                controller: addressLine1Ctrl,
                label: 'Street Address *',
                hint: 'e.g. 123 Main Street',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _CheckoutField(
                controller: addressLine2Ctrl,
                label: 'Apartment / Suite (optional)',
                hint: 'e.g. Apt 4B',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _CheckoutField(
                      controller: cityCtrl,
                      label: 'City *',
                      hint: 'Amman',
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CheckoutField(
                      controller: postalCodeCtrl,
                      label: 'Postal Code',
                      hint: '11110',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryButton(label: 'Save Address', onPressed: onAddAddress),
            ],
          ),
        ),
      );
}

class _CheckoutField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _CheckoutField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: kNavy)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(fontSize: 13, color: kNavy),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: kSlate, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kBorderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kNavy, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      );
}

// ── Step 1: Review ────────────────────────────────────────────────────────────

class _ReviewStep extends StatelessWidget {
  final List<CustomerAddressModel> addresses;
  final int? selectedAddressId;
  final bool isPlacingOrder;
  final VoidCallback onPlaceOrder;
  final ValueChanged<int> onStepChanged;

  const _ReviewStep({
    required this.addresses,
    required this.selectedAddressId,
    required this.isPlacingOrder,
    required this.onPlaceOrder,
    required this.onStepChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final addr = addresses.where((a) => a.id == selectedAddressId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review Your Order',
            style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kNavy)),
        const SizedBox(height: 20),
        if (addr != null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: kGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(addr.label,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kNavy)),
                      Text([addr.fullAddress, addr.city].join(', '),
                          style: const TextStyle(fontSize: 12, color: kSlate)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => onStepChanged(0),
                  child: const Text('Change',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kNavy)),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Obx(() => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _ReviewItemRow(item: cart.items[index]),
            )),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Place Order',
          onPressed: onPlaceOrder,
          loading: isPlacingOrder,
          icon: Icons.check_circle_outline_rounded,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => onStepChanged(0),
          style: TextButton.styleFrom(foregroundColor: kSlate),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back_rounded, size: 14),
              SizedBox(width: 6),
              Text('Back to Address',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewItemRow extends StatelessWidget {
  final CartItemModel item;
  const _ReviewItemRow({required this.item});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorderColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 56,
                height: 68,
                child: item.primaryImageUrl != null
                    ? Image.network(item.primaryImageUrl!, fit: BoxFit.cover)
                    : Container(color: kCream),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: kNavy)),
                  Text('Size: ${item.sizeLabel}',
                      style: const TextStyle(fontSize: 12, color: kSlate)),
                  Text('Qty: ${item.quantity}',
                      style: const TextStyle(fontSize: 12, color: kSlate)),
                ],
              ),
            ),
            Text(
              'JOD ${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: kNavy),
            ),
          ],
        ),
      );
}

// ── Checkout order summary sidebar ───────────────────────────────────────────

class _CheckoutOrderSummary extends StatelessWidget {
  final CartController cart;
  const _CheckoutOrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) => Obx(() {
        final shipping = cart.subtotal >= 50 ? 0.0 : 3.0;
        final total = cart.grandTotal + shipping;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kCream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Summary',
                  style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kNavy)),
              const SizedBox(height: 20),
              _Row('Subtotal', 'JOD ${cart.subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              if (cart.discountTotal > 0) ...[
                _Row('Discount',
                    '- JOD ${cart.discountTotal.toStringAsFixed(2)}',
                    green: true),
                const SizedBox(height: 8),
              ],
              _Row(
                  'Shipping',
                  shipping == 0
                      ? 'Free'
                      : 'JOD ${shipping.toStringAsFixed(2)}'),
              if (cart.subtotal < 50)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Add JOD ${(50 - cart.subtotal).toStringAsFixed(2)} more for free shipping',
                    style: const TextStyle(
                        fontSize: 11,
                        color: kSlate,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              const SizedBox(height: 16),
              const Divider(color: kBorderColor),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Total',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kNavy)),
                  const Spacer(),
                  Text('JOD ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: kNavy)),
                ],
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 13, color: kSlate),
                  SizedBox(width: 6),
                  Text('Secure checkout',
                      style: TextStyle(fontSize: 12, color: kSlate)),
                ],
              ),
            ],
          ),
        );
      });
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool green;
  const _Row(this.label, this.value, {this.green = false});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: kSlate)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: green ? Colors.green : kNavy)),
        ],
      );
}

// ── Success state ─────────────────────────────────────────────────────────────

class _SuccessState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration:
                    const BoxDecoration(color: kNavy, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded,
                    size: 44, color: Colors.white),
              ),
              const SizedBox(height: 28),
              const Text('Order Confirmed!',
                  style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: kNavy)),
              const SizedBox(height: 12),
              const Text(
                'Thank you for shopping with MARCAT.\nYou\'ll receive a confirmation email shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: kSlate, height: 1.7),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    child: PrimaryButton(
                      label: 'My Orders',
                      onPressed: () => Get.offAllNamed(AppRoutes.orders),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 180,
                    child: OutlineButton(
                      label: 'Keep Shopping',
                      onPressed: () => Get.offAllNamed(AppRoutes.shop),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
