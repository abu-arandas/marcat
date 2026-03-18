// lib/views/customer/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:marcat/controllers/account_controller.dart';
import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/core/constants/app_text_styles.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/models/enums.dart';
import 'package:marcat/models/loyalty_transaction_model.dart';
import 'package:marcat/models/user_model.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart'; // ✅ single source of colour constants
import 'shared/empty_state.dart';
import 'shared/buttons.dart';
import 'shared/section_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProfilePage
// ─────────────────────────────────────────────────────────────────────────────

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ── Text controllers ───────────────────────────────────────────────────────
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _pwFormKey = GlobalKey<FormState>();

  // ── UI state ──────────────────────────────────────────────────────────────
  int _activeTab = 0;
  bool _isSaving = false;
  bool _isChangingPw = false;
  final _loyaltyTransactions = <LoyaltyTransactionModel>[];
  bool _loyaltyLoading = false;

  AccountController get _accountCtrl => Get.find<AccountController>();
  AuthController get _auth => Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _auth.state.value.user;
    if (user == null) return;
    try {
      await _accountCtrl.loadProfile(user.id);
      final profile = _accountCtrl.profile.value;
      if (profile != null && mounted) {
        _firstNameCtrl.text = profile.firstName;
        _lastNameCtrl.text = profile.lastName;
        _phoneCtrl.text = profile.phone ?? '';
      }
    } catch (_) {}
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (mounted) setState(() => _isSaving = true);
    try {
      final user = _auth.state.value.user;
      if (user == null) return;
      await _accountCtrl.updateUserProfile(
        user.id,
        {
          'first_name': _firstNameCtrl.text.trim(),
          'last_name': _lastNameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        },
      );
      if (mounted) {
        Get.snackbar(
          'Profile Updated',
          'Your profile has been saved.',
          backgroundColor: AppColors.successGreen,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', e.toString(),
            backgroundColor: AppColors.errorRed, colorText: Colors.white);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    if (!(_pwFormKey.currentState?.validate() ?? false)) return;
    if (_newPwCtrl.text != _confirmPwCtrl.text) {
      Get.snackbar('Mismatch', 'Passwords do not match.',
          backgroundColor: AppColors.errorRed, colorText: Colors.white);
      return;
    }
    if (mounted) setState(() => _isChangingPw = true);
    try {
      await _auth.updatePassword(_newPwCtrl.text);
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();
      if (mounted) {
        Get.snackbar(
          'Password Updated',
          'Your password has been changed.',
          backgroundColor: AppColors.successGreen,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', e.toString(),
            backgroundColor: AppColors.errorRed, colorText: Colors.white);
      }
    } finally {
      if (mounted) setState(() => _isChangingPw = false);
    }
  }

  Future<void> _uploadAvatar() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;
    final user = _auth.state.value.user;
    if (user == null) return;
    try {
      final bytes = await xFile.readAsBytes();
      await _accountCtrl.uploadAvatar(user.id, bytes);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', e.toString(),
            backgroundColor: AppColors.errorRed, colorText: Colors.white);
      }
    }
  }

  Future<void> _loadLoyalty() async {
    final user = _auth.state.value.user;
    if (user == null) return;
    if (mounted) setState(() => _loyaltyLoading = true);
    try {
      await _accountCtrl.fetchLoyaltyTransactions(customerId: user.id);
      if (mounted) {
        setState(() {
          _loyaltyTransactions
            ..clear()
            ..addAll(_accountCtrl.loyaltyTransactions);
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loyaltyLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomerScaffold(
      page: 'My Profile',
      body: Obx(() {
        final user = _auth.state.value.user;
        if (user == null) {
          return EmptyState(
            icon: Icons.person_outline,
            title: 'Not Signed In',
            actionLabel: 'Sign In',
            onAction: () => Get.toNamed(AppRoutes.login),
          );
        }

        final isDesktop = MediaQuery.sizeOf(context).width > 900;

        return FB5Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 280,
                        child: _ProfileSidebar(
                          user: user,
                          activeTab: _activeTab,
                          onTabChanged: (i) {
                            setState(() => _activeTab = i);
                            if (i == 2) _loadLoyalty();
                          },
                          onUploadAvatar: _uploadAvatar,
                        ),
                      ),
                      const SizedBox(width: 40),
                      Expanded(
                        child: _ProfileContent(
                          user: user,
                          activeTab: _activeTab,
                          isSaving: _isSaving,
                          isChangingPw: _isChangingPw,
                          loyaltyTransactions: _loyaltyTransactions,
                          loyaltyLoading: _loyaltyLoading,
                          firstNameCtrl: _firstNameCtrl,
                          lastNameCtrl: _lastNameCtrl,
                          phoneCtrl: _phoneCtrl,
                          formKey: _formKey,
                          newPwCtrl: _newPwCtrl,
                          confirmPwCtrl: _confirmPwCtrl,
                          pwFormKey: _pwFormKey,
                          onSaveProfile: _saveProfile,
                          onChangePassword: _changePassword,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _ProfileSidebar(
                        user: user,
                        activeTab: _activeTab,
                        onTabChanged: (i) {
                          setState(() => _activeTab = i);
                          if (i == 2) _loadLoyalty();
                        },
                        onUploadAvatar: _uploadAvatar,
                      ),
                      const SizedBox(height: 32),
                      _ProfileContent(
                        user: user,
                        activeTab: _activeTab,
                        isSaving: _isSaving,
                        isChangingPw: _isChangingPw,
                        loyaltyTransactions: _loyaltyTransactions,
                        loyaltyLoading: _loyaltyLoading,
                        firstNameCtrl: _firstNameCtrl,
                        lastNameCtrl: _lastNameCtrl,
                        phoneCtrl: _phoneCtrl,
                        formKey: _formKey,
                        newPwCtrl: _newPwCtrl,
                        confirmPwCtrl: _confirmPwCtrl,
                        pwFormKey: _pwFormKey,
                        onSaveProfile: _saveProfile,
                        onChangePassword: _changePassword,
                      ),
                    ],
                  ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProfileSidebar
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileSidebar extends StatelessWidget {
  const _ProfileSidebar({
    required this.user,
    required this.activeTab,
    required this.onTabChanged,
    required this.onUploadAvatar,
  });

  final UserModel user;
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onUploadAvatar;

  String get _initials =>
      '${user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : ''}'
      '${user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : ''}';

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          children: [
            // ── Avatar ────────────────────────────────────────────────────
            GestureDetector(
              onTap: onUploadAvatar,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: kGold.withAlpha(51),
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            _initials.isNotEmpty ? _initials : 'U',
                            style: const TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: kGold,
                            ),
                          )
                        : null,
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: kNavy,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Name & role ───────────────────────────────────────────────
            Text(
              user.fullName,
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Obx(() {
              final customer = Get.find<AccountController>().customer.value;
              return customer != null
                  ? _LoyaltyBadge(tier: customer.loyaltyTier)
                  : const SizedBox.shrink();
            }),

            const SizedBox(height: 24),
            const Divider(color: kBorder),
            const SizedBox(height: 12),

            // ── Tab navigation ────────────────────────────────────────────
            _SidebarTab(
              icon: Icons.person_outline_rounded,
              label: 'Personal Info',
              active: activeTab == 0,
              onTap: () => onTabChanged(0),
            ),
            _SidebarTab(
              icon: Icons.lock_outline_rounded,
              label: 'Password',
              active: activeTab == 1,
              onTap: () => onTabChanged(1),
            ),
            _SidebarTab(
              icon: Icons.stars_rounded,
              label: 'Loyalty Points',
              active: activeTab == 2,
              onTap: () => onTabChanged(2),
            ),
            _SidebarTab(
              icon: Icons.receipt_long_outlined,
              label: 'My Orders',
              active: false,
              onTap: () => Get.toNamed(AppRoutes.orders),
            ),

            const SizedBox(height: 12),
            const Divider(color: kBorder),
            const SizedBox(height: 12),

            // ── Sign out ──────────────────────────────────────────────────
            GestureDetector(
              onTap: () => Get.find<AuthController>().signOut(),
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded, size: 18, color: kSlate),
                  const SizedBox(width: 10),
                  Text(
                    'Sign Out',
                    style: AppTextStyles.bodyMedium.copyWith(color: kSlate),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _SidebarTab extends StatelessWidget {
  const _SidebarTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active ? kNavy.withAlpha(13) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? kNavy : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: active ? kNavy : kSlate),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? kNavy : kSlate,
                ),
              ),
            ],
          ),
        ),
      );
}

class _LoyaltyBadge extends StatelessWidget {
  const _LoyaltyBadge({required this.tier});

  final LoyaltyTier tier;

  Color get _color => switch (tier) {
        LoyaltyTier.bronze => const Color(0xFFCD7F32),
        LoyaltyTier.silver => const Color(0xFF9E9E9E),
        LoyaltyTier.gold => AppColors.marcatGold,
        LoyaltyTier.platinum => const Color(0xFF6A5ACD),
      };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: _color.withAlpha(26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _color.withAlpha(77)),
        ),
        child: Text(
          tier.displayLabel.toUpperCase(),
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: _color,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProfileContent — tab body
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.user,
    required this.activeTab,
    required this.isSaving,
    required this.isChangingPw,
    required this.loyaltyTransactions,
    required this.loyaltyLoading,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.phoneCtrl,
    required this.formKey,
    required this.newPwCtrl,
    required this.confirmPwCtrl,
    required this.pwFormKey,
    required this.onSaveProfile,
    required this.onChangePassword,
  });

  final UserModel user;
  final int activeTab;
  final bool isSaving;
  final bool isChangingPw;
  final List<LoyaltyTransactionModel> loyaltyTransactions;
  final bool loyaltyLoading;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController phoneCtrl;
  final GlobalKey<FormState> formKey;
  final TextEditingController newPwCtrl;
  final TextEditingController confirmPwCtrl;
  final GlobalKey<FormState> pwFormKey;
  final VoidCallback onSaveProfile;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) => switch (activeTab) {
        1 => _PasswordTab(
            newPwCtrl: newPwCtrl,
            confirmPwCtrl: confirmPwCtrl,
            pwFormKey: pwFormKey,
            isChangingPw: isChangingPw,
            onChangePassword: onChangePassword,
          ),
        2 => _LoyaltyTab(
            user: user,
            transactions: loyaltyTransactions,
            isLoading: loyaltyLoading,
          ),
        _ => _PersonalInfoTab(
            firstNameCtrl: firstNameCtrl,
            lastNameCtrl: lastNameCtrl,
            phoneCtrl: phoneCtrl,
            formKey: formKey,
            isSaving: isSaving,
            onSave: onSaveProfile,
          ),
      };
}

// ── Personal Info ─────────────────────────────────────────────────────────────

class _PersonalInfoTab extends StatelessWidget {
  const _PersonalInfoTab({
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.phoneCtrl,
    required this.formKey,
    required this.isSaving,
    required this.onSave,
  });

  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController phoneCtrl;
  final GlobalKey<FormState> formKey;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                eyebrow: 'Account',
                title: 'Personal Info',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _ProfileField(
                      controller: firstNameCtrl,
                      label: 'First Name',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ProfileField(
                      controller: lastNameCtrl,
                      label: 'Last Name',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ProfileField(
                controller: phoneCtrl,
                label: 'Phone (optional)',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Save Changes',
                onPressed: onSave,
                loading: isSaving,
                icon: Icons.check_rounded,
              ),
            ],
          ),
        ),
      );
}

