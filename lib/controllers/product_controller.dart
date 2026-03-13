// lib/controllers/product_controller.dart
//
// Merges: product_repository  (products, colors, sizes, images, availability)
//         category_repository (categories, brands)
//         wishlist_repository (wishlist CRUD)
//         offer_repository    (active offers / hero banners)
//
// Delete those four repository files — everything lives here now.

import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:marcat/core/constants/supabase_constants.dart';
import 'package:marcat/core/error_handler.dart';
import 'package:marcat/models/brand_model.dart';
import 'package:marcat/models/category_model.dart';
import 'package:marcat/models/inventory_model.dart';
import 'package:marcat/models/offer_model.dart';
import 'package:marcat/models/product_color_model.dart';
import 'package:marcat/models/product_image_model.dart';
import 'package:marcat/models/product_model.dart';
import 'package:marcat/models/product_size_model.dart';
import 'package:marcat/models/wishlist_model.dart';

// ─── field projection constants ──────────────────────────────────────────────

const _productFields =
    'id, name, description, sku, base_price, brand_id, category_id, '
    'primary_image_url, status, created_at, updated_at';

// ─────────────────────────────────────────────────────────────────────────────
// ProductController
// ─────────────────────────────────────────────────────────────────────────────

class ProductController extends GetxController {
  sb.SupabaseClient get _client => sb.Supabase.instance.client;

  // ── Product list ────────────────────────────────────────────────────────────
  final products = <ProductModel>[].obs;
  final totalProducts = 0.obs;
  final isLoadingProducts = false.obs;

  // ── Product detail ──────────────────────────────────────────────────────────
  final selectedProduct = Rxn<ProductModel>();
  final selectedColors = <ProductColorModel>[].obs;
  final selectedSizes = <ProductSizeModel>[].obs;
  final selectedImages = <ProductImageModel>[].obs;
  final selectedAvailability = <InventoryModel>[].obs;
  final isLoadingDetail = false.obs;

  // ── Home-screen featured content ────────────────────────────────────────────
  final topProducts = <ProductModel>[].obs;
  final newArrivals = <ProductModel>[].obs;
  final activeOffers = <OfferModel>[].obs;
  final isLoadingHome = false.obs;

  // ── Catalogue filters ───────────────────────────────────────────────────────
  final categories = <CategoryModel>[].obs;
  final brands = <BrandModel>[].obs;
  final isLoadingMeta = false.obs;

