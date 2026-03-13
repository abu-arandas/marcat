// lib/presentation/shared/widgets/marcat_app_bar.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

class MarcatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MarcatAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 0,
    this.bottom,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: AppTextStyles.appBarTitle),
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.marcatCream,
      elevation: elevation,
      scrolledUnderElevation: 2,
      shadowColor: AppColors.borderLight,
      surfaceTintColor: Colors.transparent,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      AppDimensions.appBarHeight + (bottom?.preferredSize.height ?? 0));
}

/// AppBar with a gold bottom border accent.
class MarcatGoldAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MarcatGoldAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: AppTextStyles.appBarTitle),
      leading: leading,
      actions: actions,
      centerTitle: true,
      backgroundColor: AppColors.marcatBlack,
      foregroundColor: AppColors.marcatCream,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(height: 2, color: AppColors.marcatGold),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(AppDimensions.appBarHeight + 2);
}
