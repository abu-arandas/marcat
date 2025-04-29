import '/config/exports.dart';

class ProductController extends GetxController {
  static ProductController instance = Get.find();

  RxList<ProductModel> products = <ProductModel>[].obs;
  List<ProductModel> get allProducts => products;
  List<ProductModel> get featuredProducts =>
      products.where((product) => product.isFeatured).toList();
  ProductModel product(String id) =>
      products.singleWhere((product) => product.id == id);

  @override
  void onInit() {
    super.onInit();

    products.bindStream(fetchProducts());
  }

  Stream<List<ProductModel>> fetchProducts() {
    try {
      final snapshot = FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .snapshots();

      return snapshot.map((querySnapshot) =>
          querySnapshot.docs.map((doc) => ProductModel.fromJson(doc)).toList());
    } catch (e) {
      Get.snackbar('Error', 'Error loading products: ${e.toString()}');
      return Stream.value([]);
    } finally {
      update();
    }
  }

  Future<void> addProduct({required ProductModel product}) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .add(product.toJson());
    } on FirebaseException catch (e) {
      Get.snackbar('Error', 'Error adding product: ${e.message}');
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update(product.toJson());
    } on FirebaseException catch (e) {
      Get.snackbar('Error', 'Error adding product: ${e.message}');
    }
  }

  Future<void> updateProductIsFeatured({
    required String productId,
    required bool isFeatured,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({'isFeatured': isFeatured});
    } on FirebaseException catch (e) {
      Get.snackbar('Error', 'Error adding product: ${e.message}');
    }
  }

  Future<void> deleteProduct(ProductModel product) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .delete();
    } on FirebaseException catch (e) {
      Get.snackbar('Error', 'Error adding product: ${e.message}');
    }
  }
}
