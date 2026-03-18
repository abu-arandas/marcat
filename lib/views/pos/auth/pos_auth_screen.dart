// lib/presentation/pos/auth/pos_auth_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/snackbar_utils.dart';
import 'package:marcat/controllers/admin_controller.dart';
import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/core/router/app_router.dart';

class PosAuthScreen extends StatefulWidget {
  const PosAuthScreen({super.key});

  @override
  State<PosAuthScreen> createState() => _PosAuthScreenState();
}

class _PosAuthScreenState extends State<PosAuthScreen> {
  String _pin = '';
  final int _pinLength = 4; // Simplified PIN length for demo

  void _onKeyPress(String digit) {
    if (_pin.length < _pinLength) {
      setState(() => _pin += digit);
      if (_pin.length == _pinLength) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  Future<void> _verifyPin() async {
    final authController = Get.find<AuthController>();
    final authState = authController.state.value;

    if (!authState.isAuthenticated || authState.user == null) {
      SnackbarUtils.showError(context, 'No active terminal session');
      setState(() => _pin = '');
      return;
    }

    if (authState.isSalesperson ||
        authState.isStoreManager ||
        authState.isAdmin) {
      try {
        final isValid = await Get.find<AdminController>()
            .verifyPosPin(staffId: authState.user!.id, pin: _pin);

        if (isValid) {
          if (mounted) {
            Get.toNamed(AppRoutes.posTerminal); // Was: '/app/pos/home'
          }
        } else {
          if (!mounted) return;
          SnackbarUtils.showError(context, 'Invalid PIN');
          setState(() => _pin = '');
        }
      } catch (e) {
        if (!mounted) return;
        SnackbarUtils.showError(context, e.toString());
        setState(() => _pin = '');
      }
    } else {
      SnackbarUtils.showError(context, 'Unauthorized for POS access');
      setState(() => _pin = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.marcatBlack,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(AppDimensions.space48),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Obx(() {
            final user = authController.state.value.user;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MARCAT POS',
                  style: AppTextStyles.displayMedium
                      .copyWith(color: AppColors.marcatBlack, letterSpacing: 4),
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  'Enter PIN to start shift\n(${user?.firstName ?? "Staff"})',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimensions.space32),

                // PIN Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pinLength, (index) {
                    final isActive = index < _pin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.marcatBlack
                            : AppColors.borderMedium,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: AppDimensions.space48),

                // Numpad
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 12, // 1-9, C, 0, Del
                  itemBuilder: (context, index) {
                    if (index == 9) {
                      return _NumpadKey(
                          label: 'C', onTap: () => setState(() => _pin = ''));
                    }
                    if (index == 11) {
                      return _NumpadKey(
                          icon: Icons.backspace_outlined, onTap: _onDelete);
                    }
                    final digit = index == 10 ? '0' : '${index + 1}';
                    return _NumpadKey(
                        label: digit, onTap: () => _onKeyPress(digit));
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _NumpadKey extends StatelessWidget {
  const _NumpadKey({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Center(
          child: label != null
              ? Text(label!, style: AppTextStyles.headlineLarge)
              : Icon(icon, size: 28, color: AppColors.marcatBlack),
        ),
      ),
    );
  }
}
