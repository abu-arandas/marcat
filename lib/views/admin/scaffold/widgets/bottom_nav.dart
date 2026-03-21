// lib/views/admin/scaffold/widgets/bottom_nav.dart
//
// Mobile bottom navigation bar for the admin panel.
//
// Uses the brand navy/black background with gold selected indicators,
// matching the dark aesthetic of the desktop NavigationRail.

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../app_scaffold.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminBottomNav
// ─────────────────────────────────────────────────────────────────────────────

/// Bottom navigation bar for mobile admin layouts.
class AdminBottomNav extends StatelessWidget {
  const AdminBottomNav({
    super.key,
    required this.currentIndex,
    required this.destinations,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final List<AdminDestination> destinations;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: AppColors.marcatBlack,
        // withAlpha(51) ≈ 20 % opacity
        indicatorColor: AppColors.marcatGold.withAlpha(51),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon, color: AppColors.textDisabled),
                selectedIcon:
                    Icon(d.selectedIcon, color: AppColors.marcatGold),
                label: d.label,
              ),
            )
            .toList(),
      );
}
