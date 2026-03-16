// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'route_guards.dart';

// ── Auth screens ──────────────────────────────────────────────────────────────
import 'package:marcat/views/auth/login_screen.dart';
import 'package:marcat/views/auth/register_screen.dart';
import 'package:marcat/views/auth/forgot_password_screen.dart';

// ── Customer screens ──────────────────────────────────────────────────────────
import 'package:marcat/views/customer/home_page.dart';
import 'package:marcat/views/customer/product_detail_page.dart';
import 'package:marcat/views/customer/about_page.dart';
import 'package:marcat/views/customer/contact_page.dart';
import 'package:marcat/views/customer/cart_page.dart';
import 'package:marcat/views/customer/checkout_page.dart';
import 'package:marcat/views/customer/profile_page.dart';
import 'package:marcat/views/customer/orders_page.dart';
import 'package:marcat/views/customer/shop_page.dart';
import 'package:marcat/views/customer/wishlist_page.dart';
import 'package:marcat/views/customer/order_detail_page.dart';

// ── Admin screens ─────────────────────────────────────────────────────────────
import 'package:marcat/views/admin/app_scaffold.dart';
import 'package:marcat/views/admin/products/product_form_screen.dart';
import 'package:marcat/views/admin/orders/order_detail_screen.dart';
import 'package:marcat/views/admin/staff/staff_form_screen.dart';

// ── POS screens ───────────────────────────────────────────────────────────────
import 'package:marcat/views/pos/auth/pos_auth_screen.dart';
import 'package:marcat/views/pos/terminal/pos_terminal_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route name constants
// ─────────────────────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';

  // Customer app
  static const String home = '/app/home';
  static const String about = '/app/about';
  static const String contact = '/app/contact';
  static const String shop = '/app/shop';
  static const String shopWomen = '/app/shop/women';
  static const String shopMen = '/app/shop/men';
  static const String shopKids = '/app/shop/kids';
  static const String shopSale = '/app/shop/sale';
  static const String shopNew = '/app/shop/new';
  static const String wishlist = '/app/wishlist';
  static const String profile = '/app/profile';
  static const String product = '/app/product/:id';
  static const String category = '/app/category/:id';
  static const String cart = '/app/cart';
  static const String checkout = '/app/checkout';
  static const String orders = '/app/profile/orders';
  static const String orderDetail = '/app/profile/orders/:id';

  // Informational
  static const String sizeGuide = '/app/size-guide';
  static const String returns = '/app/returns';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProductsCreate = '/admin/products/create';
  static const String adminProductsEdit = '/admin/products/:id/edit';
  static const String adminOrders = '/admin/orders/:id';
  static const String adminStaff = '/admin/staff/add';

  // POS
  static const String posAuth = '/pos/auth';
  static const String posTerminal = '/pos/terminal';

  // ── Dynamic route helpers ──────────────────────────────────────────────────
  static String productOf(dynamic id) => '/app/product/$id';
  static String categoryOf(dynamic id) => '/app/category/$id';
  static String orderDetailOf(dynamic id) => '/app/profile/orders/$id';
  static String adminOrderOf(dynamic id) => '/admin/orders/$id';
  static String adminProductEditOf(dynamic id) => '/admin/products/$id/edit';
}

// ─────────────────────────────────────────────────────────────────────────────
// Route definitions
// ─────────────────────────────────────────────────────────────────────────────

class AppPages {
  AppPages._();

  static final pages = [
    // ── Auth ─────────────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),
    GetPage(
        name: AppRoutes.forgotPassword,
        page: () => const ForgotPasswordScreen()),

    // ── Customer app ─────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.home, page: () => const HomePage()),
    GetPage(name: AppRoutes.about, page: () => const AboutPage()),
    GetPage(name: AppRoutes.contact, page: () => const ContactPage()),
    GetPage(name: AppRoutes.shop, page: () => const ShopPage()),

    // Category sub-routes
    GetPage(name: AppRoutes.shopWomen, page: () => const ShopPage()),
    GetPage(name: AppRoutes.shopMen, page: () => const ShopPage()),
    GetPage(name: AppRoutes.shopKids, page: () => const ShopPage()),
    GetPage(name: AppRoutes.shopSale, page: () => const ShopPage()),
    GetPage(name: AppRoutes.shopNew, page: () => const ShopPage()),

    GetPage(
      name: AppRoutes.wishlist,
      page: () => const WishlistPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.product,
      page: () => const ProductDetailPage(),
    ),
    GetPage(
      name: AppRoutes.category,
      page: () {
        final categoryId = int.tryParse(Get.parameters['id'] ?? '');
        return ShopPage(initialCategoryId: categoryId);
      },
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrdersPage(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () {
        final orderId = int.tryParse(Get.parameters['id'] ?? '');
        if (orderId == null) {
          return const _InvalidRouteScreen(message: 'Invalid order ID.');
        }
        return CustomerOrderDetailPage(orderId: orderId);
      },
      middlewares: [AuthGuard()],
    ),

    GetPage(
      name: AppRoutes.sizeGuide,
      page: () => const _ComingSoonScreen(title: 'Size Guide'),
    ),
    GetPage(
      name: AppRoutes.returns,
      page: () => const _ComingSoonScreen(title: 'Returns & Exchanges'),
    ),

    // ── Admin app ─────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminAppScaffold(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.adminProductsCreate,
      page: () => const ProductFormScreen(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.adminProductsEdit,
      page: () {
        final productId = int.tryParse(Get.parameters['id'] ?? '');
        if (productId == null) {
          return const _InvalidRouteScreen(message: 'Invalid product ID.');
        }
        return ProductFormScreen(productId: productId);
      },
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.adminOrders,
      page: () {
        final orderId = int.tryParse(Get.parameters['id'] ?? '');
        if (orderId == null) {
          return const _InvalidRouteScreen(message: 'Invalid order ID.');
        }
        return AdminOrderDetailScreen(orderId: orderId);
      },
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.adminStaff,
      page: () => const StaffFormScreen(),
      middlewares: [AuthGuard()],
    ),

    // ── POS app ───────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.posAuth,
      page: () => const PosAuthScreen(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.posTerminal,
      page: () => const PosTerminalScreen(),
      middlewares: [AuthGuard()],
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// _InvalidRouteScreen
// Shown when a route parameter is missing or non-parseable.
// ─────────────────────────────────────────────────────────────────────────────

class _InvalidRouteScreen extends StatelessWidget {
  const _InvalidRouteScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.link_off, size: 48),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
}

class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_outlined, size: 48),
              const SizedBox(height: 16),
              Text(
                '$title coming soon.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Get.back(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
}
