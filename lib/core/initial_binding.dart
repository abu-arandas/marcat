// lib/core/initial_binding.dart

import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/account_controller.dart';
import '../controllers/admin_controller.dart';
import '../controllers/delivery_controller.dart';
import '../controllers/search_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// InitialBinding
// ─────────────────────────────────────────────────────────────────────────────

/// Registers all global GetX controllers at app start.
///
/// - `permanent: true` — lives for the full app lifetime.
/// - `fenix: true`     — auto-recreated after disposal (lazy).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ── Auth ─────────────────────────────────────────────────────────────────
    Get.put(AuthController(), permanent: true);

    // ── Product ──────────────────────────────────────────────────────────────
    Get.put(ProductController(), permanent: true);

    // ── Cart ─────────────────────────────────────────────────────────────────
    Get.put(CartController(), permanent: true);

    // ── Search ───────────────────────────────────────────────────────────────
    Get.put(MarcatSearchController(), permanent: true);

    // ── Account ──────────────────────────────────────────────────────────────
    Get.lazyPut(() => AccountController(), fenix: true);

    // ── Admin ────────────────────────────────────────────────────────────────
    Get.lazyPut(() => AdminController(), fenix: true);

    // ── Delivery ─────────────────────────────────────────────────────────────
    Get.lazyPut(() => DeliveryController(), fenix: true);
  }
}
