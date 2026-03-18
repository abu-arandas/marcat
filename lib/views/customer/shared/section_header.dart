// lib/views/customer/shared/section_header.dart

import 'package:flutter/material.dart';
import 'brand.dart';

/// Reusable section header used across all customer pages.
/// Shows a gold eyebrow label, serif title, optional subtitle & trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.action,
    this.dark = false,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? action;
  final bool dark;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Eyebrow ──────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 2,
                      color: kGold,
                      margin: const EdgeInsets.only(right: 10),
                    ),
                    Text(
                      eyebrow.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: kGold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Title ────────────────────────────────────────────────
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay', // ✅ correct — no space
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: dark ? Colors.white : kNavy,
                    height: 1.15,
                  ),
                ),

                // ── Subtitle ─────────────────────────────────────────────
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 14,
                      color: dark ? Colors.white.withOpacity(0.55) : kSlate,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Trailing action (e.g. "View All" button) ──────────────────
          if (action != null) ...[
            const SizedBox(width: 16),
            action!,
          ],
        ],
      );
}
