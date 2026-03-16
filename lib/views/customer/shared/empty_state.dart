// lib/views/customer/shared/empty_state.dart

import 'package:flutter/material.dart';
import 'brand.dart';

/// Consistent empty / error / loading state used across all customer pages.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kCream,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorderColor),
                ),
                child: Icon(icon, size: 36, color: kSlate),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: kNavy,
                ),
              ),

              // Subtitle
              if (subtitle != null) ...[
                const SizedBox(height: 10),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: kSlate,
                    height: 1.6,
                  ),
                ),
              ],

              // Action button
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 28),
                SizedBox(
                  width: 180,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kNavy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    child: Text(actionLabel!),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SkeletonRow — simple shimmer placeholder row
// ─────────────────────────────────────────────────────────────────────────────

class SkeletonRow extends StatelessWidget {
  const SkeletonRow({super.key, this.height = 60});

  final double height;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: kCream,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kBorderColor),
        ),
      );
}
