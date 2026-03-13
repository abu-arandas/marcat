// lib/core/constants/app_dimensions.dart

class AppDimensions {
  AppDimensions._();

  // ── Spacing scale (base unit: 8px) ────────────────────────────────────────
  static const double space0 = 0;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;
  static const double space80 = 80;
  static const double space96 = 96;

  // ── Border radius ─────────────────────────────────────────────────────────
  static const double radiusXS = 2;
  static const double radiusS = 4; // cards, inputs — sharp/masculine
  static const double radiusM = 8;
  static const double radiusL = 12;
  static const double radiusXL = 16;
  static const double radiusPill = 100; // chips, badges

  // ── Button heights ────────────────────────────────────────────────────────
  static const double buttonHeightPrimary = 52;
  static const double buttonHeightSecondary = 44;
  static const double buttonHeightSmall = 36;

  // ── App bar ───────────────────────────────────────────────────────────────
  static const double appBarHeight = 60;

  // ── Bottom navigation ──────────────────────────────────────────────────────
  static const double bottomNavHeight = 64;

  // ── Product card ──────────────────────────────────────────────────────────
  static const double productCardAspectRatio = 3 / 4; // 3:4 portrait
  static const double productCardImageAspectRatio = 3 / 4;

  // ── Icon sizes ────────────────────────────────────────────────────────────
  static const double iconXS = 14;
  static const double iconS = 16;
  static const double iconM = 20;
  static const double iconL = 24;
  static const double iconXL = 32;
  static const double iconXXL = 48;

  // ── Avatar sizes ──────────────────────────────────────────────────────────
  static const double avatarSmall = 32;
  static const double avatarMedium = 48;
  static const double avatarLarge = 80;
  static const double avatarXLarge = 120;

  // ── Elevation ────────────────────────────────────────────────────────────
  static const double elevationCard = 4;
  static const double elevationNone = 0;

  // ── Input field ───────────────────────────────────────────────────────────
  static const double inputHeight = 52;
  static const double inputBorderWidth = 1.5;

  // ── Color swatches ────────────────────────────────────────────────────────
  static const double colorSwatchSize = 20;
  static const double colorSwatchSpacing = 6;

  // ── Shimmer ───────────────────────────────────────────────────────────────
  static const double shimmerHeight = 16;
  static const double shimmerHeightLarge = 24;

  // ── POS split ─────────────────────────────────────────────────────────────
  static const double posLeftPanelFraction = 0.55;
  static const double posRightPanelFraction = 0.45;

  // ── Page padding ──────────────────────────────────────────────────────────
  static const double pagePaddingH = 16;
  static const double pagePaddingV = 16;

  // ── Thumbnail ─────────────────────────────────────────────────────────────
  static const double thumbnailSmall = 48;
  static const double thumbnailMedium = 72;
  static const double thumbnailLarge = 96;
}
