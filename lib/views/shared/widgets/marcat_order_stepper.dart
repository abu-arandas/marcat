// lib/presentation/shared/widgets/marcat_order_stepper.dart

import 'package:flutter/material.dart';
import 'package:marcat/models/enums.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';

class MarcatOrderStepper extends StatelessWidget {
  const MarcatOrderStepper({
    super.key,
    required this.status,
    this.deliveryStatus,
  });

  final SaleStatus status;
  final DeliveryStatus? deliveryStatus;

  @override
  Widget build(BuildContext context) {
    if (status == SaleStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: AppColors.statusRedLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel, color: AppColors.statusRed),
            const SizedBox(width: AppDimensions.space8),
            Text(
              context.l10n.statusCancelled,
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.statusRed),
            ),
          ],
        ),
      );
    }

    // Define steps based on status progression
    final int currentStep = switch (status) {
      SaleStatus.pending => 0,
      SaleStatus.paid => 1,
      SaleStatus.shipped => 2,
      SaleStatus.delivered => 3,
      SaleStatus.cancelled => -1,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStep(
          context,
          title: context.l10n.saleConfirmed,
          isActive: currentStep >= 1,
          isFirst: true,
        ),
        _buildStep(
          context,
          title: context.l10n.saleProcessing,
          isActive: currentStep >= 2,
        ),
        _buildStep(
          context,
          title: context.l10n.saleShipped,
          isActive: currentStep >= 3,
        ),
        _buildStep(
          context,
          title: context.l10n.saleDelivered,
          isActive: currentStep >= 4,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String title,
    required bool isActive,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 20,
                    color:
                        isActive ? AppColors.marcatGold : AppColors.borderLight,
                  ),
                Container(
                  width: 16,
                  height: 16,
                  margin: EdgeInsets.only(
                      top: isFirst ? 4 : 0, bottom: isLast ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.marcatGold
                        : AppColors.surfaceWhite,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? AppColors.marcatGold
                          : AppColors.borderMedium,
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isActive
                          ? AppColors.marcatGold
                          : AppColors.borderLight,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          Padding(
            padding:
                const EdgeInsets.only(top: 2, bottom: AppDimensions.space24),
            child: Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                color:
                    isActive ? AppColors.textPrimary : AppColors.textDisabled,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
