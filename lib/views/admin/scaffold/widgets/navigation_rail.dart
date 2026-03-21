// lib/views/admin/scaffold/widgets/navigation_rail.dart
//
// Desktop / tablet side navigation for the admin panel.
//
// Uses the brand navy background with gold accents, matching the dark
// drawer treatment on the customer side.
//
// ✅ REFACTORED: uses brand.dart aliases — zero raw AppColors references.

import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../shared/brand.dart';
import '../app_scaffold.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminNavigationRail
// ─────────────────────────────────────────────────────────────────────────────

/// Side navigation rail for desktop and tablet admin layouts.
///
/// Shows the brand logo at the top, then the five destination icons
/// with gold accent when selected. Extended mode shows labels.
class AdminNavigationRail extends StatelessWidget {
  const AdminNavigationRail({
    super.key,
    required this.currentIndex,
    required this.destinations,
    required this.extended,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final List<AdminDestination> destinations;
  final bool extended;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) => NavigationRail(
        backgroundColor: kBlack,
        // withAlpha(51) ≈ 20 % opacity — replaces deprecated withOpacity
        indicatorColor: kGold.withAlpha(51),
        unselectedIconTheme: const IconThemeData(
          color: kTextDisabled,
          size: AppDimensions.iconL,
        ),
        selectedIconTheme: const IconThemeData(
          color: kGold,
          size: AppDimensions.iconL,
        ),
        unselectedLabelTextStyle: AppTextStyles.labelSmall.copyWith(
          color: kTextDisabled,
        ),
        selectedLabelTextStyle: AppTextStyles.labelSmall.copyWith(
          color: kGold,
          fontWeight: FontWeight.w700,
        ),
        extended: extended,
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        leading: _RailLeading(extended: extended),
        destinations: destinations
            .map(
              (d) => NavigationRailDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: Text(d.label),
              ),
            )
            .toList(),
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
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space24,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kGold,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: const Center(
                  child: Text(
                    'M',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: kBlack,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MARCAT',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: kCream,
                      letterSpacing: 3,
                    ),
                  ),
                  Text(
                    'Admin Panel',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: kTextDisabled,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      : Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.space24,
          ),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kGold,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: kBlack,
                ),
              ),
            ),
          ),
        );
}
