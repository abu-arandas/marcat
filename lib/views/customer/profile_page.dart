// lib/views/customer/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// FIX: customer_repository.dart → account_controller.dart
import 'package:marcat/controllers/account_controller.dart';
// FIX: loyalty_repository.dart merged into AccountController

import 'package:marcat/controllers/auth_controller.dart'; // FIX: auth_provider.dart → auth_controller.dart
import 'package:marcat/models/loyalty_transaction_model.dart';
import 'package:marcat/models/user_model.dart';

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
      Get.snackbar('Profile Updated', 'Your profile has been saved.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: kNavy,
          colorText: Colors.white);
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
      final txs = await _accountCtrl.fetchLoyaltyTransactions(
          customerId: user.id, pageSize: 20);

      if (mounted) {
        setState(() {
          loyaltyTransactions.clear();
          //loyaltyTransactions.add(txs);
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
      await Supabase.instance.client.auth
          .updateUser(UserAttributes(password: newPwCtrl.text));
      currentPwCtrl.clear();
      newPwCtrl.clear();
      confirmPwCtrl.clear();
      Get.snackbar('Password Changed', 'Your password has been updated.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: kNavy,
          colorText: Colors.white);
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
                    )),
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

// â”€â”€â”€ Sidebar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ProfileSidebar extends StatelessWidget {
  final UserModel user;
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onUploadAvatar;
  final VoidCallback onLoadLoyalty;

  const _ProfileSidebar({
    required this.user,
    required this.activeTab,
    required this.onTabChanged,
    required this.onUploadAvatar,
    required this.onLoadLoyalty,
  });

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
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
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

          Text(
            '${user.firstName} ${user.lastName}',
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kNavy,
            ),
          ),
          if (user.phone != null)
            Text(user.phone!,
                style: const TextStyle(fontSize: 13, color: kSlate)),

          const SizedBox(height: 28),

          // Nav items
          _SidebarTab(
            icon: Icons.person_outline_rounded,
            label: 'Edit Profile',
            index: 0,
            activeTab: activeTab,
            onTabChanged: onTabChanged,
          ),
          _SidebarTab(
            icon: Icons.star_outline_rounded,
            label: 'Loyalty Points',
            index: 1,
            activeTab: activeTab,
            onTabChanged: (idx) {
              onTabChanged(idx);
              onLoadLoyalty();
            },
          ),
          _SidebarTab(
            icon: Icons.lock_outline_rounded,
            label: 'Change Password',
            index: 2,
            activeTab: activeTab,
            onTabChanged: onTabChanged,
          ),

          const SizedBox(height: 16),
          const Divider(color: kBorderColor),
          const SizedBox(height: 8),

          // Quick links
          _SidebarLink(
            icon: Icons.receipt_long_outlined,
            label: 'My Orders',
            onTap: () => Get.toNamed(AppRoutes.orders),
          ),
          _SidebarLink(
            icon: Icons.favorite_outline_rounded,
            label: 'Wishlist',
            onTap: () => Get.toNamed(AppRoutes.wishlist),
          ),
          _SidebarLink(
            icon: Icons.location_on_outlined,
            label: 'Addresses',
            onTap: () => Get.toNamed(AppRoutes.checkout),
          ),
        ],
      );
}

class _SidebarTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int activeTab;
  final ValueChanged<int> onTabChanged;

  const _SidebarTab({
    required this.icon,
    required this.label,
    required this.index,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeTab == index;
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: active ? kNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: active ? Colors.white : kSlate),
            const SizedBox(width: 12),
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
}

class _SidebarLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SidebarLink(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Icon(icon, size: 18, color: kSlate),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: kSlate)),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: kSlate),
            ],
          ),
        ),
      );
}

// â”€â”€â”€ Profile Content â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ProfileContent extends StatelessWidget {
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

// â”€â”€â”€ Edit Profile Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _EditProfileTab extends StatelessWidget {
  final UserModel user;
  final bool isSaving;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController phoneCtrl;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSaveProfile;

  const _EditProfileTab({
    required this.user,
    required this.isSaving,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.phoneCtrl,
    required this.formKey,
    required this.onSaveProfile,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Account',
            title: 'Edit Profile',
            subtitle: 'Update your personal information.',
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorderColor),
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
                          hint: 'Your first name',
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ProfileField(
                          controller: lastNameCtrl,
                          label: 'Last Name',
                          hint: 'Your last name',
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ProfileField(
                    controller: phoneCtrl,
                    label: 'Phone Number',
                    hint: '+962 7X XXX XXXX',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Save Changes',
                    onPressed: onSaveProfile,
                    loading: isSaving,
                    icon: Icons.check_rounded,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? Function(String?)? validator;

  const _ProfileField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.obscure = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: kNavy)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            validator: validator,
            style: const TextStyle(fontSize: 14, color: kNavy),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: kSlate, fontSize: 14),
              filled: true,
              fillColor: kCream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBorderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kNavy, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      );
}

