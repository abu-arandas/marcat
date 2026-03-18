// test/core/router/auth_guard_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:marcat/core/router/route_guards.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/models/user_model.dart';
import 'package:marcat/models/enums.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fake AuthController
// ─────────────────────────────────────────────────────────────────────────────

class _FakeAuthController extends GetxController implements AuthController {
  final _state = const AuthState().obs;

  @override
  Rx<AuthState> get state => _state;

  void setFakeState(AuthState newState) {
    _state.value = newState;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late _FakeAuthController authCtrl;
  late AuthGuard guard;

  final dummyUser = UserModel(
    id: 'u1',
    firstName: 'Test',
    lastName: 'User',
    role: UserRole.customer,
    status: 'active',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    Get.reset();
    authCtrl = _FakeAuthController();
    Get.put<AuthController>(authCtrl);
    guard = AuthGuard();
  });

  group('AuthGuard.redirect()', () {
    test('returns null if AuthController is not registered', () {
      Get.delete<AuthController>();
      final result = guard.redirect('/some-route');
      expect(result, isNull);
    });

    test('redirects to home if loading and not authenticated', () {
      authCtrl.setFakeState(const AuthState(isLoading: true));
      // AppRoutes.home is '/'
      final result = guard.redirect(AppRoutes.profile);
      expect(result?.name, AppRoutes.home);
    });

    test('allows auth routes if not authenticated', () {
      authCtrl.setFakeState(const AuthState(isLoading: false));
      final result = guard.redirect(AppRoutes.login);
      expect(result, isNull);
    });

    test('redirects admin from auth routes to adminDashboard', () {
      authCtrl.setFakeState(AuthState(
        isLoading: false,
        user: dummyUser,
        roles: const ['admin'],
      ));
      final result = guard.redirect(AppRoutes.login);
      expect(result?.name, AppRoutes.adminDashboard);
    });

    test('redirects salesperson from auth routes to posAuth', () {
      authCtrl.setFakeState(AuthState(
        isLoading: false,
        user: dummyUser,
        roles: const ['salesperson'],
      ));
      final result = guard.redirect(AppRoutes.register);
      expect(result?.name, AppRoutes.posAuth);
    });

    test('redirects customer from auth routes to home', () {
      authCtrl.setFakeState(AuthState(
        isLoading: false,
        user: dummyUser,
        roles: const ['customer'], // highestRole will be customer
      ));
      final result = guard.redirect(AppRoutes.login);
      expect(result?.name, AppRoutes.home);
    });

    test('redirects unauthenticated users to login for protected customer routes', () {
      authCtrl.setFakeState(const AuthState(isLoading: false));
      expect(guard.redirect(AppRoutes.cart)?.name, AppRoutes.login);
      expect(guard.redirect(AppRoutes.checkout)?.name, AppRoutes.login);
      expect(guard.redirect(AppRoutes.profile)?.name, AppRoutes.login);
    });

    test('allows authenticated customers to access protected customer routes', () {
      authCtrl.setFakeState(AuthState(
        isLoading: false,
        user: dummyUser,
        roles: const ['customer'],
      ));
      expect(guard.redirect(AppRoutes.checkout), isNull);
      expect(guard.redirect(AppRoutes.profile), isNull);
      expect(guard.redirect(AppRoutes.cart), isNull);
      expect(guard.redirect(AppRoutes.wishlist), isNull);
    });

    test('blocks customers from POS routes', () {
      authCtrl.setFakeState(AuthState(
        isLoading: false,
        user: dummyUser,
        roles: const ['customer'],
      ));
      expect(guard.redirect('/pos/dashboard')?.name, AppRoutes.home);
    });

    test('allows salesperson to access POS routes', () {
      authCtrl.setFakeState(AuthState(
        isLoading: false,
        user: dummyUser,
        roles: const ['salesperson'],
      ));
      expect(guard.redirect('/pos/dashboard'), isNull);
    });

    test('blocks customers from admin routes', () {
      authCtrl.setFakeState(AuthState(
        isLoading: false,
        user: dummyUser,
        roles: const ['customer'],
      ));
      expect(guard.redirect('/admin/dashboard')?.name, AppRoutes.home);
    });

    test('allows admin to access admin routes', () {
      authCtrl.setFakeState(AuthState(
        isLoading: false,
        user: dummyUser,
        roles: const ['admin'],
      ));
      expect(guard.redirect('/admin/dashboard'), isNull);
    });
  });
}
