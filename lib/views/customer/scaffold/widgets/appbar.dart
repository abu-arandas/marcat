// lib/views/customer/scaffold/widgets/appbar.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/controllers/cart_controller.dart';
import 'package:marcat/controllers/product_controller.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/models/user_model.dart';

import '../../shared/search_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CustomerAppBar
// ─────────────────────────────────────────────────────────────────────────────

/// Frosted-glass sticky app bar used by [CustomerScaffold].
///
/// - Transparent on the home hero, opaque (frosted) when scrolled.
/// - Shows the category strip on tablet & desktop.
/// - Responsive: collapses nav links to hamburger on mobile.
class CustomerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomerAppBar({
    super.key,
    required this.pageName,
    required this.scrolled,
    required this.hasFilterDrawer,
  });

  final String pageName;
  final bool scrolled;
  final bool hasFilterDrawer;

  bool get _isTransparent => !scrolled;

  @override
  Size get preferredSize => const Size.fromHeight(105);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width > 1024;
    final isTablet = width > 600;

    final Color fg = _isTransparent ? Colors.white : AppColors.marcatNavy;
    // withAlpha(26) ≈ 10 % opacity for the border tint
    final Color divider =
        _isTransparent ? Colors.white.withAlpha(26) : AppColors.borderLight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      // withAlpha(245) ≈ 96 % opacity
      color: _isTransparent ? Colors.transparent : Colors.white.withAlpha(245),
      foregroundDecoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: divider, width: 1)),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _isTransparent ? 0 : 16,
            sigmaY: _isTransparent ? 0 : 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Primary bar ───────────────────────────────────────────────
              SizedBox(
                height: 65,
                child: FB5Container(
                  child: Row(
                    children: [
                      // Brand wordmark
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.home),
                        child: Text(
                          'MARCAT',
                          style: TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _isTransparent
                                ? Colors.white
                                : AppColors.marcatGold,
                            letterSpacing: 3,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Desktop nav links
                      if (isDesktop) ...[
                        _NavLink(label: 'Shop', route: AppRoutes.shop, fg: fg),
                        _NavLink(
                            label: 'About', route: AppRoutes.about, fg: fg),
                        _NavLink(
                            label: 'Contact',
                            route: AppRoutes.contact,
                            fg: fg),
                        const SizedBox(width: 16),
                      ],

                      // Mobile filter icon (only when page has a filter drawer)
                      if (!isDesktop && hasFilterDrawer)
                        _iconButton(
                          icon: Icons.tune_rounded,
                          tooltip: 'Filter',
                          color: fg,
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),

                      // Search
                      _iconButton(
                        icon: Icons.search_rounded,
                        tooltip: 'Search',
                        color: fg,
                        onPressed: () => SearchSheet.show(context),
                      ),

                      // Cart with badge
                      GetBuilder<CartController>(
                        builder: (cart) {
                          final count = cart.items
                              .fold<int>(0, (sum, item) => sum + item.quantity);
                          return _CartIcon(
                            count: count > 0 ? '$count' : null,
                            color: fg,
                            onPressed: () => Get.toNamed(AppRoutes.cart),
                          );
                        },
                      ),

                      // User avatar / sign-in button
                      const SizedBox(width: 2),
                      GetBuilder<AuthController>(
                        builder: (ctrl) {
                          final user = ctrl.state.value.user;
                          return user != null
                              ? _UserAvatar(user: user, fg: fg)
                              : _SignInButton(
                                  isDesktop: isDesktop,
                                  color: fg,
                                );
                        },
                      ),

                      // Mobile hamburger
                      if (!isDesktop) ...[
                        const SizedBox(width: 4),
                        _iconButton(
                          icon: Icons.menu_rounded,
                          tooltip: 'Menu',
                          color: fg,
                          onPressed: () => Scaffold.of(context).openEndDrawer(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Category strip (tablet+) ───────────────────────────────────
              if (isDesktop || isTablet)
                GetBuilder<ProductController>(
                  builder: (productCtrl) {
                    final cats = productCtrl.categories;
                    if (cats.isEmpty) return const SizedBox.shrink();
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 40,
                      decoration: BoxDecoration(
                        color: _isTransparent
                            ? Colors.transparent
                            // withAlpha(230) ≈ 90 % opacity
                            : AppColors.marcatCream.withAlpha(230),
                        border: Border(
                          bottom: BorderSide(color: divider, width: 1),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: cats.map((cat) {
                            return GestureDetector(
                              onTap: () =>
                                  Get.toNamed(AppRoutes.categoryOf(cat.id)),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  cat.name.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexSansArabic',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                    // withAlpha(204) ≈ 80 % opacity
                                    color: _isTransparent
                                        ? Colors.white.withAlpha(204)
                                        : AppColors.marcatNavy,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget _iconButton({
  required IconData icon,
  required String tooltip,
  required Color color,
  required VoidCallback onPressed,
}) =>
    IconButton(
      icon: Icon(icon, color: color),
      tooltip: tooltip,
      onPressed: onPressed,
      splashRadius: 20,
    );

// ─────────────────────────────────────────────────────────────────────────────
// _NavLink
// ─────────────────────────────────────────────────────────────────────────────

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.label,
    required this.route,
    required this.fg,
  });

  final String label;
  final String route;
  final Color fg;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => Get.toNamed(widget.route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 160),
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    _hovered ? AppColors.marcatGold : widget.fg.withAlpha(230),
                letterSpacing: 0.5,
              ),
              child: Text(widget.label.toUpperCase()),
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _CartIcon
// ─────────────────────────────────────────────────────────────────────────────

class _CartIcon extends StatelessWidget {
  const _CartIcon({
    required this.count,
    required this.color,
    required this.onPressed,
  });

  final String? count;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(Icons.shopping_bag_outlined, color: color),
            tooltip: 'Cart',
            onPressed: onPressed,
            splashRadius: 20,
          ),
          if (count != null)
            Positioned(
              top: 6,
              right: 4,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.marcatGold,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _UserAvatar
// ─────────────────────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user, required this.fg});

  final UserModel user;
  final Color fg;

  String get _initials {
    final f = user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '';
    final l = user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : '';
    return '$f$l'.isNotEmpty ? '$f$l' : 'U';
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.profile),
        child: Tooltip(
          message: 'Profile',
          child: CircleAvatar(
            radius: 17,
            // withAlpha(51) ≈ 20 % opacity
            backgroundColor: AppColors.marcatGold.withAlpha(51),
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Text(
                    _initials,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  )
                : null,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _SignInButton
// ─────────────────────────────────────────────────────────────────────────────

class _SignInButton extends StatefulWidget {
  const _SignInButton({required this.isDesktop, required this.color});

  final bool isDesktop;
  final Color color;

  @override
  State<_SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<_SignInButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isDesktop) {
      return IconButton(
        icon: Icon(Icons.person_outline_rounded, color: widget.color),
        tooltip: 'Sign In',
        onPressed: () => Get.toNamed(AppRoutes.login),
        splashRadius: 20,
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.login),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.marcatGold : Colors.transparent,
            border: Border.all(
              color:
                  _hovered ? AppColors.marcatGold : widget.color.withAlpha(230),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Sign In',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _hovered ? AppColors.marcatNavy : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
