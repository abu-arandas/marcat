// lib/views/admin/scaffold/app_scaffold.dart
//
// Root shell for every admin screen.
//
// Mirrors the customer-side scaffold architecture:
//   customer/scaffold/app_scaffold.dart  ←→  admin/scaffold/app_scaffold.dart
//   customer/scaffold/widgets/appbar.dart ←→  admin/scaffold/widgets/navigation_rail.dart
//   customer/scaffold/widgets/body.dart   ←→  admin/scaffold/widgets/body.dart
//   customer/scaffold/widgets/drawer.dart ←→  admin/scaffold/widgets/bottom_nav.dart
//
// Layout strategy:
//  • Desktop / Tablet  → extended NavigationRail (left) + IndexedStack (right)
//  • Mobile            → IndexedStack body + NavigationBar (bottom)

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';

import 'widgets/navigation_rail.dart';
import 'widgets/bottom_nav.dart';
import '../dashboard/dashboard_screen.dart';
import '../products/product_list_screen.dart';
import '../orders/order_list_screen.dart';
import '../staff/staff_list_screen.dart';
import '../settings/admin_settings_screen.dart';
import '../shared/brand.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminAppScaffold
// ─────────────────────────────────────────────────────────────────────────────

/// Root navigation scaffold for the admin panel.
///
/// Switches between a side [NavigationRail] on tablet/desktop and a
/// [NavigationBar] on mobile — keeping the admin content always inside
/// an [IndexedStack] so each tab preserves its scroll position and
/// controller state.
class AdminAppScaffold extends StatefulWidget {
  const AdminAppScaffold({super.key});

  @override
  State<AdminAppScaffold> createState() => _AdminAppScaffoldState();
}

class _AdminAppScaffoldState extends State<AdminAppScaffold> {
  int _currentIndex = 0;

  // Pages are instantiated once and kept alive inside the IndexedStack.
  static const _pages = <Widget>[
    AdminDashboardScreen(),
    AdminProductListScreen(),
    AdminOrderListScreen(),
    AdminStaffListScreen(),
    AdminSettingsScreen(),
  ];

  // ── Destination definitions ───────────────────────────────────────────────

  static const _destinations = <AdminDestination>[
    AdminDestination(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    AdminDestination(
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
      label: 'Products',
    ),
    AdminDestination(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
      label: 'Orders',
    ),
    AdminDestination(
      icon: Icons.group_outlined,
      selectedIcon: Icons.group_rounded,
      label: 'Staff',
    ),
    AdminDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  void _onDestinationSelected(int index) =>
      setState(() => _currentIndex = index);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return FlutterBootstrap5(
      builder: (ctx) {
        final bp = BootstrapTheme.of(ctx);
        final isDesktop =
            bp.currentBreakPoint.isBreakPointOrLarger(bp.breakPoints.lg);
        final isTablet = bp.currentBreakPoint == bp.breakPoints.md;

        if (isDesktop || isTablet) {
          return _DesktopLayout(
            currentIndex: _currentIndex,
            destinations: _destinations,
            pages: _pages,
            extended: isDesktop,
            onDestinationSelected: _onDestinationSelected,
          );
        }

        return _MobileLayout(
          currentIndex: _currentIndex,
          destinations: _destinations,
          pages: _pages,
          onDestinationSelected: _onDestinationSelected,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AdminDestination — data class for nav items
// ─────────────────────────────────────────────────────────────────────────────

/// Lightweight data class for navigation destinations.
class AdminDestination {
  const AdminDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

// ─────────────────────────────────────────────────────────────────────────────
// _DesktopLayout
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.currentIndex,
    required this.destinations,
    required this.pages,
    required this.extended,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final List<AdminDestination> destinations;
  final List<Widget> pages;
  final bool extended;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kSurface,
        body: Row(
          children: [
            // ── Navigation Rail ──────────────────────────────────────────
            AdminNavigationRail(
              currentIndex: currentIndex,
              destinations: destinations,
              extended: extended,
              onDestinationSelected: onDestinationSelected,
            ),

            // ── Content area ─────────────────────────────────────────────
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: pages,
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _MobileLayout
// ─────────────────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.currentIndex,
    required this.destinations,
    required this.pages,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final List<AdminDestination> destinations;
  final List<Widget> pages;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kSurface,
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: AdminBottomNav(
          currentIndex: currentIndex,
          destinations: destinations,
          onDestinationSelected: onDestinationSelected,
        ),
      );
}
