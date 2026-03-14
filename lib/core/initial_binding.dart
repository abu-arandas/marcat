// lib/core/initial_binding.dart
//
// Registers every app-wide controller exactly once at startup.
//
// FIX: LocaleController is now only registered HERE with permanent:true.
// The duplicate Get.put(LocaleController()) call in main.dart has been removed.
// Duplicate registration caused GetX to silently ignore the permanent flag
// on the second call, which meant the controller could be garbage-collected.
//
// ShopController is NOT registered here — it is scoped per-page in ShopPage
// using Get.put(..., tag: tag) so each category gets its own instance.

import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/account_controller.dart';
import '../controllers/admin_controller.dart';
import '../controllers/delivery_controller.dart';
import '../controllers/search_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ── Auth ─────────────────────────────────────────────────────────────────
    // Permanent; subscribes to Supabase onAuthStateChange at init.
    // AuthGuard reads Get.find<AuthController>().state on every route push.
    Get.put(AuthController(), permanent: true);

    // ── Product ──────────────────────────────────────────────────────────────
    // Permanent; owns products, categories, brands, wishlist, and offers.
    // Home content and catalogue meta are pre-fetched in onInit.
    Get.put(ProductController(), permanent: true);

    // ── Cart ─────────────────────────────────────────────────────────────────
    // Permanent; persisted to SharedPreferences across sessions.
    // Also owns order creation, order history, and return requests.
    Get.put(CartController(), permanent: true);

    // ── Account ──────────────────────────────────────────────────────────────
    // Lazy + fenix; owns profile, customer data, addresses, loyalty.
    // Instantiated on demand when the user opens their account section.
    Get.lazyPut(() => AccountController(), fenix: true);

    // ── Admin ────────────────────────────────────────────────────────────────
    // Lazy + fenix; owns staff, commissions, stores, and inventory.
    // Only instantiated for admin / store_manager roles.
    Get.lazyPut(() => AdminController(), fenix: true);

    // ── Delivery ─────────────────────────────────────────────────────────────
    // Lazy + fenix; owns deliveries and delivery status history.
    // Only instantiated for driver / dispatch screens.
    Get.lazyPut(() => DeliveryController(), fenix: true);

    // ── Search ───────────────────────────────────────────────────────────────
    // Permanent; the search sheet is accessible from every screen.
    // Delegates all data reads to ProductController — no direct Supabase calls.
    Get.put(SearchController(), permanent: true);

    // Note: ShopController is intentionally NOT registered here.
    // It is created per-page in ShopPage via Get.put(..., tag: categoryId)
    // so that different category views each maintain independent state.
  }
}
