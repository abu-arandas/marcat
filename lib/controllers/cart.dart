import '/config/exports.dart';

class CartController extends GetxController {
  static CartController instance = Get.find();
  List<CartItemModel> cartItems = <CartItemModel>[];

  @override
  void onInit() {
    super.onInit();

    loadCartFromLocal();
  }

  void addToCart({
    required ProductModel product,
    required VariantModel variant,
  }) {
    final existingItem = cartItems.firstWhereOrNull((item) =>
        item.productId == product.id && item.variant.sku == variant.sku);

    if (existingItem != null) {
      existingItem.quantity += 1;
    } else {
      final uuid = const Uuid();

      cartItems.add(
        CartItemModel(
          id: uuid.v4(),
          productId: product.id,
          variant: variant,
          quantity: 1,
        ),
      );
    }

    saveCartToLocal();
  }

  void removeFromCart({required String productId}) {
    final existingItem =
        cartItems.firstWhereOrNull((item) => item.productId == productId);

    if (existingItem != null) {
      if (existingItem.quantity > 1) {
        existingItem.quantity -= 1;
      } else {
        cartItems.remove(existingItem);
      }
    }

    saveCartToLocal();
  }

  void clearCart() {
    cartItems.clear();
    saveCartToLocal();
  }

  double get totalPrice => cartItems.fold(
      0, (sum, item) => sum + (item.quantity * item.variant.price));

  Future<void> saveCartToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = cartItems.map((item) => item.toJson()).toList();
    await prefs.setString('cart', json.encode(cartJson));

    update();
  }

  Future<void> loadCartFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart');

    if (cartString != null) {
      final cartJson = json.decode(cartString) as List<dynamic>;
      final loadedCartItems =
          cartJson.map((itemJson) => CartItemModel.fromJson(itemJson)).toList();
      cartItems.assignAll(loadedCartItems);
    }

    update();
  }
}
