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
import 'shared/empty_state.dart';
import 'shared/marcat_buttons.dart';
import 'shared/section_header.dart';

// ── Local colour aliases (always reference AppColors) ─────────────────────────
const _kNavy = AppColors.marcatNavy;
const _kGold = AppColors.marcatGold;
const _kCream = AppColors.marcatCream;
const _kSlate = AppColors.marcatSlate;
const _kRed = AppColors.saleRed;
const _kBorder = AppColors.borderLight;

// ─────────────────────────────────────────────────────────────────────────────
// ProfilePage
// ─────────────────────────────────────────────────────────────────────────────

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ── Controllers ───────────────────────────────────────────────────────────
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _pwFormKey = GlobalKey<FormState>();

  // ── State ─────────────────────────────────────────────────────────────────
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
    if (!_formKey.currentState!.validate()) return;
    final user = _auth.state.value.user;
    if (user == null) return;
    setState(() => _isSaving = true);
    try {
      await _accountCtrl.updateUserProfile(user.id, {
        'first_name': _firstNameCtrl.text.trim(),
        'last_name': _lastNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      });
      Get.snackbar(
        'Saved',
        'Your profile has been updated.',
        backgroundColor: AppColors.marcatNavy,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.errorRed, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_pwFormKey.currentState!.validate()) return;
    if (_newPwCtrl.text != _confirmPwCtrl.text) {
      Get.snackbar('Error', 'Passwords do not match.',
          backgroundColor: AppColors.errorRed, colorText: Colors.white);
      return;
    }
    setState(() => _isChangingPw = true);
    try {
      await _auth.updatePassword(_newPwCtrl.text);
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();
      Get.snackbar('Success', 'Password updated successfully.',
          backgroundColor: AppColors.marcatNavy, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.errorRed, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isChangingPw = false);
    }
  }

  Future<void> _uploadAvatar() async {
    final picker = ImagePicker();
    final file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    final user = _auth.state.value.user;
    if (user == null) return;
    try {
      final bytes = await file.readAsBytes();
      await _accountCtrl.uploadAvatar(user.id, bytes);
      Get.snackbar('Success', 'Avatar updated.',
          backgroundColor: AppColors.marcatNavy, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _loadLoyalty() async {
    final user = _auth.state.value.user;
    if (user == null) return;
    setState(() => _loyaltyLoading = true);
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
  Widget build(BuildContext context) => CustomerScaffold(
        page: 'My Profile',
        pageImage:
            'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=1600&q=80',
        body: GetBuilder<AuthController>(
          builder: (auth) {
            final user = auth.state.value.user;

            if (user == null) {
              return EmptyState(
                icon: Icons.person_off_outlined,
                title: 'Not Signed In',
                subtitle: 'Please sign in to view your profile.',
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
                            width: 260,
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
                          const SizedBox(width: 48),
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
          },
        ),
      );
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
      '${user.firstName.isNotEmpty ? user.firstName[0] : ''}'
              '${user.lastName.isNotEmpty ? user.lastName[0] : ''}'
          .toUpperCase();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // ── Avatar ───────────────────────────────────────────────────────
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kNavy,
                  border: Border.all(color: _kGold.withOpacity(0.4), width: 3),
                  image: user.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(user.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user.avatarUrl == null
                    ? Center(
                        child: Text(
                          _initials,
                          style: const TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              GestureDetector(
                onTap: onUploadAvatar,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: _kGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${user.firstName} ${user.lastName}',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            user.phone ?? '',
            style: const TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 13,
              color: _kSlate,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // ── Navigation tabs ──────────────────────────────────────────────
          _SidebarTab(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
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
          const SizedBox(height: 12),
          const Divider(color: _kBorder),
          const SizedBox(height: 12),

          // ── Sign out ────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Get.find<AuthController>().signOut();
                Get.offAllNamed(AppRoutes.home);
              },
              icon: const Icon(Icons.logout_rounded, size: 16),
              label: const Text(
                'Sign Out',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kRed,
                side: const BorderSide(color: _kRed),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _SidebarTab
// ─────────────────────────────────────────────────────────────────────────────

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
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: active ? _kNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: active ? Colors.white : _kSlate),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? Colors.white : _kSlate,
                ),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProfileContent  — routes to the correct tab widget
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
  Widget build(BuildContext context) {
    return switch (activeTab) {
      1 => _PasswordTab(
          pwFormKey: pwFormKey,
          newPwCtrl: newPwCtrl,
          confirmPwCtrl: confirmPwCtrl,
          isChangingPw: isChangingPw,
          onChangePassword: onChangePassword,
        ),
      2 => _LoyaltyTab(
          loyaltyTransactions: loyaltyTransactions,
          loyaltyLoading: loyaltyLoading,
          user: user,
        ),
      _ => _InfoTab(
          formKey: formKey,
          firstNameCtrl: firstNameCtrl,
          lastNameCtrl: lastNameCtrl,
          phoneCtrl: phoneCtrl,
          isSaving: isSaving,
          onSaveProfile: onSaveProfile,
        ),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _InfoTab
// ─────────────────────────────────────────────────────────────────────────────

class _InfoTab extends StatelessWidget {
  const _InfoTab({
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.phoneCtrl,
    required this.isSaving,
    required this.onSaveProfile,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController phoneCtrl;
  final bool isSaving;
  final VoidCallback onSaveProfile;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Account',
            title: 'Personal Info',
            subtitle: 'Update your name and contact details.',
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ProfileField(
                          controller: firstNameCtrl,
                          label: 'First Name',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ProfileField(
                          controller: lastNameCtrl,
                          label: 'Last Name',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ProfileField(
                    controller: phoneCtrl,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Save Changes',
                    loading: isSaving,
                    onPressed: onSaveProfile,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _PasswordTab
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordTab extends StatelessWidget {
  const _PasswordTab({
    required this.pwFormKey,
    required this.newPwCtrl,
    required this.confirmPwCtrl,
    required this.isChangingPw,
    required this.onChangePassword,
  });

  final GlobalKey<FormState> pwFormKey;
  final TextEditingController newPwCtrl;
  final TextEditingController confirmPwCtrl;
  final bool isChangingPw;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Security',
            title: 'Change Password',
            subtitle: 'Keep your account secure with a strong password.',
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: Form(
              key: pwFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileField(
                    controller: newPwCtrl,
                    label: 'New Password',
                    obscureText: true,
                    validator: (v) => (v == null || v.length < 8)
                        ? 'At least 8 characters required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _ProfileField(
                    controller: confirmPwCtrl,
                    label: 'Confirm Password',
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Update Password',
                    loading: isChangingPw,
                    onPressed: onChangePassword,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _LoyaltyTab
// ─────────────────────────────────────────────────────────────────────────────

class _LoyaltyTab extends StatelessWidget {
  const _LoyaltyTab({
    required this.loyaltyTransactions,
    required this.loyaltyLoading,
    required this.user,
  });

  final List<LoyaltyTransactionModel> loyaltyTransactions;
  final bool loyaltyLoading;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final customer = auth.state.value.customer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          eyebrow: 'Rewards',
          title: 'Loyalty Points',
          subtitle: 'Earn points with every purchase.',
        ),
        const SizedBox(height: 24),

        // ── Points balance card ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _kNavy,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.stars_rounded, color: _kGold, size: 36),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${customer?.loyaltyPoints ?? 0} pts',
                    style: const TextStyle(
                      fontFamily: 'IBMPlexMono',
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    customer?.loyaltyTier.dbValue.toUpperCase() ?? 'BRONZE',
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      color: _kGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Transaction history ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transaction History', style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),
              const Divider(color: _kBorder),
              if (loyaltyLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _kGold),
                  ),
                )
              else if (loyaltyTransactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No transactions yet.',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        color: _kSlate,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: loyaltyTransactions.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: _kBorder, height: 1),
                  itemBuilder: (_, i) =>
                      _LoyaltyRow(tx: loyaltyTransactions[i]),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoyaltyRow extends StatelessWidget {
  const _LoyaltyRow({required this.tx});

  final LoyaltyTransactionModel tx;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              tx.points > 0
                  ? Icons.add_circle_outline_rounded
                  : Icons.remove_circle_outline_rounded,
              size: 18,
              color: tx.points > 0 ? AppColors.successGreen : AppColors.saleRed,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description ?? 'Points transaction',
                    style: AppTextStyles.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatDate(tx.createdAt),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              '${tx.points > 0 ? '+' : ''}${tx.points} pts',
              style: AppTextStyles.priceSmall.copyWith(
                color:
                    tx.points > 0 ? AppColors.successGreen : AppColors.saleRed,
              ),
            ),
          ],
        ),
      );

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProfileField  (shared text form field)
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 14,
          color: _kNavy,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 13,
            color: _kSlate,
          ),
          filled: true,
          fillColor: _kCream,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kNavy, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kRed),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
