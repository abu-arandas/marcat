// lib/controllers/auth_controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:marcat/core/constants/supabase_constants.dart';
import 'package:marcat/core/error_handler.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/models/customer_model.dart';
import 'package:marcat/models/enums.dart';
import 'package:marcat/models/user_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthState  (immutable value object — no GetX dependency)
// ─────────────────────────────────────────────────────────────────────────────

class AuthState {
  const AuthState({
    this.user,
    this.customer,
    this.roles = const [],
    this.isLoading = false,
    this.error,
  });

  final UserModel? user;
  final CustomerModel? customer;
  final List<String> roles;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null;

  bool hasRole(String r) => roles.contains(r);
  bool get isAdmin => hasRole('admin');
  bool get isStoreManager => hasRole('store_manager');
  bool get isSalesperson => hasRole('salesperson');
  bool get isDriver => hasRole('driver');
  bool get isCustomer => hasRole('customer');

  /// Highest-privilege role — used for post-login routing decisions.
  String get highestRole {
    if (isAdmin) return 'admin';
    if (isStoreManager) return 'store_manager';
    if (isSalesperson) return 'salesperson';
    if (isDriver) return 'driver';
    return 'customer';
  }

  AuthState copyWith({
    UserModel? user,
    CustomerModel? customer,
    List<String>? roles,
    bool? isLoading,
    String? error,
  }) =>
      AuthState(
        user: user ?? this.user,
        customer: customer ?? this.customer,
        roles: roles ?? this.roles,
        isLoading: isLoading ?? this.isLoading,
        error: error, // always replace — null clears the error
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthController
// ─────────────────────────────────────────────────────────────────────────────

class AuthController extends GetxController {
  // ── Supabase client ─────────────────────────────────────────────────────────
  sb.SupabaseClient get _client => sb.Supabase.instance.client;

  // ── Reactive state ──────────────────────────────────────────────────────────
  final state = const AuthState().obs;

  // ── Convenience pass-throughs ────────────────────────────────────────────────
  UserModel? get user => state.value.user;
  CustomerModel? get customer => state.value.customer;
  bool get isAuthenticated => state.value.isAuthenticated;
  String? get currentUserId => _client.auth.currentUser?.id;
  sb.User? get currentAuthUser => _client.auth.currentUser;

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    // FIX: mock QA auth was injected here and the real listener was commented
    // out, meaning no real user could ever sign in or have their session
    // restored on cold start. Restored the real auth listener.
    _subscribeToAuthChanges();
  }

  // ── Auth state listener ──────────────────────────────────────────────────────

  void _subscribeToAuthChanges() {
    _client.auth.onAuthStateChange.listen((event) async {
      switch (event.event) {
        case sb.AuthChangeEvent.signedIn:
        case sb.AuthChangeEvent.tokenRefreshed:
        case sb.AuthChangeEvent.initialSession:
          await _loadUserData();
        case sb.AuthChangeEvent.signedOut:
          state.value = const AuthState();
        default:
          break;
      }
    });
  }

  // ── Internal data loading ────────────────────────────────────────────────────

  Future<void> _loadUserData() async {
    state.value = state.value.copyWith(isLoading: true, error: null);
    try {
      final userId = currentUserId;
      if (userId == null) {
        state.value = const AuthState();
        return;
      }

      final user = await _fetchUserProfile(userId);
      final roles = await _fetchUserRoles(userId);

      CustomerModel? customerRow;
      if (roles.contains('customer')) {
        try {
          customerRow = await _fetchCustomer(userId);
        } catch (_) {
          // Trigger delay after sign-up — non-fatal, retry on next refresh.
        }
      }

      state.value = AuthState(user: user, customer: customerRow, roles: roles);
      update();
      _redirectBasedOnRole();
    } catch (e, s) {
      // FIX: was catch (e) — stack trace was silently discarded.
      debugPrint('[AuthController._loadUserData] $e\n$s');
      state.value = AuthState(error: e.toString());
    }
  }

  void _redirectBasedOnRole() {
    // Do not snap users who are already inside a protected section.
    final route = Get.currentRoute;
    if (route.startsWith('/app/') ||
        route.startsWith('/admin/') ||
        route.startsWith('/pos/')) {
      return;
    }

    switch (state.value.highestRole) {
      case 'admin':
      case 'store_manager':
        Get.offAllNamed(AppRoutes.adminDashboard);
      case 'salesperson':
        Get.offAllNamed(AppRoutes.posAuth);
      default:
        Get.offAllNamed(AppRoutes.home);
    }
  }

  // ── Public auth actions ──────────────────────────────────────────────────────

  /// Signs the user in with email and password.
  ///
  /// On success, [_subscribeToAuthChanges] handles _loadUserData() and
  /// _redirectBasedOnRole() — no manual wiring needed here.
  /// On failure, sets state.error and rethrows so the UI can display it.
  Future<void> signIn(String email, String password) async {
    state.value = state.value.copyWith(isLoading: true, error: null);
    try {
      // FIX: entire method body was replaced with a hardcoded QA mock and a
      // 'return' statement before the real Supabase call. Removed entirely.
      // Real signInWithPassword is now called — auth listener does the rest.
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      // Note: isLoading stays true until _loadUserData() finishes via the
      // auth listener, which then sets state with isLoading: false.
    } on sb.AuthException catch (e, s) {
      state.value = AuthState(error: e.message);
      throw ErrorHandler.handle(e, s);
    } catch (e, s) {
      if (e is AppException) {
        state.value = AuthState(error: e.message);
        rethrow;
      }
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    state.value = state.value.copyWith(isLoading: true, error: null);
    try {
      final res = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          if (phone != null) 'phone': phone.trim(),
        },
      );
      if (res.user == null) {
        throw const AppException(
            message: 'Registration failed. Please try again.');
      }
      // FIX: isLoading was never reset on the success path when the auth
      // state-change listener fires slowly. Reset it here as a safety net.
      // The listener's _loadUserData() will overwrite with the full state
      // once it completes.
      state.value = state.value.copyWith(isLoading: false);
    } on sb.AuthException catch (e, s) {
      state.value = AuthState(error: e.message);
      throw ErrorHandler.handle(e, s);
    } catch (e, s) {
      if (e is AppException) {
        state.value = AuthState(error: e.message);
        rethrow;
      }
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } on sb.AuthException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on sb.AuthException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    } finally {
      state.value = const AuthState();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Force-refresh the current user's profile (e.g. after a profile update).
  Future<void> refreshAuth() => _loadUserData();

  // ── Private Supabase helpers ─────────────────────────────────────────────────

  Future<UserModel> _fetchUserProfile(String userId) async {
    Map<String, dynamic>? data;
    try {
      data = await _client
          .from(SupabaseConstants.profiles)
          .select('id, first_name, last_name, phone, avatar_url, '
              'role, status, created_at, updated_at')
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      debugPrint('[AuthController] fetchProfile error (may be new user): $e');
    }

    if (data == null) {
      // Fallback: profile row not yet inserted (trigger delay after sign-up).
      final authUser = _client.auth.currentUser;
      if (authUser != null && authUser.id == userId) {
        return UserModel(
          id: userId,
          firstName: authUser.userMetadata?['first_name'] as String? ?? 'New',
          lastName: authUser.userMetadata?['last_name'] as String? ?? 'User',
          phone: authUser.userMetadata?['phone'] as String?,
          role: UserRole.customer,
          status: 'active',
          createdAt: DateTime.tryParse(authUser.createdAt) ?? DateTime.now(),
          updatedAt: DateTime.tryParse(authUser.createdAt) ?? DateTime.now(),
        );
      }
      throw const AppException(message: 'User profile not found.');
    }
    return UserModel.fromJson(data);
  }

  Future<List<String>> _fetchUserRoles(String userId) async {
    try {
      final row = await _client
          .from(SupabaseConstants.profiles)
          .select('role')
          .eq('id', userId)
          .single();
      final role = row['role'] as String?;
      return role != null ? [role] : ['customer'];
    } on sb.PostgrestException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }

  Future<CustomerModel?> _fetchCustomer(String userId) async {
    final data = await _client
        .from(SupabaseConstants.customers)
        .select('id, loyalty_points, loyalty_tier, total_spent, '
            'date_of_birth, notes, created_at, updated_at')
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return CustomerModel.fromJson(data);
  }

  /// Updates the currently authenticated user's password.
  /// Supabase handles this via the active JWT — no current password needed.
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        sb.UserAttributes(password: newPassword),
      );
    } on sb.AuthException catch (e, s) {
      throw ErrorHandler.handle(e, s);
    }
  }
}
