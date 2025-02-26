import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/order.dart';
import 'cart.dart';
import 'auth.dart';

class OrderController extends GetxController {
  static OrderController instance = Get.find();

  var orders = <Order>[].obs;
  final CartController cartController = Get.find();
  final AuthController authController = Get.find();

  void placeOrder() async {
    if (authController.user != null && cartController.cartItems.isNotEmpty) {
      var newOrder = Order(
        id: UniqueKey().toString(),
        userId: authController.user!.id,
        items: cartController.cartItems
            .map(
              (element) => OrderItem(
                  productId: element.productId,
                  color: element.color,
                  size: element.size,
                  quantity: element.quantity,
                  price: element.price),
            )
            .toList(),
        totalAmount: cartController.totalPrice,
        createdAt: DateTime.now(),
        payment: Payment.cash,
        status: Status.bind,
      );

      var success = true;
      if (success) {
        orders.add(newOrder);
        cartController.cartItems.clear();
      } /*else {
        // Handle order placement error
      }*/
    } else {
      // Handle case when user is not logged in or cart is empty
    }
  }

  void fetchOrders() async {}
}