  // ── Wishlist ────────────────────────────────────────────────────────────────
  final wishlistItems = <WishlistModel>[].obs;
  final isLoadingWishlist = false.obs;

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadHomeContent();
    loadCatalogMeta();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HOME CONTENT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Loads top products, new arrivals, and hero-banner offers concurrently.
  Future<void> loadHomeContent() async {
    isLoadingHome.value = true;
    try {
      final results = await Future.wait([
        fetchTopProducts(limit: 6),
        fetchNewArrivals(limit: 10),
        fetchActiveOffers(limit: 5),
      ]);
      topProducts.assignAll(results[0] as List<ProductModel>);
      newArrivals.assignAll(results[1] as List<ProductModel>);
      activeOffers.assignAll(results[2] as List<OfferModel>);
    } catch (_) {
      // Partial failures are acceptable — screen renders what loaded.
    } finally {
      isLoadingHome.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CATALOGUE META  (categories + brands)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> loadCatalogMeta() async {
    isLoadingMeta.value = true;
    try {
      final results = await Future.wait([
        loadCategories(),
        loadBrands(),
      ]);
      categories.assignAll(results[0] as List<CategoryModel>);
      brands.assignAll(results[1] as List<BrandModel>);
    } catch (_) {
    } finally {
      isLoadingMeta.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRODUCTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Paginated product list with optional filters.
  ///
  /// When [updateState] is true (default) the [products] / [totalProducts]
  /// observables are updated — set to false for preview-only calls (search
  /// sheet) that must not clobber the shop listing.
  Future<(List<ProductModel>, int)> fetchProducts({
    int page = 0,
    int pageSize = SupabaseConstants.defaultPageSize,
    String? query,
    int? categoryId,
    int? brandId,
    double? minPrice,
    double? maxPrice,
    int? storeId,
    String sortBy = 'created_at',
    bool ascending = false,
    bool updateState = true,
  }) async {
    if (updateState) isLoadingProducts.value = true;
    try {
      var q = _client
          .from(SupabaseConstants.products)
          .select(_productFields)
          .neq('status', 'archived');

      if (query != null && query.isNotEmpty) q = q.ilike('name', '%$query%');
      if (categoryId != null) q = q.eq('category_id', categoryId);
      if (brandId != null) q = q.eq('brand_id', brandId);
      if (minPrice != null) q = q.gte('base_price', minPrice);
      if (maxPrice != null) q = q.lte('base_price', maxPrice);

      if (storeId != null) {
        final ids = await _productIdsByStore(storeId);
        if (ids.isEmpty) {
          if (updateState) {
            products.clear();
            totalProducts.value = 0;
          }
          return (<ProductModel>[], 0);
        }
        q = q.inFilter('id', ids);
      }

      final from = page * pageSize;
      final res = await q
          .order(sortBy, ascending: ascending)
          .range(from, from + pageSize - 1)
          .count(sb.CountOption.exact);

      final items = (res.data as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (updateState) {
        products.assignAll(items);
        totalProducts.value = res.count;
      }
      return (items, res.count);
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      if (updateState) isLoadingProducts.value = false;
    }
  }

  Future<ProductModel> fetchProductById(int productId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.products)
          .select(_productFields)
          .eq('id', productId)
          .single();
      return ProductModel.fromJson(data);
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<List<ProductModel>> fetchProductsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    try {
      final data = await _client
          .from(SupabaseConstants.products)
          .select(_productFields)
          .inFilter('id', ids);
      return (data as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<List<ProductModel>> fetchTopProducts({int limit = 6}) async {
    try {
      final data = await _client
          .from(SupabaseConstants.products)
          .select(_productFields)
          .eq('status', 'active')
          .limit(limit);
      return (data as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<List<ProductModel>> fetchNewArrivals({int limit = 10}) async {
    try {
      final data = await _client
          .from(SupabaseConstants.products)
          .select(_productFields)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(limit);
      return (data as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  /// Loads a product's full detail (product + colors + sizes + images +
  /// availability) in one parallel batch and populates the detail observables.
  Future<void> loadProductDetail(int productId) async {
    isLoadingDetail.value = true;
    try {
      final results = await Future.wait([
        fetchProductById(productId),
        fetchColors(productId),
        fetchSizes(productId),
        fetchImages(productId),
        fetchProductAvailability(productId),
      ]);
      selectedProduct.value = results[0] as ProductModel;
      selectedColors.assignAll(results[1] as List<ProductColorModel>);
      selectedSizes.assignAll(results[2] as List<ProductSizeModel>);
      selectedImages.assignAll(results[3] as List<ProductImageModel>);
      selectedAvailability.assignAll(results[4] as List<InventoryModel>);
    } catch (e) {
      rethrow;
    } finally {
      isLoadingDetail.value = false;
    }
  }

  void clearProductDetail() {
    selectedProduct.value = null;
    selectedColors.clear();
    selectedSizes.clear();
    selectedImages.clear();
    selectedAvailability.clear();
  }

  // ─── Product sub-resources ───────────────────────────────────────────────────

  Future<List<ProductColorModel>> fetchColors(int productId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.productColors)
          .select('id, product_id, name, hex_code')
          .eq('product_id', productId);
      return (data as List<dynamic>)
          .map((e) => ProductColorModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<List<ProductSizeModel>> fetchSizes(int productId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.productSizes)
          .select('id, product_id, label')
          .eq('product_id', productId);
      return (data as List<dynamic>)
          .map((e) => ProductSizeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<List<ProductImageModel>> fetchImages(int productId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.productImages)
          .select('id, product_id, image_url, display_order')
          .eq('product_id', productId)
          .order('display_order');
      return (data as List<dynamic>)
          .map((e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  /// Calls get_product_availability RPC — returns inventory per store/color/size.
  Future<List<InventoryModel>> fetchProductAvailability(int productId) async {
    try {
      final data = await _client.rpc(
        SupabaseConstants.rpcGetProductAvailability,
        params: {'p_product_id': productId},
      );
      return (data as List<dynamic>)
          .map((e) => InventoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  // ─── Admin: product mutations ────────────────────────────────────────────────

  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    try {
      final result = await _client
          .from(SupabaseConstants.products)
          .insert(data)
          .select()
          .single();
      return ProductModel.fromJson(result);
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      await _client.from(SupabaseConstants.products).update(data).eq('id', id);
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  /// Uploads a product image to Storage and inserts a product_images row.
  Future<String> uploadProductImage({
    required int productId,
    required int colorId,
    required List<int> imageBytes,
    required String uuid,
    required bool isPrimary,
    required int sortOrder,
  }) async {
    try {
      final fileName = '$productId/$colorId/$uuid.jpg';
      await _client.storage
          .from(SupabaseConstants.productImagesBucket)
          .uploadBinary(
            fileName,
            Uint8List.fromList(imageBytes),
            fileOptions: const sb.FileOptions(contentType: 'image/jpeg'),
          );
      final url = _client.storage
          .from(SupabaseConstants.productImagesBucket)
          .getPublicUrl(fileName);

      await _client.from(SupabaseConstants.productImages).insert({
        'product_id': productId,
        'image_url': url,
        'display_order': sortOrder,
      });
      return url;
    } catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORIES & BRANDS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<CategoryModel>> loadCategories({int? parentId}) async {
    try {
      var q = _client
          .from(SupabaseConstants.categories)
          .select('id, name, parent_id, image_url, is_active');
      if (parentId != null) q = q.eq('parent_id', parentId);
      final data = await q.order('id');
      final items = (data as List<dynamic>)
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (parentId == null) categories.assignAll(items);
      return items;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<List<BrandModel>> loadBrands() async {
    try {
      final data = await _client
          .from(SupabaseConstants.brands)
          .select('id, name, logo_url')
          .order('name');
      final items = (data as List<dynamic>)
          .map((e) => BrandModel.fromJson(e as Map<String, dynamic>))
          .toList();
      brands.assignAll(items);
      return items;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    try {
      final result = await _client
          .from(SupabaseConstants.categories)
          .insert(data)
          .select()
          .single();
      final cat = CategoryModel.fromJson(result);
      categories.add(cat);
      return cat;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<BrandModel> createBrand(Map<String, dynamic> data) async {
    try {
      final result = await _client
          .from(SupabaseConstants.brands)
          .insert(data)
          .select()
          .single();
      final brand = BrandModel.fromJson(result);
      brands.add(brand);
      return brand;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OFFERS  (hero banner slides on home screen)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<OfferModel>> fetchActiveOffers({int limit = 5}) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final data = await _client
          .from(SupabaseConstants.offers)
          .select()
          .eq('is_active', true)
          .or('expires_at.is.null,expires_at.gt.$now')
          .order('created_at', ascending: false)
          .limit(limit);
      final items = (data as List<dynamic>)
          .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
          .toList();
      activeOffers.assignAll(items);
      return items;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WISHLIST
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> loadWishlist(String userId) async {
    isLoadingWishlist.value = true;
    try {
      final data = await _client
          .from(SupabaseConstants.wishlists)
          .select('id, user_id, product_id, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      wishlistItems.assignAll(
        (data as List<dynamic>)
            .map((e) => WishlistModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      isLoadingWishlist.value = false;
    }
  }

  /// Adds or removes a product from the wishlist (toggle).
  /// Returns true if the product is now in the wishlist.
  Future<bool> toggleWishlist(String userId, int productId) async {
    final alreadyIn = isProductInWishlist(productId);
    if (alreadyIn) {
      await removeFromWishlist(userId, productId);
      return false;
    } else {
      await addToWishlist(userId, productId);
      return true;
    }
  }

  Future<void> addToWishlist(String userId, int productId) async {
    try {
      await _client.from(SupabaseConstants.wishlists).upsert({
        'user_id': userId,
        'product_id': productId,
      });
      // Optimistic update
      if (!isProductInWishlist(productId)) {
        wishlistItems.add(WishlistModel(
          id: 0, // placeholder until reload
          userId: userId,
          productId: productId,
          createdAt: DateTime.now(),
        ));
      }
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<void> removeFromWishlist(String userId, int productId) async {
    try {
      await _client
          .from(SupabaseConstants.wishlists)
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
      wishlistItems.removeWhere((w) => w.productId == productId);
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  /// Checks the local in-memory wishlist — no network call.
  bool isProductInWishlist(int productId) =>
      wishlistItems.any((w) => w.productId == productId);

  /// Network check — use when wishlist may not be loaded yet.
  Future<bool> checkIsInWishlist(String userId, int productId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.wishlists)
          .select('id')
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();
      return data != null;
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<int>> _productIdsByStore(int storeId) async {
    final r = await _client
        .from(SupabaseConstants.vStoreInventory)
        .select('product_id')
        .eq('store_id', storeId);
    return (r as List<dynamic>).map((e) => e['product_id'] as int).toList();
  }
}
