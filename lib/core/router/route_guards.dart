// lib/core/router/route_guards.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marcat/controllers/auth_controller.dart';
import 'app_router.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) return null;
    final authState = Get.find<AuthController>().state.value;

    // While auth is still resolving, hold on the splash screen.
    if (authState.isLoading && !authState.isAuthenticated) {
      if (route != AppRoutes.home) {
        return const RouteSettings(name: AppRoutes.home);
      }
      return null;
    }

    final isAuthRoute = route?.startsWith('/auth') ?? false;
    final isPosRoute = route?.startsWith('/pos') ?? false;
    final isAdminRoute = route?.startsWith('/admin') ?? false;

    // Customer routes that require authentication.
    final isProtectedCustomerRoute = route == AppRoutes.cart ||
        route == AppRoutes.checkout ||
        route == AppRoutes.profile ||
        route == AppRoutes.orders ||
        route == AppRoutes.wishlist ||
        (route?.startsWith('/app/profile') ?? false);

    // ── Auth / Splash / Onboarding ───────────────────────────────────────────
    // Redirect AUTHENTICATED users away from these screens.
    // Unauthenticated users must pass through freely.
    if (isAuthRoute || route == '/onboarding') {
      if (!authState.isAuthenticated) return null;

      switch (authState.highestRole) {
        case 'admin':
        case 'store_manager':
          return const RouteSettings(name: AppRoutes.adminDashboard);
        case 'salesperson':
          return const RouteSettings(name: AppRoutes.posAuth);
        default:
          return const RouteSettings(name: AppRoutes.home);
      }
    }

    // ── Unauthenticated access to protected routes → login ───────────────────
    if (!authState.isAuthenticated &&
        (isAdminRoute || isPosRoute || isProtectedCustomerRoute)) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // ── POS routes: salesperson / store_manager / admin only ─────────────────
    if (isPosRoute &&
        !authState.isAdmin &&
        !authState.isStoreManager &&
        !authState.isSalesperson) {
      return const RouteSettings(name: AppRoutes.home);
    }

    // ── Admin routes: admin / store_manager only ─────────────────────────────
    if (isAdminRoute && !authState.isAdmin && !authState.isStoreManager) {
      return const RouteSettings(name: AppRoutes.home);
    }

    return null;
  }
}
