// lib/core/bindings/initial_binding.dart
//
// Registers every app-wide controller exactly once at startup.
//
// The 15 old repository classes (AuthRepository, CartRepository, etc.) have
// been removed — each merged controller owns its Supabase calls directly.
// Delete the entire lib/controllers/repositories/ directory.

import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/locale_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/account_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/delivery_controller.dart';
import '../../controllers/search_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ── Locale ───────────────────────────────────────────────────────────────
    // Must be first — the app renders the correct language on the first frame.
    Get.put(LocaleController(), permanent: true);

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
  }
}
