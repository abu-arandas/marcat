// lib/views/customer/scaffold/widgets/drawer.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/models/user_model.dart';
import 'package:marcat/core/router/app_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Brand constants — kept local so the drawer has no dependency on app_colors
// ─────────────────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1A1A2E);
const _kGold = Color(0xFFC9A84C);
const _kCream = Color(0xFFF5F0E8);

// ─────────────────────────────────────────────────────────────────────────────
// CustomerDrawer
// ─────────────────────────────────────────────────────────────────────────────

class CustomerDrawer extends StatelessWidget {
  const CustomerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Drawer(
      backgroundColor: _kNavy,
      child: SafeArea(
        child: Column(
          children: [
            // ── Header (user-aware) ─────────────────────────────────────
            Obx(() {
              final user = auth.state.value.user;
              return _DrawerHeader(user: user);
            }),

            const Divider(color: Colors.white12, height: 1),

            // ── Navigation links ────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerLink(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () => _go(context, AppRoutes.home),
                  ),
                  _DrawerLink(
                    icon: Icons.storefront_outlined,
                    label: 'Shop',
                    onTap: () => _go(context, AppRoutes.shop),
                  ),
                  _DrawerLink(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Cart',
                    onTap: () => _go(context, AppRoutes.cart),
                  ),
                  _DrawerLink(
                    icon: Icons.favorite_border,
                    label: 'Wishlist',
                    onTap: () => _go(context, AppRoutes.wishlist),
                  ),
                  _DrawerLink(
                    icon: Icons.receipt_long_outlined,
                    label: 'My Orders',
                    onTap: () => _go(context, AppRoutes.orders),
                  ),
                  _DrawerLink(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: () => _go(context, AppRoutes.profile),
                  ),
                  const Divider(color: Colors.white12),
                  _DrawerLink(
                    icon: Icons.info_outline,
                    label: 'About',
                    onTap: () => _go(context, AppRoutes.about),
                  ),
                  _DrawerLink(
                    icon: Icons.contact_support_outlined,
                    label: 'Contact',
                    onTap: () => _go(context, AppRoutes.contact),
                  ),
                ],
              ),
            ),

            // ── Footer ──────────────────────────────────────────────────
            Obx(() {
              final user = auth.state.value.user;
              return _DrawerFooter(user: user);
            }),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, String route) {
    Navigator.of(context).pop();
    Get.toNamed(route);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DrawerHeader
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return _AuthenticatedHeader(user: user!);
    }
    return const _GuestHeader();
  }
}

class _AuthenticatedHeader extends StatelessWidget {
  const _AuthenticatedHeader({required this.user});

  final UserModel user;

  String get _initials {
    final f = user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '';
    final l = (user.lastName.isNotEmpty) ? user.lastName[0].toUpperCase() : '';
    return '$f$l'.isNotEmpty ? '$f$l' : 'U';
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: _kGold.withOpacity(0.3),
              backgroundImage:
                  user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null
                  ? Text(
                      _initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  if (user.phone != null)
                    Text(
                      user.phone!,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6), fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.profile),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Text(
                        'View Profile',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _GuestHeader extends StatelessWidget {
  const _GuestHeader();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  'MARCAT',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
                SizedBox(width: 5),
                CircleAvatar(radius: 3, backgroundColor: _kGold),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to track orders, save\nyour wishlist & more.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGold,
                  foregroundColor: _kNavy,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.4,
                  ),
                ),
                child: const Text('Sign In / Register'),
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _DrawerFooter
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerFooter extends StatelessWidget {
  final UserModel? user;

  const _DrawerFooter({this.user});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        decoration: const BoxDecoration(
          color: _kCream,
          border: Border(top: BorderSide(color: Color(0xFFEEE8E0))),
        ),
        child: user != null ? _AuthFooter(user: user!) : const _GuestFooter(),
      );
}

class _AuthFooter extends StatelessWidget {
  const _AuthFooter({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          user.firstName,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: _kNavy,
          ),
        ),
        TextButton.icon(
          onPressed: () => auth.signOut(),
          icon: const Icon(Icons.logout, size: 16, color: _kNavy),
          label: const Text(
            'Sign Out',
            style: TextStyle(color: _kNavy, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _GuestFooter extends StatelessWidget {
  const _GuestFooter();

  @override
  Widget build(BuildContext context) => const Text(
        '© 2025 Marcat. All rights reserved.',
        style: TextStyle(
          fontSize: 11,
          color: Color(0xFF9E9E9E),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _DrawerLink
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerLink extends StatelessWidget {
  const _DrawerLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: Colors.white70, size: 20),
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        dense: true,
      );
}
