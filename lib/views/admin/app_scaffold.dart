// lib/presentation/admin/app_scaffold.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/extensions/context_extensions.dart';
import 'dashboard/dashboard_screen.dart';
import 'products/product_list_screen.dart';
import 'orders/order_list_screen.dart';
import 'staff/staff_list_screen.dart';
import 'settings/admin_settings_screen.dart';

class AdminAppScaffold extends StatefulWidget {
  const AdminAppScaffold({super.key});

  @override
  State<AdminAppScaffold> createState() => _AdminAppScaffoldState();
}

class _AdminAppScaffoldState extends State<AdminAppScaffold> {
  int currentIndex = 0;

  final pages = [
    const AdminDashboardScreen(),
    const AdminProductListScreen(),
    const AdminOrderListScreen(),
    const AdminStaffListScreen(),
    const AdminSettingsScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterBootstrap5(
      builder: (context) {
        final breakPoint = BootstrapTheme.of(context).currentBreakPoint;
        final breakPoints = BootstrapTheme.of(context).breakPoints;
        final isDesktop = breakPoint.isBreakPointOrLarger(breakPoints.lg);
        final isTablet = breakPoint == breakPoints.md;

        if (isDesktop || isTablet) {
          return Scaffold(
            backgroundColor: AppColors.surfaceGrey,
            body: Row(
              children: [
                NavigationRail(
                  backgroundColor: AppColors.marcatBlack,
                  indicatorColor: AppColors.marcatGold.withOpacity(0.2),
                  unselectedIconTheme:
                      const IconThemeData(color: AppColors.textDisabled),
                  selectedIconTheme:
                      const IconThemeData(color: AppColors.marcatGold),
                  unselectedLabelTextStyle:
                      const TextStyle(color: AppColors.textDisabled),
                  selectedLabelTextStyle:
                      const TextStyle(color: AppColors.marcatGold),
                  extended: isDesktop,
                  selectedIndex: currentIndex,
                  onDestinationSelected: _onTap,
                  leading: isDesktop
                      ? const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.space24),
                          child: Text(
                            'MARCAT ADMIN',
                            style: TextStyle(
                              color: AppColors.marcatGold,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        )
                      : const SizedBox(height: AppDimensions.space24),
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.dashboard_outlined),
                      selectedIcon: const Icon(Icons.dashboard),
                      label: Text(context.l10n.adminDashboard),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.inventory_2_outlined),
                      selectedIcon: const Icon(Icons.inventory_2),
                      label: Text(context.l10n.adminProducts),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.receipt_long_outlined),
                      selectedIcon: const Icon(Icons.receipt_long),
                      label: Text(context.l10n.adminOrders),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.group_outlined),
                      selectedIcon: Icon(Icons.group),
                      label: Text('Staff'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                ),
                const VerticalDivider(
                    thickness: 1, width: 1, color: AppColors.borderMedium),
                Expanded(
                  child: FB5Container(
                    child: IndexedStack(
                      index: currentIndex,
                      children: pages,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.surfaceGrey,
          body: FB5Container(
            child: IndexedStack(
              index: currentIndex,
              children: pages,
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: _onTap,
            backgroundColor: AppColors.marcatCream,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: context.l10n.adminDashboard,
              ),
              NavigationDestination(
                icon: const Icon(Icons.inventory_2_outlined),
                selectedIcon: const Icon(Icons.inventory_2),
                label: context.l10n.adminProducts,
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: const Icon(Icons.receipt_long),
                label: context.l10n.adminOrders,
              ),
              const NavigationDestination(
                icon: Icon(Icons.group_outlined),
                selectedIcon: Icon(Icons.group),
                label: 'Staff',
              ),
              const NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
