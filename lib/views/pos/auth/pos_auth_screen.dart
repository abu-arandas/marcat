// lib/views/pos/auth/pos_auth_screen.dart
//
// POS PIN authentication screen — staff enter their 4-digit PIN to
// begin a shift on the point-of-sale terminal.
//
// ✅ REFACTORED: uses brand.dart aliases, consistent with admin/customer.
// ✅ REFACTORED: fixed file path in header comment (was presentation/).
// ✅ REFACTORED: clear PIN button uses brand colors.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../shared/brand.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PosAuthScreen
// ─────────────────────────────────────────────────────────────────────────────

class PosAuthScreen extends StatefulWidget {
  const PosAuthScreen({super.key});

  @override
  State<PosAuthScreen> createState() => _PosAuthScreenState();
}

class _PosAuthScreenState extends State<PosAuthScreen> {
  String _pin = '';
  final int _pinLength = 4;

  // ── PIN entry ─────────────────────────────────────────────────────────────

  void _onKeyPress(String digit) {
    if (_pin.length < _pinLength) {
      setState(() => _pin += digit);
      if (_pin.length == _pinLength) _verifyPin();
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _onClear() => setState(() => _pin = '');

  // ── PIN verification ──────────────────────────────────────────────────────

  Future<void> _verifyPin() async {
    final authCtrl = Get.find<AuthController>();
    final authState = authCtrl.state.value;

    if (!authState.isAuthenticated || authState.user == null) {
      if (mounted) {
        SnackbarUtils.showError(context, 'No active terminal session');
        _onClear();
      }
      return;
    }

    if (authState.isSalesperson ||
        authState.isStoreManager ||
        authState.isAdmin) {
      try {
        final isValid = await Get.find<AdminController>()
            .verifyPosPin(staffId: authState.user!.id, pin: _pin);

        if (!mounted) return;

        if (isValid) {
          Get.toNamed(AppRoutes.posTerminal);
        } else {
          SnackbarUtils.showError(context, 'Invalid PIN');
          _onClear();
        }
      } catch (e) {
        if (!mounted) return;
        SnackbarUtils.showError(context, e.toString());
        _onClear();
      }
    } else {
      if (mounted) {
        SnackbarUtils.showError(context, 'Unauthorized for POS access');
        _onClear();
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: kBlack,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(AppDimensions.space48),
          decoration: BoxDecoration(
            color: kSurfaceWhite,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Obx(() {
            final user = authCtrl.state.value.user;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ────────────────────────────────────────────────
                Text(
                  'MARCAT POS',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: kBlack,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  'Enter PIN to start shift\n(${user?.firstName ?? "Staff"})',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: kTextSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.space32),

                // ── PIN Dots ──────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pinLength, (index) {
                    final isActive = index < _pin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isActive ? kBlack : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive ? kBlack : kBorderMedium,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: AppDimensions.space48),

                // ── Numpad ────────────────────────────────────────────────
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    if (index == 9) {
                      return _NumpadKey(label: 'C', onTap: _onClear);
                    }
                    if (index == 11) {
                      return _NumpadKey(
                        icon: Icons.backspace_outlined,
                        onTap: _onDelete,
                      );
                    }
                    final digit = index == 10 ? '0' : '${index + 1}';
                    return _NumpadKey(
                      label: digit,
                      onTap: () => _onKeyPress(digit),
                    );
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

// ─────────────────────────────────────────────────────────────────────────────
// _NumpadKey
// ─────────────────────────────────────────────────────────────────────────────

class _NumpadKey extends StatelessWidget {
  const _NumpadKey({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        child: Container(
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Center(
            child: label != null
                ? Text(label!, style: AppTextStyles.headlineLarge)
                : Icon(icon, size: 28, color: kBlack),
          ),
        ),
      );
}