// ── Password ──────────────────────────────────────────────────────────────────

class _PasswordTab extends StatelessWidget {
  const _PasswordTab({
    required this.newPwCtrl,
    required this.confirmPwCtrl,
    required this.pwFormKey,
    required this.isChangingPw,
    required this.onChangePassword,
  });

  final TextEditingController newPwCtrl;
  final TextEditingController confirmPwCtrl;
  final GlobalKey<FormState> pwFormKey;
  final bool isChangingPw;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: Form(
          key: pwFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                eyebrow: 'Security',
                title: 'Change Password',
              ),
              const SizedBox(height: 24),
              _ProfileField(
                controller: newPwCtrl,
                label: 'New Password',
                obscureText: true,
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
              ),
              const SizedBox(height: 16),
              _ProfileField(
                controller: confirmPwCtrl,
                label: 'Confirm Password',
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Update Password',
                onPressed: onChangePassword,
                loading: isChangingPw,
                icon: Icons.lock_outline_rounded,
              ),
            ],
          ),
        ),
      );
}

// ── Loyalty ───────────────────────────────────────────────────────────────────

class _LoyaltyTab extends StatelessWidget {
  const _LoyaltyTab({
    required this.user,
    required this.transactions,
    required this.isLoading,
  });

  final UserModel user;
  final List<LoyaltyTransactionModel> transactions;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              eyebrow: 'Rewards',
              title: 'Loyalty Points',
            ),
            const SizedBox(height: 24),

            // ── Points summary ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.loyaltyBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.marcatGold.withAlpha(77),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    color: AppColors.marcatGold,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Obx(() {
                    final customer = Get.find<AccountController>().customer.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${customer?.loyaltyPoints ?? 0} pts',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.marcatGold,
                          ),
                        ),
                        Text(
                          customer?.loyaltyTier.displayLabel ?? '',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: kSlate,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Transaction history ────────────────────────────────────────
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.marcatGold,
                ),
              )
            else if (transactions.isEmpty)
              const EmptyState(
                icon: Icons.history_rounded,
                title: 'No Transactions Yet',
                subtitle: 'Complete orders to earn loyalty points.',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: kBorder, height: 1),
                itemBuilder: (_, i) => _LoyaltyTile(tx: transactions[i]),
              ),
          ],
        ),
      );
}

class _LoyaltyTile extends StatelessWidget {
  const _LoyaltyTile({required this.tx});

  final LoyaltyTransactionModel tx;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: tx.points > 0
                ? AppColors.successGreenLight
                : AppColors.statusRedLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            tx.points > 0 ? Icons.add_rounded : Icons.remove_rounded,
            size: 18,
            color: tx.points > 0 ? AppColors.statusGreen : AppColors.statusRed,
          ),
        ),
        title: Text(tx.description ?? '', style: AppTextStyles.bodyMedium),
        trailing: Text(
          '${tx.points > 0 ? '+' : ''}${tx.points} pts',
          style: AppTextStyles.titleSmall.copyWith(
            color: tx.points > 0 ? AppColors.statusGreen : AppColors.statusRed,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProfileField — shared form input
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 14,
          color: kNavy,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 13,
            color: kSlate,
          ),
          filled: true,
          fillColor: kCream,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kNavy, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.errorRed),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      );
}
