// lib/views/customer/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:marcat/controllers/account_controller.dart';
import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/core/constants/app_text_styles.dart';
import 'package:marcat/core/extensions/date_extensions.dart';
import 'package:marcat/core/router/app_router.dart';
import 'package:marcat/models/loyalty_transaction_model.dart';
import 'package:marcat/models/user_model.dart';

import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/buttons.dart';
import 'shared/empty_state.dart';
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

  // ── Lifecycle ─────────────────────────────────────────────────────────────
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

  // ── Loaders ───────────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    final user = _auth.state.value.user;
    if (user == null) return;
    try {
      await _accountCtrl.loadProfile(user.id);
      final profile = _accountCtrl.profile.value;
      if (profile != null && mounted) {
        setState(() {
          _firstNameCtrl.text = profile.firstName;
          _lastNameCtrl.text = profile.lastName;
          _phoneCtrl.text = profile.phone ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> _loadLoyalty() async {
    final uid = _auth.state.value.user?.id;
    if (uid == null) return;
    if (mounted) setState(() => _loyaltyLoading = true);
    try {
      await _accountCtrl.fetchLoyaltyTransactions(customerId: uid);
      if (mounted) {
        setState(() {
          _loyaltyTransactions
            ..clear()
            ..addAll(_accountCtrl.loyaltyTransactions);
          _loyaltyLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loyaltyLoading = false);
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final uid = _auth.state.value.user?.id;
    if (uid == null) return;
    setState(() => _isSaving = true);
    try {
      await _accountCtrl.updateUserProfile(
        uid,
        {
          'first_name': _firstNameCtrl.text.trim(),
          'last_name': _lastNameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        }
      );
      if (mounted) {
        Get.snackbar(
          'Saved',
          'Profile updated successfully.',
          backgroundColor: kNavy,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    if (!(_pwFormKey.currentState?.validate() ?? false)) return;
    if (_newPwCtrl.text != _confirmPwCtrl.text) {
      Get.snackbar('Mismatch', 'Passwords do not match.');
      return;
    }
    setState(() => _isChangingPw = true);
    try {
      await _auth.updatePassword(_newPwCtrl.text);
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();
      if (mounted) {
        Get.snackbar(
          'Done',
          'Password changed successfully.',
          backgroundColor: kNavy,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _isChangingPw = false);
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (xfile == null) return;
    final uid = _auth.state.value.user?.id;
    if (uid == null) return;
    try {
      await _accountCtrl.uploadAvatar(uid, await xfile.readAsBytes());
    } catch (e) {
      if (mounted) Get.snackbar('Error', e.toString());
    }
  }

  void _onTabChanged(int tab) {
    setState(() => _activeTab = tab);
    if (tab == 2 && _loyaltyTransactions.isEmpty) {
      _loadLoyalty();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return CustomerScaffold(
      page: 'My Profile',
      pageImage:
          'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=1600&q=80',
      body: Obx(() {
        final user = _auth.state.value.user;
        if (user == null) {
          return EmptyState(
            icon: Icons.lock_outline_rounded,
            title: 'Sign In Required',
            subtitle: 'Please sign in to view your profile.',
            actionLabel: 'Sign In',
            onAction: () => Get.toNamed(AppRoutes.login),
          );
        }
        return _buildContent(user);
      }),
    );
  }

  Widget _buildContent(UserModel user) {
    final isDesktop = MediaQuery.sizeOf(context).width > 900;

    return FB5Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: isDesktop
            ? FB5Row(
                children: [
                  FB5Col(
                    classNames: 'col-lg-3 col-12',
                    child: _ProfileSidebar(
                      user: user,
                      activeTab: _activeTab,
                      onTabChanged: _onTabChanged,
                      onPickAvatar: _pickAvatar,
                    ),
                  ),
                  FB5Col(
                    classNames: 'col-lg-9 col-12',
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
                      newPwCtrl: _newPwCtrl,
                      confirmPwCtrl: _confirmPwCtrl,
                      formKey: _formKey,
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
                    onTabChanged: _onTabChanged,
                    onPickAvatar: _pickAvatar,
                  ),
                  const SizedBox(height: 24),
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
                    newPwCtrl: _newPwCtrl,
                    confirmPwCtrl: _confirmPwCtrl,
                    formKey: _formKey,
                    pwFormKey: _pwFormKey,
                    onSaveProfile: _saveProfile,
                    onChangePassword: _changePassword,
                  ),
                ],
              ),
      ),
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
    required this.onPickAvatar,
  });

  final UserModel user;
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onPickAvatar;

  String get _initials {
    final f = user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '';
    final l = user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : '';
    return '$f$l'.isEmpty ? 'U' : '$f$l';
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          children: [
            // ── Avatar ──────────────────────────────────────────────────
            GestureDetector(
              onTap: onPickAvatar,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: kGold.withAlpha(40),
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            _initials,
                            style: const TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: kNavy,
                            ),
                          )
                        : null,
                  ),
                  Container(
                    width: 28,
                    height: 28,
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
            const SizedBox(height: 12),

            // ── Name ─────────────────────────────────────────────────────
            Text(
              '${user.firstName} ${user.lastName}',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              user.phone ?? '',
              style: AppTextStyles.bodySmall.copyWith(color: kSlate),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            const Divider(color: kBorder, height: 1),
            const SizedBox(height: 16),

            // ── Tab navigation ───────────────────────────────────────────
            ...[
              (0, Icons.person_outline, 'Personal Info'),
              (1, Icons.lock_outline, 'Security'),
              (2, Icons.stars_rounded, 'Loyalty'),
              (3, Icons.location_on_outlined, 'Addresses'),
            ].map(
              (t) => _SidebarTab(
                index: t.$1,
                icon: t.$2,
                label: t.$3,
                active: activeTab == t.$1,
                onTap: () => onTabChanged(t.$1),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(color: kBorder, height: 1),
            const SizedBox(height: 12),

            // ── Sign out ─────────────────────────────────────────────────
            GestureDetector(
              onTap: () => Get.find<AuthController>().signOut(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, size: 16, color: kSlate),
                  const SizedBox(width: 8),
                  Text(
                    'Sign Out',
                    style: AppTextStyles.bodySmall.copyWith(color: kSlate),
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
    required this.index,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final int index;
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active ? kNavy.withAlpha(13) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? kNavy : Colors.transparent,
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
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? kNavy : kSlate,
                ),
              ),
            ],
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
    required this.newPwCtrl,
    required this.confirmPwCtrl,
    required this.formKey,
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
  final TextEditingController newPwCtrl;
  final TextEditingController confirmPwCtrl;
  final GlobalKey<FormState> formKey;
  final GlobalKey<FormState> pwFormKey;
  final VoidCallback onSaveProfile;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) => switch (activeTab) {
        0 => _PersonalInfoTab(
            formKey: formKey,
            firstNameCtrl: firstNameCtrl,
            lastNameCtrl: lastNameCtrl,
            phoneCtrl: phoneCtrl,
            isSaving: isSaving,
            onSave: onSaveProfile,
          ),
        1 => _SecurityTab(
            pwFormKey: pwFormKey,
            newPwCtrl: newPwCtrl,
            confirmPwCtrl: confirmPwCtrl,
            isChangingPw: isChangingPw,
            onChangePassword: onChangePassword,
          ),
        2 => _LoyaltyTab(
            transactions: loyaltyTransactions,
            isLoading: loyaltyLoading,
          ),
        3 => const _AddressesTab(),
        _ => const SizedBox.shrink(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab bodies
// ─────────────────────────────────────────────────────────────────────────────

class _PersonalInfoTab extends StatelessWidget {
  const _PersonalInfoTab({
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.phoneCtrl,
    required this.isSaving,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController phoneCtrl;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                eyebrow: 'Profile',
                title: 'Personal Info',
              ),
              const SizedBox(height: 24),
              FB5Row(
                children: [
                  FB5Col(
                    classNames: 'col-md-6 col-12',
                    child: TextFormField(
                      controller: firstNameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'First Name'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  FB5Col(
                    classNames: 'col-md-6 col-12',
                    child: TextFormField(
                      controller: lastNameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Last Name'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneCtrl,
                decoration:
                    const InputDecoration(labelText: 'Phone (optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Save Changes',
                onPressed: onSave,
                loading: isSaving,
              ),
            ],
          ),
        ),
      );
}

class _SecurityTab extends StatelessWidget {
  const _SecurityTab({
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
              TextFormField(
                controller: newPwCtrl,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'New Password'),
                validator: (v) =>
                    (v == null || v.length < 8) ? 'Min 8 characters' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPwCtrl,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Update Password',
                onPressed: onChangePassword,
                loading: isChangingPw,
              ),
            ],
          ),
        ),
      );
}

class _LoyaltyTab extends StatelessWidget {
  const _LoyaltyTab({
    required this.transactions,
    required this.isLoading,
  });

  final List<LoyaltyTransactionModel> transactions;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(
                    color: kGold, strokeWidth: 2),
              )
            else if (transactions.isEmpty)
              const EmptyState(
                icon: Icons.stars_rounded,
                title: 'No Transactions Yet',
                subtitle: 'Place orders to earn loyalty points.',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: kBorder, height: 1),
                itemBuilder: (_, i) {
                  final t = transactions[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      t.description ?? 'Transaction',
                      style: AppTextStyles.bodyMedium,
                    ),
                    subtitle: Text(
                      // ✅ FIX: shortDate() — 0-arg, no locale
                      t.createdAt.shortDate(),
                      style: AppTextStyles.bodySmall
                          .copyWith(color: kSlate),
                    ),
                    trailing: Text(
                      '${t.points > 0 ? '+' : ''}${t.points} pts',
                      style: TextStyle(
                        fontFamily: 'IBMPlexMono',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color:
                            t.points > 0 ? AppColors.statusGreen : kRed,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      );
}

class _AddressesTab extends StatelessWidget {
  const _AddressesTab();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              eyebrow: 'Delivery',
              title: 'Saved Addresses',
            ),
            const SizedBox(height: 24),
            const EmptyState(
              icon: Icons.location_on_outlined,
              title: 'No Addresses Yet',
              subtitle: 'Saved addresses will appear here.',
            ),
          ],
        ),
      );
}