// â”€â”€â”€ Loyalty Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _LoyaltyTab extends StatelessWidget {
  final List<LoyaltyTransactionModel> loyaltyTransactions;
  final bool loyaltyLoading;
  final UserModel user;

  const _LoyaltyTab({
    required this.loyaltyTransactions,
    required this.loyaltyLoading,
    required this.user,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Rewards',
            title: 'Loyalty Points',
            subtitle:
                'Earn points with every purchase and redeem for discounts.',
          ),
          const SizedBox(height: 24),

          // Points balance card
          Obx(() {
            final customer = Get.find<AuthController>().customer;
            final points = customer?.loyaltyPoints ?? 0;

            return Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kNavy, Color(0xFF2D2D4E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL POINTS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: kGold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$points',
                        style: const TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'pts = JOD ${(points / 100).toStringAsFixed(2)} value',
                        style: TextStyle(
                            fontSize: 13, color: Colors.white.withOpacity(0.6)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.star_rounded, size: 64, color: kGold),
                ],
              ),
            );
          }),

          const SizedBox(height: 32),

          // How it works
          const Text(
            'HOW IT WORKS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kSlate,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: _HowItWorksStep(
                    icon: Icons.shopping_bag_outlined,
                    step: '1',
                    desc: 'Earn 1 point per JOD spent'),
              ),
              Expanded(
                child: _HowItWorksStep(
                    icon: Icons.redeem_outlined,
                    step: '2',
                    desc: '100 points = JOD 1 discount'),
              ),
              Expanded(
                child: _HowItWorksStep(
                    icon: Icons.celebration_outlined,
                    step: '3',
                    desc: 'Apply at checkout for savings'),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Transaction history
          const Text(
            'POINTS HISTORY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kSlate,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          Builder(builder: (context) {
            if (loyaltyLoading) {
              return const Center(
                  child:
                      CircularProgressIndicator(color: kNavy, strokeWidth: 2));
            }
            if (loyaltyTransactions.isEmpty) {
              return const Text(
                'No transactions yet. Start shopping to earn points!',
                style: TextStyle(fontSize: 14, color: kSlate),
              );
            }
            return Column(
              children: loyaltyTransactions
                  .map((t) => _LoyaltyRow(t: t))
                  .toList(),
            );
          }),
        ],
      );
}

class _HowItWorksStep extends StatelessWidget {
  final IconData icon;
  final String step, desc;
  const _HowItWorksStep(
      {required this.icon, required this.step, required this.desc});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: kCream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorderColor),
                  ),
                  child: Icon(icon, size: 22, color: kNavy),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                        color: kGold, shape: BoxShape.circle),
                    child: Center(
                      child: Text(step,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: kNavy)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(desc,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, color: kSlate, height: 1.5)),
          ],
        ),
      );
}

class _LoyaltyRow extends StatelessWidget {
  final LoyaltyTransactionModel t;
  const _LoyaltyRow({required this.t});

  @override
  Widget build(BuildContext context) {
    final earn = t.points > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  earn ? Colors.green.withOpacity(0.1) : kRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              earn ? Icons.add_rounded : Icons.remove_rounded,
              size: 18,
              color: earn ? Colors.green : kRed,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.description ?? 'Points transaction',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: kNavy),
                ),
                Text(
                  _formatDate(t.createdAt),
                  style: const TextStyle(fontSize: 11, color: kSlate),
                ),
              ],
            ),
          ),
          Text(
            '${earn ? '+' : ''}${t.points} pts',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: earn ? Colors.green : kRed,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

// â”€â”€â”€ Security Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SecurityTab extends StatelessWidget {
  final TextEditingController newPwCtrl;
  final TextEditingController confirmPwCtrl;
  final GlobalKey<FormState> pwFormKey;
  final bool isChangingPw;
  final VoidCallback onChangePassword;

  const _SecurityTab({
    required this.newPwCtrl,
    required this.confirmPwCtrl,
    required this.pwFormKey,
    required this.isChangingPw,
    required this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Security',
            title: 'Change Password',
            subtitle: 'Keep your account secure with a strong password.',
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorderColor),
            ),
            child: Form(
              key: pwFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileField(
                    controller: newPwCtrl,
                    label: 'New Password',
                    hint: 'Min 8 characters',
                    obscure: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 8) return 'Minimum 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _ProfileField(
                    controller: confirmPwCtrl,
                    label: 'Confirm New Password',
                    hint: 'Repeat your new password',
                    obscure: true,
                    validator: (v) {
                      if (v != newPwCtrl.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Update Password',
                    onPressed: onChangePassword,
                    loading: isChangingPw,
                    icon: Icons.lock_outline_rounded,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Danger zone
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kRed.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kRed.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 18, color: kRed),
                    SizedBox(width: 8),
                    Text('Sign Out',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: kRed)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign out of your account on this device.',
                  style: TextStyle(fontSize: 13, color: kSlate),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Get.find<AuthController>().signOut(),
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text('Sign Out',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kRed,
                    side: const BorderSide(color: kRed),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
