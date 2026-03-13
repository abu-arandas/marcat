// lib/views/customer/scaffold/widgets/appbar.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

// FIX: auth_provider.dart → auth_controller.dart
import '../../../../controllers/auth_controller.dart';
// FIX: cart_repository.dart → cart_controller.dart
import '../../../../controllers/cart_controller.dart';
// FIX: category_repository.dart → product_controller.dart
//      Categories are pre-loaded by ProductController.onInit().
//      CategoryRepository no longer exists.
import '../../../../controllers/product_controller.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../models/user_model.dart';
import '../../shared/search_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CustomerAppBar
// ─────────────────────────────────────────────────────────────────────────────

class CustomerAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String pageName;
  final bool scrolled;

  /// Whether the host scaffold has a filter drawer.
  /// When false the filter/sort icon is hidden on mobile.
  final bool hasFilterDrawer;

  const CustomerAppBar({
    super.key,
    required this.pageName,
    required this.scrolled,
    this.hasFilterDrawer = false,
  });

  @override
  Size get preferredSize {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final logicalWidth = view.physicalSize.width / view.devicePixelRatio;
    final hasCategoryBar = logicalWidth > 768;
    return Size.fromHeight(65 + (hasCategoryBar ? 50 : 0));
  }

  @override
  State<CustomerAppBar> createState() => _CustomerAppBarState();
}

class _CustomerAppBarState extends State<CustomerAppBar> {
  // FIX: removed local `categories` field and the initState CategoryRepository
  //      fetch.  Categories are owned by ProductController (loaded in its
  //      onInit) and are read reactively via GetBuilder<ProductController>
  //      in the build method.

  bool get _isHome => widget.pageName.toLowerCase() == 'home';
  bool get _isTransparent => _isHome && !widget.scrolled;

  Color get _fg => _isTransparent
      ? Colors.white
      : Theme.of(Get.context!).colorScheme.primary;

