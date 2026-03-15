// lib/views/auth/auth_scaffold.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';

import 'package:marcat/core/constants/app_colors.dart';
import 'package:marcat/core/constants/app_dimensions.dart';

class AuthScaffold extends StatefulWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subTitle,
    required this.form,
  });

  final String title;
  final String subTitle;
  final Form form;

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: FB5Row(
        children: [
          // ── Left panel — marketing / branding ──────────────────────────
          FB5Col(
            classNames: 'col-md-7 col-lg-8 d-none d-md-block',
            child: Container(
              width: double.infinity,
              height: MediaQuery.sizeOf(context).height,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/auth_background.jpg'),
                  fit: BoxFit.cover,
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xAA1A1A2E), Color(0xF01A1A2E)],
                  stops: [0.0, 1.0],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    width: 200,
                    color: Colors.white,
                  ),
                  const Spacer(),
                  const Text(
                    'Fast.\nReliable.\nDelivered.',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'The best men\'s clothing platform in Jordan.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xCCFFFFFF),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),

          // ── Right panel — auth form ─────────────────────────────────────
          FB5Col(
            classNames: 'col-12 col-md-5 col-lg-4',
            child: Container(
              height: MediaQuery.sizeOf(context).height,
              color: const Color(0xFFF8F9FB),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space32,
                  vertical: AppDimensions.space48,
                ),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppDimensions.space32),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: AuthTheme.primary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.subTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AuthTheme.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 36),
                        widget.form,
                        SizedBox(
                          height: MediaQuery.viewInsetsOf(context).bottom,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthTheme — scoped design tokens for the auth flow
// ─────────────────────────────────────────────────────────────────────────────
class AuthTheme {
  AuthTheme._();

  // ── Color aliases ──────────────────────────────────────────────────────────
  static const Color primary = AppColors.marcatNavy;
  static const Color accent = AppColors.accentOrange;
  static const Color surface = AppColors.surfaceWhite;
  static const Color border = AppColors.borderLight;
  static const Color muted = AppColors.marcatSlate;
  static const Color error = AppColors.errorRedVivid;

  // ── Text styles ────────────────────────────────────────────────────────────
  static const TextStyle bodyStyle = TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 14,
    color: primary,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // ── Input decoration factory ───────────────────────────────────────────────
  static InputDecoration inputDecoration(
    String label, {
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: muted, fontSize: 14),
        floatingLabelStyle: const TextStyle(
          color: primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: muted)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      );

  // ── Button style factory ───────────────────────────────────────────────────
  static ButtonStyle primaryButtonStyle() => ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: buttonLabel,
      );
}
