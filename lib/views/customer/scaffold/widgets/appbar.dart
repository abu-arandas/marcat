// lib/views/customer/scaffold/widgets/appbar.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import '../../../../controllers/auth_controller.dart';
import '../../../../controllers/cart_controller.dart';
import '../../../../controllers/product_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../models/user_model.dart';
import '../../shared/search_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CustomerAppBar
// ─────────────────────────────────────────────────────────────────────────────

class CustomerAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomerAppBar({
    super.key,
    required this.pageName,
    required this.scrolled,
    this.hasFilterDrawer = false,
  });

  final String pageName;
  final bool scrolled;

  /// When true the filter/sort icon is shown on mobile.
  final bool hasFilterDrawer;

  @override
  Size get preferredSize {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final logicalWidth = view.physicalSize.width / view.devicePixelRatio;
    // Category bar is shown at tablet+ widths.
    final hasCategoryBar = logicalWidth > 768;
    return Size.fromHeight(65 + (hasCategoryBar ? 48 : 0));
  }

  @override
  State<CustomerAppBar> createState() => _CustomerAppBarState();
}

class _CustomerAppBarState extends State<CustomerAppBar> {
  bool get _isHome => widget.pageName.toLowerCase() == 'home';
  bool get _isTransparent => _isHome && !widget.scrolled;

  Color get _fg => _isTransparent ? Colors.white : AppColors.marcatNavy;

  Color get _divider => _isTransparent
      ? Colors.white.withOpacity(0.15)
      : AppColors.borderStrong;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width > 1024;
    final isTablet = width > 768 && width <= 1024;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color:
            _isTransparent ? Colors.transparent : Colors.white.withOpacity(0.96),
        border: Border(bottom: BorderSide(color: _divider, width: 1)),
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
                        _NavLink(label: 'Shop', route: AppRoutes.shop, fg: _fg),
                        _NavLink(label: 'About', route: AppRoutes.about, fg: _fg),
                        _NavLink(
                            label: 'Contact', route: AppRoutes.contact, fg: _fg),
                        const SizedBox(width: 16),
                      ],

                      // Mobile filter icon (shown only when page has a filter drawer)
                      if (!isDesktop && widget.hasFilterDrawer)
                        _iconButton(
                          icon: Icons.tune_rounded,
                          tooltip: 'Filter',
                          color: _fg,
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),

                      // Search
                      _iconButton(
                        icon: Icons.search_rounded,
                        tooltip: 'Search',
                        color: _fg,
                        onPressed: () => SearchSheet.show(context),
                      ),

                      // Cart with badge
                      GetBuilder<CartController>(
                        builder: (cart) {
                          final count = cart.items.fold<int>(
                              0, (sum, item) => sum + item.quantity);
                          return _CartIcon(
                            count: count > 0 ? '$count' : null,
                            color: _fg,
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
                              ? _UserAvatar(user: user, fg: _fg)
                              : _SignInButton(isDesktop: isDesktop, color: _fg);
                        },
                      ),

                      // Mobile hamburger
                      if (!isDesktop) ...[
                        const SizedBox(width: 4),
                        _iconButton(
                          icon: Icons.menu_rounded,
                          tooltip: 'Menu',
                          color: _fg,
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
                            : AppColors.marcatCream.withOpacity(0.9),
                        border: Border(
                          bottom: BorderSide(color: _divider, width: 1),
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
                                    color: _fg.withOpacity(0.8),
                                    letterSpacing: 1.5,
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

// ── Private helpers ───────────────────────────────────────────────────────────

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
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: _hovered
                    ? AppColors.marcatGold
                    : widget.fg.withOpacity(0.9),
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
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: BoxDecoration(
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
            backgroundColor: AppColors.marcatGold.withOpacity(0.2),
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
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

class _SignInButton extends StatelessWidget {
  const _SignInButton({required this.isDesktop, required this.color});

  final bool isDesktop;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return TextButton(
        onPressed: () => Get.toNamed(AppRoutes.login),
        child: Text(
          'Sign In',
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: color,
          ),
        ),
      );
    }
    return _iconButton(
      icon: Icons.person_outline_rounded,
      tooltip: 'Sign In',
      color: color,
      onPressed: () => Get.toNamed(AppRoutes.login),
    );
  }
}
