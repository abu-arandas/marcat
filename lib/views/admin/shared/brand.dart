// lib/views/admin/shared/brand.dart
//
// Admin-side color aliases — mirrors customer/shared/brand.dart so that
// both halves of the app share a single, consistent naming convention.
//
// Usage: import 'shared/brand.dart'; then use kNavy, kGold, etc.
//
// ✅ UPDATED: added kGreenLight, kAmberLight, kRedLight, kBlueLight,
//    kSuccessGreen, kSuccessGreenLight so every admin screen can use
//    brand aliases for snackbar backgrounds instead of raw AppColors.

import 'package:marcat/core/constants/app_colors.dart';

// ── Primary palette aliases ─────────────────────────────────────────────────
const kNavy = AppColors.marcatNavy;
const kGold = AppColors.marcatGold;
const kGoldVibrant = AppColors.marcatGoldVibrant;
const kCream = AppColors.marcatCream;
const kSlate = AppColors.marcatSlate;
const kCharcoal = AppColors.marcatCharcoal;
const kBlack = AppColors.marcatBlack;

// ── Surface / border ────────────────────────────────────────────────────────
const kSurface = AppColors.surfaceGrey;
const kSurfaceWhite = AppColors.surfaceWhite;
const kBorder = AppColors.borderLight;
const kBorderStrong = AppColors.borderStrong;
const kBorderMedium = AppColors.borderMedium;

// ── Status ──────────────────────────────────────────────────────────────────
const kRed = AppColors.saleRed;
const kErrorRed = AppColors.errorRed;
const kGreen = AppColors.statusGreen;
const kAmber = AppColors.statusAmber;
const kBlue = AppColors.statusBlue;

// ── Status light variants (for snackbar / badge backgrounds) ────────────────
const kGreenLight = AppColors.statusGreenLight;
const kAmberLight = AppColors.statusAmberLight;
const kRedLight = AppColors.statusRedLight;
const kBlueLight = AppColors.statusBlueLight;

// ── Success (distinct from status green) ────────────────────────────────────
const kSuccessGreen = AppColors.successGreen;
const kSuccessGreenLight = AppColors.successGreenLight;

// ── Text ────────────────────────────────────────────────────────────────────
const kTextPrimary = AppColors.textPrimary;
const kTextSecondary = AppColors.textSecondary;
const kTextDisabled = AppColors.textDisabled;
const kTextOnDark = AppColors.textOnDark;
