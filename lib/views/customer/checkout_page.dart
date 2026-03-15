// lib/views/customer/checkout_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marcat/models/cart_item_model.dart';
import 'package:marcat/models/customer_address_model.dart';
import 'package:marcat/models/enums.dart';
import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/controllers/account_controller.dart';
import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/controllers/admin_controller.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/core/extensions/currency_extensions.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/marcat_buttons.dart';

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
  int step = 0; // 0 = address, 1 = review, 2 = success

  // New address form state
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
          addresses
            ..clear()
            ..addAll(_accountCtrl.addresses);
          final def = addresses.where((a) => a.isDefault).firstOrNull;
          selectedAddressId = def?.id ?? addresses.firstOrNull?.id;
          isLoadingAddresses = false;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load addresses: ${e.toString()}');
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
          addresses
            ..clear()
            ..addAll(_accountCtrl.addresses);
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
    if (user == null) {
      Get.snackbar(
        'Authentication Required',
        'Please sign in to place an order.',
        snackPosition: SnackPosition.TOP,
      );
      Get.toNamed(AppRoutes.login);
      return;
    }
    if (selectedAddressId == null) {
      Get.snackbar(
        'Address Required',
        'Please select or add a delivery address.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (mounted) setState(() => isPlacingOrder = true);

    try {
      final adminCtrl = Get.find<AdminController>();
      if (adminCtrl.stores.isEmpty) {
        await adminCtrl.fetchStores(activeOnly: true);
      }
      final onlineStoreId =
          adminCtrl.stores.isNotEmpty ? adminCtrl.stores.first.id : 1;

      final saleId = await _cart.createOrder(
        storeId: onlineStoreId,
        shippingAddressId: selectedAddressId!,
        cartItems: _cart.items,
        channel: SaleChannel.online.dbValue,
        customerId: user.id,
        discountTotalAmt: _cart.discountTotal,
        shippingCostAmt: 0.0, // TODO: implement shipping cost calculator
        subtotalAmt: _cart.subtotal,
        taxTotalAmt: 0.0, // TODO: implement tax calculation
        offerId: _cart.appliedOffer.value?.offerId,
      );

      if (mounted) {
        setState(() => step = 2);
      }
      Get.snackbar(
        'Order Placed!',
        'Your order #$saleId has been placed successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      // FIX: was no catch block — isPlacingOrder stayed true permanently on
      // failure, locking the user out of retrying.
      Get.snackbar(
        'Order Failed',
        'Could not place your order: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      // FIX: always reset loading state regardless of success or failure.
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

// ─────────────────────────────────────────────────────────────────────────────
// _CheckoutBody
// ─────────────────────────────────────────────────────────────────────────────

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
    if (step == 2) return const _SuccessState();

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
                    flex: 3,
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
                  Expanded(
                    flex: 2,
                    child: _OrderSummaryCard(cart: cart),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  _OrderSummaryCard(cart: cart),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _OrderSummaryCard
// ─────────────────────────────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.cart});
  final CartController cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kNavy,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (ctx, idx) {
                  final item = cart.items[idx];
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.productName} (${item.sizeLabel} · ${item.colorName})',
                          style: const TextStyle(fontSize: 13, color: kNavy),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.lineTotal.toJOD(),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ],
                  );
                },
              )),
          const Divider(height: 24),
          Obx(() => _summaryRow('Subtotal', cart.subtotal.toJOD())),
          if (cart.appliedOffer.value != null)
            Obx(() => _summaryRow(
                  'Discount',
                  '- ${cart.discountTotal.toJOD()}',
                  color: Colors.green,
                )),
          const Divider(height: 16),
          Obx(() => _summaryRow(
                'Total',
                cart.grandTotal.toJOD(),
                isBold: true,
              )),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {Color? color, bool isBold = false}) {
    final style = TextStyle(
      fontSize: 14,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      color: color ?? kNavy,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CheckoutSteps  (step indicator + step content)
// ─────────────────────────────────────────────────────────────────────────────

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

// ── Step indicator ────────────────────────────────────────────────────────────

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
  final int index;
  final int current;
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
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : kSlate,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active || done ? FontWeight.w700 : FontWeight.w500,
            color: active || done ? kNavy : kSlate,
          ),
        ),
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
        const Text(
          'Delivery Address',
          style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: kNavy),
        ),
        const SizedBox(height: 20),
        if (addresses.isNotEmpty)
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
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address.label,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kNavy)),
                    const SizedBox(height: 4),
                    Text(
                      '${address.fullAddress}, ${address.city}',
                      style: const TextStyle(fontSize: 13, color: kSlate),
                    ),
                  ],
                ),
              ),
              if (address.isDefault)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kGold),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderColor),
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Address',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: kNavy),
              ),
              const SizedBox(height: 16),
              _CheckoutField(
                controller: addressLine1Ctrl,
                label: 'Address Line 1',
                hint: 'Street, building, apartment',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _CheckoutField(
                controller: addressLine2Ctrl,
                label: 'Address Line 2 (Optional)',
                hint: 'Floor, landmark',
              ),
              const SizedBox(height: 12),
              _CheckoutField(
                controller: cityCtrl,
                label: 'City',
                hint: 'Amman, Zarqa…',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onShowAddressForm(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kSlate,
                        side: const BorderSide(color: kBorderColor),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAddAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kNavy,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save Address'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _CheckoutField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;

  const _CheckoutField({
    required this.controller,
    required this.label,
    required this.hint,
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
        const Text(
          'Review Your Order',
          style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: kNavy),
        ),
        const SizedBox(height: 20),

        // Delivery address
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
                      Text(
                        '${addr.fullAddress}, ${addr.city}',
                        style: const TextStyle(fontSize: 12, color: kSlate),
                      ),
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

        // Cart items
        Obx(() => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _ReviewItemRow(item: cart.items[index]),
            )),

        const SizedBox(height: 32),

        // Place order button
        PrimaryButton(
          label: 'Place Order',
          loading: isPlacingOrder,
          onPressed: isPlacingOrder ? null : onPlaceOrder,
        ),
      ],
    );
  }
}

class _ReviewItemRow extends StatelessWidget {
  final CartItemModel item;
  const _ReviewItemRow({required this.item});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              '${item.productName} — ${item.sizeLabel} · ${item.colorName}',
              style: const TextStyle(fontSize: 13, color: kNavy),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '× ${item.quantity}',
            style: const TextStyle(fontSize: 13, color: kSlate),
          ),
          const SizedBox(width: 12),
          Text(
            item.lineTotal.toJOD(),
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: kNavy),
          ),
        ],
      );
}

// ── Step 2: Success ───────────────────────────────────────────────────────────

class _SuccessState extends StatelessWidget {
  const _SuccessState();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    size: 48, color: Color(0xFF16A34A)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Order Placed!',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: kNavy,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your order has been received and is being processed.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: kSlate),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'View My Orders',
                onPressed: () => Get.toNamed(AppRoutes.orders),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.home),
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        ),
      );
}
