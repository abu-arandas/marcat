// lib/presentation/pos/terminal/pos_terminal_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/extensions/currency_extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:marcat/controllers/auth_controller.dart';
import '../../shared/widgets/marcat_app_bar.dart';

class PosTerminalScreen extends StatefulWidget {
  const PosTerminalScreen({super.key});

  @override
  State<PosTerminalScreen> createState() => _PosTerminalScreenState();
}

class _PosTerminalScreenState extends State<PosTerminalScreen> {
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: MarcatGoldAppBar(
        title: 'POS TERMINAL - STORE 1',
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: AppDimensions.space16),
              child: Obx(() {
                final user = authController.state.value.user;
                return Text(
                  user?.firstName ?? 'Staff',
                  style: AppTextStyles.labelMedium,
                );
              }),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.signOut(),
          ),
        ],
      ),
      body: Row(
        children: [
          // â”€â”€ Left: Cart / Ticket â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Expanded(
            flex: 3,
            child: Container(
              color: AppColors.surfaceWhite,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      children: [
                        _buildCartItem(
                            'Classic Oxford Shirt', 'White â€¢ L', '1', 45.0),
                        const Divider(),
                        _buildCartItem('Chino Pants', 'Navy â€¢ 32', '2', 80.0),
                      ],
                    ),
                  ),
                  _buildTicketTotals(),
                ],
              ),
            ),
          ),
          const VerticalDivider(
              width: 1, thickness: 1, color: AppColors.borderMedium),

          // â”€â”€ Right: Products / Tools â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Expanded(
            flex: 7,
            child: Column(
              children: [
                // Top tools row
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  color: AppColors.surfaceWhite,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search or scan barcode...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.qr_code_scanner),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space16),
                      TextButton.icon(
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('Add Customer'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Product Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: AppDimensions.space16,
                      mainAxisSpacing: AppDimensions.space16,
                    ),
                    itemCount: 12,
                    itemBuilder: (ctx, idx) {
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusS),
                          side: const BorderSide(color: AppColors.borderLight),
                        ),
                        child: InkWell(
                          onTap: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.shimmerBase,
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(
                                            AppDimensions.radiusS)),
                                  ),
                                  child: const Center(
                                      child: Icon(Icons.image_not_supported)),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.all(AppDimensions.space8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Sample Product ${idx + 1}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.labelMedium),
                                    const SizedBox(
                                        height: AppDimensions.space4),
                                    Text(45.0.toJOD(),
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                                fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
      String title, String subtitle, String qty, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceGrey,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(qty, style: AppTextStyles.labelMedium),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(price.toJOD(),
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTicketTotals() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.marcatBlack.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: AppTextStyles.bodyLarge),
              Text(125.0.toJOD(), style: AppTextStyles.bodyLarge),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tax',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
              Text(0.0.toJOD(),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const Divider(height: AppDimensions.space24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.displaySmall),
              Text(125.0.toJOD(), style: AppTextStyles.displaySmall),
            ],
          ),
          const SizedBox(height: AppDimensions.space24),
          // Payment Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.credit_card,
                      color: AppColors.marcatBlack),
                  label: Text('CARD',
                      style: AppTextStyles.buttonPrimary
                          .copyWith(color: AppColors.marcatBlack)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceGrey,
                    minimumSize: const Size.fromHeight(60),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon:
                      const Icon(Icons.payments, color: AppColors.marcatCream),
                  label: Text('CASH',
                      style: AppTextStyles.buttonPrimary
                          .copyWith(color: AppColors.marcatCream)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusGreen,
                    minimumSize: const Size.fromHeight(60),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
