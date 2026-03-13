// lib/views/customer/scaffold/widgets/drawer.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// FIX: was importing auth_provider.dart — replaced by auth_controller.dart
import '../../../../controllers/auth_controller.dart';
import 'package:marcat/core/router/app_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Brand constants
// ─────────────────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1A1A2E);
const _kGold = Color(0xFFC9A84C);
const _kCream = Color(0xFFF8F5F0);

// ─────────────────────────────────────────────────────────────────────────────
// ClientDrawer  (end-drawer / main navigation)
// ─────────────────────────────────────────────────────────────────────────────

class ClientDrawer extends StatelessWidget {
  const ClientDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    return Drawer(
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      child: Obx(() {
        final user = Get.find<AuthController>().state.value.user;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────
            _DrawerHeader(user: user),

            // ── Navigation ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop by category
                    const _SectionLabel('Shop'),
                    const SizedBox(height: 8),
                    _DrawerLink(
                      title: 'Women',
                      icon: Icons.woman_outlined,
                      isActive: currentRoute.contains('/women'),
                      onTap: () => Get.toNamed('/app/shop/women'),
                    ),
                    _DrawerLink(
                      title: 'Men',
                      icon: Icons.man_outlined,
                      isActive: currentRoute.contains('/men'),
                      onTap: () => Get.toNamed('/app/shop/men'),
                    ),
                    _DrawerLink(
                      title: 'Kids',
                      icon: Icons.child_care_outlined,
                      isActive: currentRoute.contains('/kids'),
                      onTap: () => Get.toNamed('/app/shop/kids'),
                    ),
                    _DrawerLink(
                      title: 'New Arrivals',
                      icon: Icons.new_releases_outlined,
                      isActive: currentRoute.contains('/new'),
                      onTap: () => Get.toNamed('/app/shop/new'),
                    ),
                    _DrawerLink(
                      title: 'Sale',
                      icon: Icons.local_offer_outlined,
                      isActive: currentRoute.contains('/sale'),
                      onTap: () => Get.toNamed('/app/shop/sale'),
                      accent: const Color(0xFFD64545),
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFEEE8E0)),
                    const SizedBox(height: 16),

                    // Explore
                    const _SectionLabel('Explore'),
                    const SizedBox(height: 8),
                    _DrawerLink(
                      title: 'Home',
                      icon: Icons.home_outlined,
                      isActive: currentRoute == '/app/home',
                      onTap: () => Get.toNamed(AppRoutes.home),
                    ),
                    _DrawerLink(
                      title: 'All Products',
                      icon: Icons.storefront_outlined,
                      isActive: currentRoute == '/app/shop',
                      onTap: () => Get.toNamed(AppRoutes.shop),
                    ),
                    _DrawerLink(
                      title: 'Wishlist',
                      icon: Icons.favorite_outline_rounded,
                      isActive: currentRoute.contains('wishlist'),
                      onTap: () => Get.toNamed(AppRoutes.wishlist),
                    ),
                    _DrawerLink(
                      title: 'Cart',
                      icon: Icons.shopping_bag_outlined,
                      isActive: currentRoute.contains('cart'),
                      onTap: () => Get.toNamed(AppRoutes.cart),
                    ),
                    if (user != null)
                      _DrawerLink(
                        title: 'My Orders',
                        icon: Icons.receipt_long_outlined,
                        isActive: currentRoute.contains('orders'),
                        onTap: () => Get.toNamed(AppRoutes.orders),
                      ),

                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFEEE8E0)),
                    const SizedBox(height: 16),

                    // Company
                    const _SectionLabel('Company'),
                    const SizedBox(height: 8),
                    _DrawerLink(
                      title: 'About Us',
                      icon: Icons.info_outline_rounded,
                      isActive: currentRoute.contains('about'),
                      onTap: () => Get.toNamed(AppRoutes.about),
                    ),
                    _DrawerLink(
                      title: 'Contact Us',
                      icon: Icons.phone_outlined,
                      isActive: currentRoute.contains('contact'),
                      onTap: () => Get.toNamed(AppRoutes.contact),
                    ),
                    _DrawerLink(
                      title: 'Size Guide',
                      icon: Icons.straighten_outlined,
                      isActive: currentRoute.contains('size'),
                      onTap: () => Get.toNamed('/app/size-guide'),
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer ───────────────────────────────────────────────────
            _DrawerFooter(user: user),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drawer header
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  final dynamic user; // UserModel | null

  const _DrawerHeader({this.user});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.paddingOf(context).top + 24,
          24,
          24,
        ),
        color: _kNavy,
        child:
            user != null ? _LoggedInHeader(user: user) : const _GuestHeader(),
      );
}

class _LoggedInHeader extends StatelessWidget {
  final dynamic user;

  const _LoggedInHeader({required this.user});

  static String _initials(String firstName, String? lastName) {
    final full = '$firstName ${lastName ?? ''}'.trim();
    return full
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0])
        .take(2)
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials(user.firstName, user.lastName);

    return Row(
      children: [
        // Avatar
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
            image: user.avatarUrl != null
                ? DecorationImage(
                    image: NetworkImage(user.avatarUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
            color: _kGold,
          ),
          // Show initials only when there is NO avatar image
          child: user.avatarUrl == null
              ? Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
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
                '${user.firstName} ${user.lastName ?? ''}',
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
              // "View Profile" chip
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.profile),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
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
    );
  }
}

class _GuestHeader extends StatelessWidget {
  const _GuestHeader();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'MARCAT',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
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
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Drawer footer
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerFooter extends StatelessWidget {
  final dynamic user;

  const _DrawerFooter({this.user});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        decoration: const BoxDecoration(
          color: _kCream,
          border: Border(top: BorderSide(color: Color(0xFFEEE8E0))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sign out (logged-in only)
            if (user != null) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Get.find<AuthController>().signOut(),
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Social links
            const Text(
              'FOLLOW US',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9E9E9E),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Instagram',
                  url: 'https://www.instagram.com/abu_arandas/',
                ),
                _SocialButton(
                  icon: Icons.facebook_outlined,
                  label: 'Facebook',
                  url: 'https://web.facebook.com/abu00arandas/',
                ),
                _SocialButton(
                  icon: Icons.chat_outlined,
                  label: 'WhatsApp',
                  url: 'https://wa.me/0791568798',
                ),
              ],
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 2,
              color: _kGold,
              margin: const EdgeInsets.only(right: 8),
            ),
            Text(
              text.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9E9E9E),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      );
}

class _DrawerLink extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final Color? accent;

  const _DrawerLink({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = accent ?? _kNavy;
    const inactiveColor = Color(0xFF6B7C93);

    return ListTile(
      onTap: onTap,
      selected: isActive,
      selectedColor: activeColor,
      selectedTileColor: activeColor.withOpacity(0.07),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Icon(
        icon,
        size: 20,
        color: isActive ? activeColor : inactiveColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? activeColor : inactiveColor,
        ),
      ),
      trailing: isActive
          ? Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: accent ?? _kGold,
                shape: BoxShape.circle,
              ),
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      minLeadingWidth: 20,
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
        message: label,
        child: IconButton(
          onPressed: () {}, // TODO: launch(url)
          icon: Icon(icon, size: 20),
          color: const Color(0xFF6B7C93),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFEEE8E0)),
            ),
            padding: const EdgeInsets.all(10),
          ),
        ),
      );
}