  Color get _divider =>
      _isTransparent ? Colors.white.withOpacity(0.15) : const Color(0xFFEEE8E0);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width > 1024;
    final isTablet = width > 768 && width <= 1024;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: _isTransparent
            ? Colors.transparent
            : Colors.white.withOpacity(0.96),
        border: Border(bottom: BorderSide(color: _divider, width: 1)),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _isTransparent ? 0 : 16,
            sigmaY: _isTransparent ? 0 : 16,
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Main bar ────────────────────────────────────────────────
                FB5Container(
                  child: SizedBox(
                    height: 64,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Filter trigger (shop pages only on mobile)
                        if (MediaQuery.of(context).size.width < 768 &&
                            widget.hasFilterDrawer) ...[
                          _iconButton(
                            icon: Icons.tune_rounded,
                            route: 'filters',
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            tooltip: 'Filter & Sort',
                          ),
                          const SizedBox(width: 4),
                        ],

                        // ── Brand logo ───────────────────────────────────────
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.home),
                          style: ButtonStyle(
                            overlayColor:
                                WidgetStateProperty.all(Colors.transparent),
                            foregroundColor:
                                WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.hovered) ||
                                  states.contains(WidgetState.focused) ||
                                  states.contains(WidgetState.pressed)) {
                                return Theme.of(context).colorScheme.primary;
                              }
                              return _fg;
                            }),
                            textStyle: WidgetStateProperty.all(
                              const TextStyle(
                                fontFamily: 'Playfair Display',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text('MARCAT'),
                              const SizedBox(width: 4),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: _fg,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Desktop / tablet nav links ───────────────────────
                        if (isDesktop || isTablet) ...[
                          const SizedBox(width: 30),
                          _textButton(
                              title: 'About Us', route: AppRoutes.about),
                          _textButton(title: 'Our Shop', route: AppRoutes.shop),
                          _textButton(
                              title: 'Contact Us', route: AppRoutes.contact),
                        ],

                        const Spacer(),

                        // ── Right actions ────────────────────────────────────

                        // Search
                        _iconButton(
                          icon: Icons.search_rounded,
                          route: 'search',
                          tooltip: 'Search',
                          onPressed: () => SearchSheet.show(context),
                        ),

                        // Wishlist (tablet+)
                        if (isDesktop || isTablet) ...[
                          const SizedBox(width: 2),
                          _iconButton(
                            icon: Icons.favorite_outline_rounded,
                            route: AppRoutes.wishlist,
                            tooltip: 'Wishlist',
                            onPressed: () => Get.toNamed(AppRoutes.wishlist),
                          ),
                        ],

                        // Cart with item count badge
                        const SizedBox(width: 2),
                        GetBuilder<CartController>(
                          builder: (ctrl) {
                            final count = ctrl.items.length;
                            return _iconButton(
                              icon: Icons.shopping_bag_outlined,
                              route: AppRoutes.cart,
                              tooltip: 'Cart',
                              badge: count > 0 ? '$count' : null,
                              onPressed: () => Get.toNamed(AppRoutes.cart),
                            );
                          },
                        ),

                        // User avatar / sign-in
                        const SizedBox(width: 2),
                        GetBuilder<AuthController>(
                          builder: (ctrl) {
                            final user = ctrl.state.value.user;
                            return user != null
                                ? _UserAvatar(user: user, fg: _fg)
                                : _SignInButton(
                                    isDesktop: isDesktop, color: _fg);
                          },
                        ),

                        // Mobile hamburger
                        if (!isDesktop) ...[
                          const SizedBox(width: 4),
                          _iconButton(
                            icon: Icons.menu_rounded,
                            route: 'menu',
                            tooltip: 'Menu',
                            onPressed: () =>
                                Scaffold.of(context).openEndDrawer(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // ── Category row (desktop/tablet) ────────────────────────────
                // FIX: was reading from a local `categories` field populated by
                //      CategoryRepository in initState.  Now reads directly from
                //      ProductController via GetBuilder — no repository needed.
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
                              ? Colors.black.withOpacity(0.15)
                              : Colors.white60,
                          border: Border(top: BorderSide(color: _divider)),
                        ),
                        child: FB5Container(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: cats
                                  .map((cat) => _textButton(
                                        title: cat.name,
                                        route: '/app/category/${cat.id}',
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textButton({required String title, required String route}) {
    final isActive = Get.currentRoute.contains(route);

    // FIX: was MaterialStateProperty / MaterialState
    Color resolveColor(Set<WidgetState> states) {
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused) ||
          states.contains(WidgetState.pressed)) {
        return Theme.of(context).colorScheme.primary;
      }
      if (isActive) return Theme.of(context).colorScheme.primary;
      return widget.scrolled || Get.currentRoute != AppRoutes.home
          ? Colors.black
          : Theme.of(context).colorScheme.onPrimary;
    }

    return TextButton(
      onPressed: () => Get.toNamed(route),
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith(resolveColor),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
      ),
      child: Text(
        title.titleCase,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required String route,
    String? tooltip,
    String? badge,
    required VoidCallback onPressed,
  }) {
    final isActive = Get.currentRoute.contains(route);

    Color resolveColor(Set<WidgetState> states) {
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused) ||
          states.contains(WidgetState.pressed)) {
        return Theme.of(context).colorScheme.primary;
      }
      if (isActive) return Theme.of(context).colorScheme.primary;
      return widget.scrolled || Get.currentRoute != AppRoutes.home
          ? Colors.black
          : Theme.of(context).colorScheme.onPrimary;
    }

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Builder(
        builder: (context) {
          Widget iconWidget = Icon(icon, size: 22);
          if (badge != null) {
            iconWidget = Badge(
              backgroundColor: const Color(0xFFD64545),
              label: Text(badge, style: const TextStyle(fontSize: 10)),
              child: iconWidget,
            );
          }
          return iconWidget;
        },
      ),
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith(resolveColor),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _UserAvatar — popup menu with profile, orders, wishlist, sign-out
// ─────────────────────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  final UserModel user;
  final Color fg;

  const _UserAvatar({required this.user, required this.fg});

  static String _initials(String firstName, String lastName) {
    final parts = '$firstName $lastName'.trim().split(' ');
    return parts
        .where((w) => w.isNotEmpty)
        .map((w) => w[0])
        .take(2)
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials(user.firstName, user.lastName);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: PopupMenuButton<int>(
        offset: const Offset(0, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 12,
        shadowColor: Colors.black.withOpacity(0.14),
        color: Colors.white,
        itemBuilder: (_) => [
          // Profile header (non-interactive)
          PopupMenuItem(
            enabled: false,
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (user.phone != null)
                    Text(
                      user.phone!,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7C93)),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
          const PopupMenuDivider(height: 1),
          _menuItem(1, Icons.person_outline_rounded, 'Edit Profile'),
          _menuItem(2, Icons.receipt_long_outlined, 'My Orders'),
          _menuItem(3, Icons.favorite_outline_rounded, 'Wishlist'),
          const PopupMenuDivider(height: 1),
          _menuItem(4, Icons.logout_rounded, 'Sign Out',
              color: const Color(0xFFDC2626)),
        ],
        onSelected: (v) {
          switch (v) {
            case 1:
              Get.toNamed(AppRoutes.profile);
            case 2:
              Get.toNamed(AppRoutes.orders);
            case 3:
              Get.toNamed(AppRoutes.wishlist);
            case 4:
              Get.find<AuthController>().signOut();
          }
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: fg.withOpacity(0.25), width: 2),
            color: Theme.of(context).colorScheme.primary,
            image: user.avatarUrl != null
                ? DecorationImage(
                    image: NetworkImage(user.avatarUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          // Show initials only when there is NO avatar image
          child: user.avatarUrl == null
              ? Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  PopupMenuItem<int> _menuItem(
    int value,
    IconData icon,
    String label, {
    Color? color,
  }) {
    final c = color ?? Theme.of(Get.context!).colorScheme.primary;
    return PopupMenuItem(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c),
          const SizedBox(width: 12),
          Text(
            label,
            style:
                TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SignInButton
// ─────────────────────────────────────────────────────────────────────────────

class _SignInButton extends StatelessWidget {
  final bool isDesktop;
  final Color color;

  const _SignInButton({required this.isDesktop, required this.color});

  @override
  Widget build(BuildContext context) => isDesktop
      ? TextButton.icon(
          onPressed: () => Get.toNamed(AppRoutes.login),
          style: TextButton.styleFrom(
            foregroundColor: color,
            overlayColor: color.withOpacity(0.08),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          icon: Icon(Icons.person_outline_rounded, size: 18, color: color),
          label: const Text('Sign In'),
        )
      : IconButton(
          onPressed: () => Get.toNamed(AppRoutes.login),
          tooltip: 'Sign In',
          icon: Icon(Icons.person_outline_rounded, size: 22, color: color),
          style: IconButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(8),
          ),
        );
}
