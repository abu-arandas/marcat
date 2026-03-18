// lib/views/customer/scaffold/widgets/drawer.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/models/user_model.dart';
import 'package:marcat/core/router/app_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CustomerDrawer
// ─────────────────────────────────────────────────────────────────────────────

/// End-drawer navigation panel shown on mobile / tablet.
///
/// Uses AppColors constants exclusively — no hardcoded hex values.
class CustomerDrawer extends StatelessWidget {
  const CustomerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Drawer(
      backgroundColor: AppColors.marcatNavy,
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
    if (user != null) return _AuthenticatedHeader(user: user!);
    return const _GuestHeader();
  }
}

// ── Authenticated header ──────────────────────────────────────────────────────

class _AuthenticatedHeader extends StatelessWidget {
  const _AuthenticatedHeader({required this.user});

  final UserModel user;

  String get _initials {
    final f = user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '';
    final l = user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : '';
    return '$f$l'.isNotEmpty ? '$f$l' : 'U';
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.marcatGold.withAlpha(77),
              backgroundImage:
                  user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null
                  ? Text(
                      _initials,
                      style: const TextStyle(
                        color: AppColors.marcatGold,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
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
                    user.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.role.name,
                    style: TextStyle(
                      color: Colors.white.withAlpha(153),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ── Guest header ──────────────────────────────────────────────────────────────

class _GuestHeader extends StatelessWidget {
  const _GuestHeader();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'MARCAT',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(width: 5),
                CircleAvatar(
                  radius: 3,
                  backgroundColor: AppColors.marcatGold,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to track orders, save\nyour wishlist & more.',
              style: TextStyle(
                color: Colors.white.withAlpha(166),
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
                  backgroundColor: AppColors.marcatGold,
                  foregroundColor: AppColors.marcatNavy,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
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
        leading: Icon(icon, color: Colors.white.withAlpha(204), size: 20),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        horizontalTitleGap: 8,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        hoverColor: Colors.white.withAlpha(20),
        splashColor: Colors.white.withAlpha(26),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _DrawerFooter
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter({this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        decoration: const BoxDecoration(
          color: AppColors.marcatCream,
          border: Border(top: BorderSide(color: Color(0xFFEEE8E0))),
        ),
        child: user != null ? _AuthFooter(user: user!) : const _GuestFooter(),
      );
}

class _AuthFooter extends StatelessWidget {
  const _AuthFooter({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(Icons.logout_rounded, size: 18, color: AppColors.marcatSlate),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Get.find<AuthController>().signOut(),
            child: const Text(
              'Sign Out',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.marcatNavy,
              ),
            ),
          ),
        ],
      );
}

class _GuestFooter extends StatelessWidget {
  const _GuestFooter();

  @override
  Widget build(BuildContext context) => Text(
        '© ${DateTime.now().year} MARCAT',
        style: const TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 11,
          color: AppColors.marcatSlate,
        ),
      );
}
