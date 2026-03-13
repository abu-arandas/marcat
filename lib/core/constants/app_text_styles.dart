// lib/core/constants/app_text_styles.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Display (Playfair Display — editorial headings) ───────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.marcatBlack,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.marcatBlack,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.marcatBlack,
    height: 1.3,
  );

  // ── Headings (Playfair Display) ───────────────────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.marcatBlack,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.marcatBlack,
    height: 1.35,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.marcatBlack,
    height: 1.4,
  );

  // ── Body (IBM Plex Sans Arabic — dual-script support) ────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.marcatCharcoal,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.marcatCharcoal,
    height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ── Label (IBM Plex Sans Arabic — UI elements) ────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.marcatBlack,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.marcatBlack,
    height: 1.4,
    letterSpacing: 0.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
    letterSpacing: 0.3,
  );

  // ── Title (IBM Plex Sans Arabic — cards, app bar) ─────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.marcatBlack,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.marcatBlack,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.marcatBlack,
    height: 1.4,
    letterSpacing: 0.1,
  );

  // ── Price / Currency (IBM Plex Mono — monospace) ──────────────────────────
  static const TextStyle priceLarge = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.marcatBlack,
    letterSpacing: 0,
  );

  static const TextStyle priceMedium = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.marcatBlack,
    letterSpacing: 0,
  );

  static const TextStyle priceSmall = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.marcatCharcoal,
    letterSpacing: 0,
  );

  // ── SKU / Reference codes ─────────────────────────────────────────────────
  static const TextStyle skuText = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle referenceText = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.marcatBlack,
    letterSpacing: 0.5,
  );

  // ── Button text ───────────────────────────────────────────────────────────
  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  // ── Sale / promo ──────────────────────────────────────────────────────────
  static const TextStyle saleBadge = TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.surfaceWhite,
    letterSpacing: 0.5,
  );

  static const TextStyle strikethrough = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textDisabled,
    decoration: TextDecoration.lineThrough,
  );

  // ── Chip / badge ──────────────────────────────────────────────────────────
  static const TextStyle chipLabel = TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  // ── App bar title ─────────────────────────────────────────────────────────
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.marcatBlack,
    letterSpacing: 0,
  );

  // ── Empty state ───────────────────────────────────────────────────────────
  static const TextStyle emptyStateTitle = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.marcatCharcoal,
  );

  static const TextStyle emptyStateBody = TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );
}
