import '/config/exports.dart';

class OrderController extends GetxController {
  static OrderController instance = Get.find();

  RxList<OrderModel> orders = <OrderModel>[].obs;
  List<OrderModel> storeOrder(String storeId) =>
      orders.where((order) => order.storeId == storeId).toList();
  List<OrderModel> userOrders(String userId) =>
      orders.where((order) => order.userId == userId).toList();
  OrderModel? orderById(String orderId) =>
      orders.firstWhere((order) => order.id == orderId);

  @override
  void onInit() {
    super.onInit();

    orders.bindStream(fetchOrders());
  }

  Stream<List<OrderModel>> fetchOrders() {
    try {
      final snapshot =
          FirebaseFirestore.instance.collection('orders').snapshots();

      return snapshot.map((querySnapshot) =>
          querySnapshot.docs.map((doc) => OrderModel.fromJson(doc)).toList());
    } catch (e) {
      Get.snackbar('Error', 'Error loading products: ${e.toString()}');
      return Stream.value([]);
    } finally {
      update();
    }
  }

  Future<void> createOrder({
    required UserModel user,
    required String storeId,
  }) async {
    try {
      double total = 0;

      for (CartItemModel item in CartController.instance.cartItems) {
        total += item.quantity * item.variant.price;
      }

      OrderModel order = OrderModel(
        id: Uuid().v1(),
        userId: user.id,
        date: DateTime.now(),
        total: total,
        status: OrderStatus.pending,
        items: CartController.instance.cartItems
            .map(
              (item) => OrderItemModel(
                id: Uuid().v1(),
                productId: item.productId,
                quantity: item.quantity,
                price: item.variant.price,
                variant: item.variant,
              ),
            )
            .toList(),
        storeId: storeId,
      );

      await FirebaseFirestore.instance.collection('orders').add(order.toJson());

      CartController.instance.clearCart();
    } catch (e) {
      Get.snackbar('Error!', 'Error creating the order: $e');
    }
  }

  Future<void> updateOrderStatus(
      {required String orderId, required OrderStatus newStatus}) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus.fromEnum()});
    } on FirebaseException catch (e) {
      Get.snackbar('Error', 'Error adding product: ${e.message}');
    }
  }
}
