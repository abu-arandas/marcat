// lib/views/customer/shared/section_header.dart

import 'package:flutter/material.dart';
import 'brand.dart';

/// Reusable section header used across all customer pages.
/// Shows an eyebrow label, serif title, optional subtitle & trailing action.
class SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? action;
  final bool dark;

  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.action,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 24,
                    height: 2,
                    color: kGold,
                    margin: const EdgeInsets.only(right: 10),
                  ),
                  Text(
                    eyebrow.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: kGold,
                      letterSpacing: 2,
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: dark ? Colors.white : kNavy,
                    height: 1.1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: dark ? Colors.white.withOpacity(0.55) : kSlate,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 16),
            action!,
          ],
        ],
      );
}
