// lib/views/admin/scaffold/widgets/bottom_nav.dart
//
// Mobile bottom navigation bar for the admin panel.
//
// Uses the brand navy/black background with gold selected indicators,
// matching the dark aesthetic of the desktop NavigationRail.
//
// ✅ REFACTORED: uses brand.dart aliases — zero raw AppColors references.

import 'package:flutter/material.dart';

import '../../shared/brand.dart';
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
        backgroundColor: kBlack,
        // withAlpha(51) ≈ 20 % opacity
        indicatorColor: kGold.withAlpha(51),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon, color: kTextDisabled),
                selectedIcon: Icon(d.selectedIcon, color: kGold),
                label: d.label,
              ),
            )
            .toList(),
      );
}
