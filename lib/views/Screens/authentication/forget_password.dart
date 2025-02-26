import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/validations.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen>
    with FormValidation {
  final PageController _pageController = PageController();

  final GlobalKey<FormState> _emailFormKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();

  final GlobalKey<FormState> _codeFormKey = GlobalKey();
  final TextEditingController _codelController = TextEditingController();

  final GlobalKey<FormState> _resetFormKey = GlobalKey();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Recovery'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_pageController.page?.round() == 0) {
              Get.back();
            }
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildEmailInputPage(),
          _buildCodeInputPage(),
          _buildPasswordResetPage(),
        ],
      ),
    );
  }

  Widget _buildEmailInputPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _emailFormKey,
        child: Column(
          children: [
            const Text(
              'Enter your email to receive a password reset link',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: validateEmail,
              onFieldSubmitted: (_) => _submitEmail(),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitEmail,
              icon:
                  _isLoading ? const SizedBox.shrink() : const Icon(Icons.send),
              label: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Send Verification'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeInputPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _codeFormKey,
        child: Column(
          children: [
            const Text(
              'Enter your received code',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _codelController,
              decoration: const InputDecoration(
                labelText: 'code',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: validateCode,
              onFieldSubmitted: (_) => _submitCode(),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitCode,
              icon:
                  _isLoading ? const SizedBox.shrink() : const Icon(Icons.done),
              label: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Verificate'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordResetPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _resetFormKey,
        child: Column(
          children: [
            const Text(
              'Create a new password',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: validatePassword,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) => validateConfirmPassword(
                value,
                _passwordController.text,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitNewPassword,
              icon: _isLoading
                  ? const SizedBox.shrink()
                  : const Icon(Icons.lock_reset),
              label: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Reset Password'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitEmail() async {
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitCode() async {
    if (!(_codeFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitNewPassword() async {
    if (!(_resetFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    // Show success message and navigate back
    Get.snackbar('Success', 'Password updated successfully!');
    Get.back();
  }
}
