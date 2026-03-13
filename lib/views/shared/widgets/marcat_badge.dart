// lib/presentation/shared/widgets/marcat_badge.dart

import 'package:flutter/material.dart';
import 'package:marcat/models/enums.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

class MarcatStatusBadge extends StatelessWidget {
  const MarcatStatusBadge(
      {super.key,
      required this.label,
      required this.color,
      required this.textColor});

  final String label;
  final Color color;
  final Color textColor;

  factory MarcatStatusBadge.forSaleStatus(
      SaleStatus status, BuildContext context) {
    final (color, textColor) = switch (status) {
      SaleStatus.pending => (AppColors.statusAmberLight, AppColors.statusAmber),
      SaleStatus.paid => (AppColors.statusBlueLight, AppColors.statusBlue),
      SaleStatus.shipped => (AppColors.statusBlueLight, AppColors.statusBlue),
      SaleStatus.delivered => (
          AppColors.statusGreenLight,
          AppColors.statusGreen
        ),
      SaleStatus.cancelled => (AppColors.statusRedLight, AppColors.statusRed),
    };
    return MarcatStatusBadge(
        label: status.name.toUpperCase(), color: color, textColor: textColor);
  }

  factory MarcatStatusBadge.forDeliveryStatus(DeliveryStatus status) {
    final (color, textColor) = switch (status) {
      DeliveryStatus.pending => (
          AppColors.statusAmberLight,
          AppColors.statusAmber
        ),
      DeliveryStatus.out_for_delivery => (
          AppColors.statusBlueLight,
          AppColors.statusBlue
        ),
      DeliveryStatus.delivered => (
          AppColors.statusGreenLight,
          AppColors.statusGreen
        ),
      DeliveryStatus.failed => (AppColors.statusRedLight, AppColors.statusRed),
    };
    return MarcatStatusBadge(
        label: status.dbValue.toUpperCase(),
        color: color,
        textColor: textColor);
  }

  factory MarcatStatusBadge.custom(
      {required String label, required Color color}) {
    return MarcatStatusBadge(
      label: label,
      color: color.withOpacity(0.15),
      textColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space8,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}
