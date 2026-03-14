// lib/views/auth/auth_scaffold.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

class AuthScaffold extends StatefulWidget {
  final String title;
  final String subTitle;
  final Form form;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subTitle,
    required this.form,
  });

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
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xAA1C2B4B), Color(0xF01C2B4B)],
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
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Manage orders, track deliveries, and\n'
                    'grow your business — all in one place.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.78),
                      fontSize: 16,
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 36),
                  const Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _FeaturePill(
                        icon: Icons.bolt_rounded,
                        label: 'Real-time tracking',
                      ),
                      _FeaturePill(
                        icon: Icons.shield_rounded,
                        label: 'Secure platform',
                      ),
                      _FeaturePill(
                        icon: Icons.analytics_rounded,
                        label: 'Smart analytics',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Right panel — form ──────────────────────────────────────────
          FB5Col(
            // Full width on xs/sm; remaining columns on md+
            classNames: 'col-12 col-md-5 col-lg-4',
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height,
                  child: Scrollbar(
                    thumbVisibility: false,
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 40,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(
                              Icons.arrow_back_ios_rounded,
                              size: 18,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AuthTheme.surface,
                              foregroundColor: AuthTheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: AuthTheme.border),
                              ),
                              padding: const EdgeInsets.all(10),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: AuthTheme.primary,
                              letterSpacing: -0.3,
                            ),
                          ),
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
  static const Color primary = Color(0xFF1C2B4B);
  static const Color accent = Color(0xFFE85D04);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8ECF4);
  static const Color muted = Color(0xFF6B7C93);
  static const Color error = Color(0xFFDC2626);

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

  static const TextStyle bodyStyle = TextStyle(fontSize: 15, color: muted);

  static const TextStyle buttonLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static ButtonStyle primaryButtonStyle() => ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: surface,
        disabledBackgroundColor: primary.withOpacity(0.45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      );

  static ButtonStyle outlinedButtonStyle() => OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _FeaturePill — left-panel marketing chips
// ─────────────────────────────────────────────────────────────────────────────

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 15),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}
