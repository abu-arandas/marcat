// lib/views/admin/app_scaffold.dart
//
// Root shell for every admin screen.
//
// Layout strategy:
//  • Desktop / Tablet  → extended NavigationRail (left) + IndexedStack (right)
//  • Mobile            → IndexedStack body + NavigationBar (bottom)
//
// The NavigationRail uses the brand navy background with gold accents,
// matching the dark drawer treatment on the customer side.

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import 'dashboard/dashboard_screen.dart';
import 'products/product_list_screen.dart';
import 'orders/order_list_screen.dart';
import 'staff/staff_list_screen.dart';
import 'settings/admin_settings_screen.dart';

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
  static const _pages = [
    AdminDashboardScreen(),
    AdminProductListScreen(),
    AdminOrderListScreen(),
    AdminStaffListScreen(),
    AdminSettingsScreen(),
  ];

  // ── Destination definitions ───────────────────────────────────────────────

  static const _destinations = <_AdminDestination>[
    _AdminDestination(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _AdminDestination(
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
      label: 'Products',
    ),
    _AdminDestination(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
      label: 'Orders',
    ),
    _AdminDestination(
      icon: Icons.group_outlined,
      selectedIcon: Icons.group_rounded,
      label: 'Staff',
    ),
    _AdminDestination(
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
      builder: (context) {
        final bp = BootstrapTheme.of(context);
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
  final List<_AdminDestination> destinations;
  final List<Widget> pages;
  final bool extended;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.surfaceGrey,
        body: Row(
          children: [
            // ── Navigation Rail ───────────────────────────────────────────
            NavigationRail(
              backgroundColor: AppColors.marcatBlack,
              // withAlpha(51) ≈ 20 % opacity — replaces deprecated withOpacity
              indicatorColor: AppColors.marcatGold.withAlpha(51),
              unselectedIconTheme: const IconThemeData(
                color: AppColors.textDisabled,
                size: AppDimensions.iconL,
              ),
              selectedIconTheme: const IconThemeData(
                color: AppColors.marcatGold,
                size: AppDimensions.iconL,
              ),
              unselectedLabelTextStyle: const TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 12,
                color: AppColors.textDisabled,
              ),
              selectedLabelTextStyle: const TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.marcatGold,
              ),
              extended: extended,
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              leading: _RailLeading(extended: extended),
              destinations: destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),

            const VerticalDivider(
              thickness: 1,
              width: 1,
              color: AppColors.borderMedium,
            ),

            // ── Content ───────────────────────────────────────────────────
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
  final List<_AdminDestination> destinations;
  final List<Widget> pages;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.surfaceGrey,
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          backgroundColor: AppColors.marcatBlack,
          indicatorColor: AppColors.marcatGold.withAlpha(51),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: destinations
              .map((d) => NavigationDestination(
                    icon: Icon(d.icon, color: AppColors.textDisabled),
                    selectedIcon:
                        Icon(d.selectedIcon, color: AppColors.marcatGold),
                    label: d.label,
                  ))
              .toList(),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _RailLeading
// ─────────────────────────────────────────────────────────────────────────────

/// Brand logo header for the extended navigation rail.
class _RailLeading extends StatelessWidget {
  const _RailLeading({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) => extended
      ? Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.space24,
            horizontal: AppDimensions.space16,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.storefront_rounded,
                color: AppColors.marcatGold,
                size: AppDimensions.iconL,
              ),
              const SizedBox(width: AppDimensions.space8),
              Text(
                'MARCAT',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.marcatGold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(width: AppDimensions.space4),
              Text(
                'ADMIN',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.marcatSlate,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        )
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.space24),
          child: const Icon(
            Icons.storefront_rounded,
            color: AppColors.marcatGold,
            size: AppDimensions.iconL,
          ),
        );
}

// ─────────────────────────────────────────────────────────────────────────────
// _AdminDestination  (data class)
// ─────────────────────────────────────────────────────────────────────────────

class _AdminDestination {
  const _AdminDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
