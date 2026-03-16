// lib/views/customer/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:marcat/controllers/account_controller.dart';
import 'package:marcat/controllers/auth_controller.dart';
import 'package:marcat/models/loyalty_transaction_model.dart';
import 'package:marcat/models/user_model.dart';

import '../../models/enums.dart';
import 'scaffold/app_scaffold.dart';
import 'shared/brand.dart';
import 'shared/empty_state.dart';
import 'shared/marcat_buttons.dart';
import 'shared/section_header.dart';
import 'package:marcat/core/router/app_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isSaving = false;
  final loyaltyTransactions = <LoyaltyTransactionModel>[];
  bool loyaltyLoading = false;
  int activeTab = 0; // 0=profile 1=loyalty 2=security

  // Form controllers
  late final TextEditingController firstNameCtrl;
  late final TextEditingController lastNameCtrl;
  late final TextEditingController phoneCtrl;
  final formKey = GlobalKey<FormState>();

  // Password change
  late final TextEditingController currentPwCtrl;
  late final TextEditingController newPwCtrl;
  late final TextEditingController confirmPwCtrl;
  final pwFormKey = GlobalKey<FormState>();
  bool isChangingPw = false;

  AccountController get _accountCtrl => Get.find<AccountController>();
  AuthController get _auth => Get.find<AuthController>();
  UserModel? get _user => _auth.user;

  @override
  void initState() {
    super.initState();
    firstNameCtrl = TextEditingController();
    lastNameCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    currentPwCtrl = TextEditingController();
    newPwCtrl = TextEditingController();
    confirmPwCtrl = TextEditingController();
    _populateForm();
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    currentPwCtrl.dispose();
    newPwCtrl.dispose();
    confirmPwCtrl.dispose();
    super.dispose();
  }

  void _populateForm() {
    final user = _user;
    if (user == null) return;
    firstNameCtrl.text = user.firstName;
    lastNameCtrl.text = user.lastName;
    phoneCtrl.text = user.phone ?? '';
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) return;
    final user = _user;
    if (user == null) return;
    if (mounted) setState(() => isSaving = true);
    try {
      await _accountCtrl.updateUserProfile(user.id, {
        'first_name': firstNameCtrl.text.trim(),
        'last_name': lastNameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
      });
      await _auth.refreshAuth();
      Get.snackbar(
        'Profile Updated',
        'Your profile has been saved.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: kNavy,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> uploadAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (file == null) return;
    final user = _user;
    if (user == null) return;

    if (mounted) setState(() => isSaving = true);
    try {
      final bytes = await file.readAsBytes();
      final url = await _accountCtrl.uploadAvatar(user.id, bytes);
      await _accountCtrl.updateUserProfile(user.id, {'avatar_url': url});
      await _auth.refreshAuth();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> loadLoyaltyTransactions() async {
    final user = _user;
    if (user == null) return;
    if (mounted) setState(() => loyaltyLoading = true);
    try {
      await _accountCtrl.fetchLoyaltyTransactions(
        customerId: user.id,
        pageSize: 20,
      );
      if (mounted) {
        setState(() {
          loyaltyTransactions
            ..clear()
            ..addAll(_accountCtrl.loyaltyTransactions);
        });
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => loyaltyLoading = false);
    }
  }

  Future<void> changePassword() async {
    if (!pwFormKey.currentState!.validate()) return;
    if (mounted) setState(() => isChangingPw = true);
    try {
      await _auth.updatePassword(newPwCtrl.text);
      currentPwCtrl.clear();
      newPwCtrl.clear();
      confirmPwCtrl.clear();
      Get.snackbar(
        'Password Changed',
        'Your password has been updated.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: kNavy,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => isChangingPw = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomerScaffold(
      page: 'My Profile',
      pageImage:
          'https://images.unsplash.com/photo-1551434678-e076c223a692?w=1600&q=80',
      body: _ProfileBody(
        user: _user,
        isSaving: isSaving,
        loyaltyTransactions: loyaltyTransactions,
        loyaltyLoading: loyaltyLoading,
        activeTab: activeTab,
        firstNameCtrl: firstNameCtrl,
        lastNameCtrl: lastNameCtrl,
        phoneCtrl: phoneCtrl,
        formKey: formKey,
        currentPwCtrl: currentPwCtrl,
        newPwCtrl: newPwCtrl,
        confirmPwCtrl: confirmPwCtrl,
        pwFormKey: pwFormKey,
        isChangingPw: isChangingPw,
        onSaveProfile: saveProfile,
        onUploadAvatar: uploadAvatar,
        onLoadLoyalty: loadLoyaltyTransactions,
        onChangePassword: changePassword,
        onTabChanged: (idx) => setState(() => activeTab = idx),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProfileBody
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileBody extends StatelessWidget {
  final UserModel? user;
  final bool isSaving;
  final List<LoyaltyTransactionModel> loyaltyTransactions;
  final bool loyaltyLoading;
  final int activeTab;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController phoneCtrl;
  final GlobalKey<FormState> formKey;
  final TextEditingController currentPwCtrl;
  final TextEditingController newPwCtrl;
  final TextEditingController confirmPwCtrl;
  final GlobalKey<FormState> pwFormKey;
  final bool isChangingPw;
  final VoidCallback onSaveProfile;
  final VoidCallback onUploadAvatar;
  final VoidCallback onLoadLoyalty;
  final VoidCallback onChangePassword;
  final ValueChanged<int> onTabChanged;

  const _ProfileBody({
    required this.user,
    required this.isSaving,
    required this.loyaltyTransactions,
    required this.loyaltyLoading,
    required this.activeTab,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.phoneCtrl,
    required this.formKey,
    required this.currentPwCtrl,
    required this.newPwCtrl,
    required this.confirmPwCtrl,
    required this.pwFormKey,
    required this.isChangingPw,
    required this.onSaveProfile,
    required this.onUploadAvatar,
    required this.onLoadLoyalty,
    required this.onChangePassword,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      final currentUser = auth.user;

      if (currentUser == null) {
        return EmptyState(
          icon: Icons.person_outline_rounded,
          title: 'Sign In to Access Your Profile',
          subtitle: 'View and edit your personal details.',
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
                        user: currentUser,
                        activeTab: activeTab,
                        onTabChanged: onTabChanged,
                        onUploadAvatar: onUploadAvatar,
                        onLoadLoyalty: onLoadLoyalty,
                      ),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      child: _ProfileContent(
                        user: currentUser,
                        activeTab: activeTab,
                        isSaving: isSaving,
                        loyaltyTransactions: loyaltyTransactions,
                        loyaltyLoading: loyaltyLoading,
                        firstNameCtrl: firstNameCtrl,
                        lastNameCtrl: lastNameCtrl,
                        phoneCtrl: phoneCtrl,
                        formKey: formKey,
                        newPwCtrl: newPwCtrl,
                        confirmPwCtrl: confirmPwCtrl,
                        pwFormKey: pwFormKey,
                        isChangingPw: isChangingPw,
                        onSaveProfile: onSaveProfile,
                        onChangePassword: onChangePassword,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _ProfileSidebar(
                      user: currentUser,
                      activeTab: activeTab,
                      onTabChanged: onTabChanged,
                      onUploadAvatar: onUploadAvatar,
                      onLoadLoyalty: onLoadLoyalty,
                    ),
                    const SizedBox(height: 32),
                    _ProfileContent(
                      user: currentUser,
                      activeTab: activeTab,
                      isSaving: isSaving,
                      loyaltyTransactions: loyaltyTransactions,
                      loyaltyLoading: loyaltyLoading,
                      firstNameCtrl: firstNameCtrl,
                      lastNameCtrl: lastNameCtrl,
                      phoneCtrl: phoneCtrl,
                      formKey: formKey,
                      newPwCtrl: newPwCtrl,
                      confirmPwCtrl: confirmPwCtrl,
                      pwFormKey: pwFormKey,
                      isChangingPw: isChangingPw,
                      onSaveProfile: onSaveProfile,
                      onChangePassword: onChangePassword,
                    ),
                  ],
                ),
        ),
      );
    });
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
    required this.onLoadLoyalty,
  });

  final UserModel user;
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onUploadAvatar;
  final VoidCallback onLoadLoyalty;

  static String _initials(String fn, String ln) =>
      '${fn.isNotEmpty ? fn[0] : ''}${ln.isNotEmpty ? ln[0] : ''}'
          .toUpperCase();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kNavy,
                  border: Border.all(color: kGold.withOpacity(0.4), width: 3),
                  image: user.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(user.avatarUrl!),
                          fit: BoxFit.cover)
                      : null,
                ),
                child: user.avatarUrl == null
                    ? Center(
                        child: Text(
                          _initials(user.firstName, user.lastName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : null,
              ),
              GestureDetector(
                onTap: onUploadAvatar,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: kGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      size: 14, color: kNavy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kNavy,
            ),
          ),
          if (user.phone != null) ...[
            const SizedBox(height: 4),
            Text(
              user.phone!,
              style: const TextStyle(fontSize: 13, color: kSlate),
            ),
          ],
          const SizedBox(height: 24),

          // Tab navigation
          _SidebarTab(
            icon: Icons.person_outline_rounded,
            label: 'Edit Profile',
            active: activeTab == 0,
            onTap: () => onTabChanged(0),
          ),
          _SidebarTab(
            icon: Icons.stars_rounded,
            label: 'Loyalty Points',
            active: activeTab == 1,
            onTap: () {
              onTabChanged(1);
              onLoadLoyalty();
            },
          ),
          _SidebarTab(
            icon: Icons.lock_outline_rounded,
            label: 'Security',
            active: activeTab == 2,
            onTap: () => onTabChanged(2),
          ),
          const SizedBox(height: 16),

          // Sign out
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Get.find<AuthController>().signOut(),
              icon: const Icon(Icons.logout_rounded, size: 16),
              label: const Text('Sign Out',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: kRed,
                side: const BorderSide(color: kRed),
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
            color: active ? kNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: active ? Colors.white : kSlate),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? Colors.white : kSlate,
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
    required this.loyaltyTransactions,
    required this.loyaltyLoading,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.phoneCtrl,
    required this.formKey,
    required this.newPwCtrl,
    required this.confirmPwCtrl,
    required this.pwFormKey,
    required this.isChangingPw,
    required this.onSaveProfile,
    required this.onChangePassword,
  });

  final UserModel user;
  final int activeTab;
  final bool isSaving;
  final List<LoyaltyTransactionModel> loyaltyTransactions;
  final bool loyaltyLoading;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController phoneCtrl;
  final GlobalKey<FormState> formKey;
  final TextEditingController newPwCtrl;
  final TextEditingController confirmPwCtrl;
  final GlobalKey<FormState> pwFormKey;
  final bool isChangingPw;
  final VoidCallback onSaveProfile;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) {
    switch (activeTab) {
      case 1:
        return _LoyaltyTab(
          loyaltyTransactions: loyaltyTransactions,
          loyaltyLoading: loyaltyLoading,
          user: user,
        );
      case 2:
        return _SecurityTab(
          newPwCtrl: newPwCtrl,
          confirmPwCtrl: confirmPwCtrl,
          pwFormKey: pwFormKey,
          isChangingPw: isChangingPw,
          onChangePassword: onChangePassword,
        );
      default:
        return _EditProfileTab(
          user: user,
          isSaving: isSaving,
          firstNameCtrl: firstNameCtrl,
          lastNameCtrl: lastNameCtrl,
          phoneCtrl: phoneCtrl,
          formKey: formKey,
          onSaveProfile: onSaveProfile,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EditProfileTab
// ─────────────────────────────────────────────────────────────────────────────

class _EditProfileTab extends StatelessWidget {
  const _EditProfileTab({
    required this.user,
    required this.isSaving,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.phoneCtrl,
    required this.formKey,
    required this.onSaveProfile,
  });

  final UserModel user;
  final bool isSaving;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController phoneCtrl;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSaveProfile;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Account',
            title: 'Edit Profile',
            subtitle: 'Update your personal information.',
          ),
          const SizedBox(height: 24),
          Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: firstNameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'First Name'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: lastNameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Last Name'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Save Changes',
                    loading: isSaving,
                    onPressed: onSaveProfile,
                  ),
                ),
              ],
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

        // Points balance card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kNavy,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.stars_rounded, color: kGold, size: 36),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${customer?.loyaltyPoints ?? 0} pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    customer?.loyaltyTier.dbValue.toUpperCase() ?? 'BRONZE',
                    style: TextStyle(
                      color: kGold.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Transactions list
        if (loyaltyLoading)
          const Center(child: CircularProgressIndicator())
        else if (loyaltyTransactions.isEmpty)
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No Transactions Yet',
            subtitle: 'Points earned from purchases appear here.',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: loyaltyTransactions.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: kCream),
            itemBuilder: (_, i) {
              final tx = loyaltyTransactions[i];
              final isEarned = tx.points > 0;
              return ListTile(
                leading: Icon(
                  isEarned
                      ? Icons.add_circle_outline_rounded
                      : Icons.remove_circle_outline_rounded,
                  color: isEarned ? kGold : kRed,
                ),
                title: Text(
                  tx.description ??
                      (isEarned ? 'Points earned' : 'Points redeemed'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kNavy,
                  ),
                ),
                subtitle: Text(
                  '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year}',
                  style: const TextStyle(fontSize: 12, color: kSlate),
                ),
                trailing: Text(
                  '${isEarned ? '+' : ''}${tx.points} pts',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isEarned ? kGold : kRed,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SecurityTab
// ─────────────────────────────────────────────────────────────────────────────

class _SecurityTab extends StatelessWidget {
  const _SecurityTab({
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
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Security',
            title: 'Change Password',
            subtitle: 'Choose a strong password to keep your account safe.',
          ),
          const SizedBox(height: 24),
          Form(
            key: pwFormKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  controller: newPwCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  validator: (v) {
                    if (v == null || v.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPwCtrl,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Confirm New Password'),
                  validator: (v) {
                    if (v != newPwCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Update Password',
                    loading: isChangingPw,
                    onPressed: onChangePassword,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
