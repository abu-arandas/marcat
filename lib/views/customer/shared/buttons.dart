// lib/views/customer/shared/buttons.dart

import 'package:flutter/material.dart';
import 'brand.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PrimaryButton — solid navy CTA
// ─────────────────────────────────────────────────────────────────────────────

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.height = 52,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: kNavy,
            foregroundColor: Colors.white,
            // withAlpha(115) ≈ 45 % opacity — replaces deprecated withOpacity(0.45)
            disabledBackgroundColor: kNavy.withAlpha(115),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(label),
                  ],
                ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// OutlineButton — navy outline, gold hover
// ─────────────────────────────────────────────────────────────────────────────

class OutlineButton extends StatefulWidget {
  const OutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 52,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final IconData? icon;

  @override
  State<OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<OutlineButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: widget.onPressed != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) {
          if (widget.onPressed != null) setState(() => _hovered = true);
        },
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: _hovered ? kGold : Colors.transparent,
              border: Border.all(
                color: _hovered ? kGold : kNavy,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 16, color: kNavy),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: kNavy,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// GoldButton — gold-filled accent CTA
// ─────────────────────────────────────────────────────────────────────────────

class GoldButton extends StatelessWidget {
  const GoldButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: kGold,
            foregroundColor: kNavy,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: kNavy,
                    strokeWidth: 2,
                  ),
                )
              : Text(label),
        ),
      );
}
