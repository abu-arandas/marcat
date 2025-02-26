import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/cart.dart';
import '../models/product.dart';

class CartController extends GetxController {
  static CartController instance = Get.find();

  List<CartItem> cartItems = <CartItem>[].obs;

  void addToCart(Product product, String color, String size, int quantity) {
    var existingItem = cartItems.firstWhereOrNull(
      (item) =>
          item.productId == product.id &&
          item.color == color &&
          item.size == size,
    );

    if (existingItem != null) {
      existingItem.quantity += quantity;
    } else {
      cartItems.add(CartItem(
        id: UniqueKey().toString(),
        productId: product.id,
        color: color,
        size: size,
        quantity: quantity,
        price: product.basePrice,
      ));
    }
  }

  void removeFromCart(CartItem item) {
    cartItems.remove(item);
  }

  double get totalPrice =>
      cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
}
