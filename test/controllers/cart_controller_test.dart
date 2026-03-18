// test/controllers/cart_controller_test.dart
//
// Tests for CartController.addItem()
// Run with: flutter test test/controllers/cart_controller_test.dart
//
// CartController uses SharedPreferences and Supabase.  We bypass both by
// testing addItem() which is pure synchronous logic (no network calls).

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/models/cart_item_model.dart';

void main() {
  late CartController ctrl;

  setUp(() async {
    // Stub SharedPreferences so _loadCart / _saveCart don't throw.
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    ctrl = CartController();
    Get.put(ctrl);
    // Wait for _loadCart to complete so isCartLoading becomes false.
    await Future.delayed(Duration.zero);
  });

  tearDown(() {
    Get.reset();
  });

  group('CartController.addItem()', () {
    test('adds a new item to an empty cart', () {
      final item = _makeItem(productSizeId: 1, colorId: 10, qty: 2);

      ctrl.addItem(item);

      expect(ctrl.items, hasLength(1));
      expect(ctrl.items.first.quantity, 2);
    });

    test('increments quantity when the same productSizeId+colorId is added', () {
      final first = _makeItem(productSizeId: 1, colorId: 10, qty: 1);
      final second = _makeItem(productSizeId: 1, colorId: 10, qty: 3);

      ctrl.addItem(first);
      ctrl.addItem(second); // same SKU → should merge

      expect(ctrl.items, hasLength(1),
          reason: 'duplicate SKU should not create a second entry');
      expect(ctrl.items.first.quantity, 4,
          reason: 'quantities should be summed (1+3)');
    });

    test('adds a distinct entry when colorId differs', () {
      final red = _makeItem(productSizeId: 1, colorId: 10, qty: 1);
      final blue = _makeItem(productSizeId: 1, colorId: 20, qty: 1);

      ctrl.addItem(red);
      ctrl.addItem(blue);

      expect(ctrl.items, hasLength(2),
          reason: 'different colorId = different line item');
    });

    test('adds a distinct entry when productSizeId differs', () {
      final sizeM = _makeItem(productSizeId: 1, colorId: 10, qty: 1);
      final sizeL = _makeItem(productSizeId: 2, colorId: 10, qty: 1);

      ctrl.addItem(sizeM);
      ctrl.addItem(sizeL);

      expect(ctrl.items, hasLength(2));
    });
  });

  group('CartController.removeItem()', () {
    test('removes the matching item from the cart', () {
      ctrl.addItem(_makeItem(productSizeId: 1, colorId: 10, qty: 1));
      ctrl.addItem(_makeItem(productSizeId: 2, colorId: 10, qty: 1));

      ctrl.removeItem(1, 10);

      expect(ctrl.items, hasLength(1));
      expect(ctrl.items.first.productSizeId, 2);
    });
  });

  group('CartController.clearCart()', () {
    test('empties all items and resets offer', () {
      ctrl.addItem(_makeItem(productSizeId: 1, colorId: 10, qty: 2));

      ctrl.clearCart();

      expect(ctrl.items, isEmpty);
      expect(ctrl.appliedOffer.value, isNull);
    });
  });

  group('CartController totals', () {
    test('subtotal is sum of unitPrice × quantity', () {
      ctrl.addItem(_makeItem(productSizeId: 1, colorId: 10, qty: 2, price: 15.0));
      ctrl.addItem(_makeItem(productSizeId: 2, colorId: 10, qty: 1, price: 20.0));

      expect(ctrl.subtotal, closeTo(50.0, 0.001));
    });

    test('itemCount returns total quantity across all lines', () {
      ctrl.addItem(_makeItem(productSizeId: 1, colorId: 10, qty: 3));
      ctrl.addItem(_makeItem(productSizeId: 2, colorId: 10, qty: 2));

      expect(ctrl.itemCount, 5);
    });
  });
}

// ── Helpers ──────────────────────────────────────────────────────────────────

CartItemModel _makeItem({
  required int productSizeId,
  required int colorId,
  required int qty,
  double price = 10.0,
}) {
  return CartItemModel(
    productId: 100,
    productName: 'Test Product',
    productSizeId: productSizeId,
    sizeLabel: 'M',
    colorId: colorId,
    colorName: 'Test Color',
    unitPrice: price,
    quantity: qty,
  );
}
