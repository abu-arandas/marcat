import 'package:get/get.dart';

import '../models/product.dart';

class ProductController extends GetxController {
  static ProductController instance = Get.find();

  var products = <Product>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  void fetchProducts() async {
    try {
      isLoading(true);
    } finally {
      isLoading(false);
    }
  }

  Product? getProductById(String id) {
    return products.firstWhereOrNull((product) => product.id == id);
  }
}
