// Shared color and typography tokens for the whole app.
// Centralized here (instead of per-screen) so a single change stays
// consistent everywhere.
//
// Design direction: a bold, saturated, modern palette that still meets
// WCAG 2.2 AA contrast for older users with lower-vision/low-contrast-
// sensitivity eyes. This also follows the senior-UX design guideline
// "스마트 시니어 세대의 문화향유를 위한 인지 반응 맞춤형 UI/UX 기술 개발"
// (고려대학교 외, 문화체육관광부·한국콘텐츠진흥원, 2018) — see its
// GB1-GB4 (색채,배색) sections specifically. Key points applied below:
//   1. Older users prefer vivid/saturated, high-brightness colors over
//      pale/desaturated ones (GB4) — hence the vivid, saturated brand
//      color (fixed to the requested #D2691E).
//   2. Two color-confusion pairs are flagged by this guideline's user
//      testing: yellow-green vs. reddish-brown (~33% of senior
//      participants couldn't reliably distinguish them) and yellow vs.
//      blue (~59%) (GB2). The status colors are chosen to keep clear
//      hue separation from both pairs, AND from the brand color itself.
//   3. Status is never color-only: every status is always shown as
//      color + icon + text together (GB2, "정보 전달을 위해 컬러뿐만
//      아니라 패턴, 질감, 텍스트 등의 요소를 사용해야 한다") — see
//      glucose_status.dart.
//   4. Every accent color is checked against every background it is
//      actually used on (surface/background/surfaceAlt/its own soft
//      tint) and kept at >=4.5:1 for normal/bold-under-14pt text (WCAG
//      1.4.3) or >=3:1 for large/bold-14pt+ text and icons/borders
//      (WCAG 1.4.11). Ratios verified below with a standalone sRGB/
//      relative-luminance/contrast-ratio script so a future palette
//      change can be re-verified the same way.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFFF4F5F3);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFECEEEA);
  // WCAG 1.4.11 (Non-text Contrast, AA, 3:1): >=4.1:1 against every
  // background it's used on.
  static const border = Color(0xFF6B7280);

  static const textPrimary = Color(0xFF171A19);
  static const textSecondary = Color(0xFF4B5048);
  // >=4.5:1 against background/surface/surfaceAlt/primarySoft.
  static const textMuted = Color(0xFF686D64);

  // Brand color, fixed to the requested #D2691E (vivid burnt-orange).
  // Verified: 3.63:1 vs. white/background/surfaceAlt — this clears the
  // 3:1 bar (WCAG 1.4.11) for icons, borders, selected-state fills, and
  // bold text at 14pt+ (e.g. the 17pt bold button label), but NOT the
  // 4.5:1 bar normal/small-bold text needs. Use `primary` only for
  // those large/non-text cases.
  static const primary = Color(0xFFD2691E);
  // Same hue/saturation as `primary`, darkened so it clears 4.5:1 on
  // every background used (white 5.53:1, background 5.06:1, surfaceAlt
  // 4.74:1, primarySoft 4.71:1). Use this instead of `primary` for any
  // small or non-bold text/badge that is colored with the brand hue
  // (e.g. chip labels, step-number badges, the role-toggle's selected
  // label) — this is exactly where raw `primary` would fail AA.
  static const primaryText = Color(0xFFA45217);
  static const primarySoft = Color(0xFFF9EAE0);
  static const onPrimary = Color(0xFFFFFFFF);

  // Normal range — vivid green. >=4.5:1 on all backgrounds used. Hue is
  // ~117° from the brand color, so no confusion risk.
  static const statusNormal = Color(0xFF117C38);
  static const statusNormalSoft = Color(0xFFE6F5EA);

  // Low (caution) — moved from orange-red to a vivid blue. The brand
  // color is now a saturated orange-brown (hue ~25°); the old orange-red
  // "Low" color (hue ~21°) would have sat almost on top of it, which is
  // exactly the kind of hue clash GB2 warns against. Blue (hue ~215°) is
  // maximally separated from the brand color, from statusHigh (~56°),
  // and from statusSevere (~0°). >=4.98:1 on all backgrounds used,
  // including its own soft tint.
  static const statusLow = Color(0xFF1D60BF);
  static const statusLowSoft = Color(0xFFE0EAF9);

  // High (caution) — dark golden-yellow, ~31° of hue from the brand
  // color and far from the yellow-green/reddish-brown confusion pair
  // this guideline's testing flagged (GB2). >=5.7:1 everywhere.
  static const statusHigh = Color(0xFF645E09);
  static const statusHighSoft = Color(0xFFF7EFDD);

  // Severe low (danger) — vivid red. >=4.5:1 everywhere. Always paired
  // with a warning icon + the word "Severe" so it never relies on hue
  // alone to read as more urgent than the brand color.
  static const statusSevere = Color(0xFFD12222);
  static const statusSevereSoft = Color(0xFFFCE8E8);

  // Insulin-pen action-type category colors (Pen Guide screen only).
  // These exist so a pen's button border/icon can be color-coded by
  // category at a glance, with a legend shown above the buttons — they
  // are decorative/non-text accents (icon + border), so the WCAG 1.4.11
  // non-text bar of 3:1 applies, verified >=3.3:1 against every
  // background used below. Hues are spread far from each other and from
  // `primary`/the status colors so none of the two palettes is
  // confusable with the other (GB2).
  static const penLongActing = Color(0xFF572BD9); // indigo
  static const penLongActingSoft = Color(0xFFE1DAF7);
  static const penRapidActing = Color(0xFF1C8C83); // teal
  static const penRapidActingSoft = Color(0xFFDAF7F5);
  static const penIntermediateActing = Color(0xFFAD2BD9); // purple-magenta
  static const penIntermediateActingSoft = Color(0xFFF0DAF7);
  static const penPremixed = Color(0xFFD92B57); // rose
  static const penPremixedSoft = Color(0xFFF7DAE1);
}

class AppText {
  AppText._();

  static TextStyle hero({Color? color}) => TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
        height: 1.0,
      );

  static TextStyle title({Color? color}) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle sectionTitle({Color? color}) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle body({Color? color, FontWeight? weight}) => TextStyle(
        fontSize: 16,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle bodyStrong({Color? color}) =>
      body(color: color, weight: FontWeight.w700);

  static TextStyle caption({Color? color}) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle button({Color? color}) => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.onPrimary,
      );
}

/// Minimum size for every tappable area (WCAG 2.5.5 Target Size
/// Enhanced, AAA, is 44x44 — this app uses a larger 52dp floor).
const double kMinTouchTarget = 52;

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.statusSevere,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),
    dividerColor: AppColors.border,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.border,
        minimumSize: const Size(64, kMinTouchTarget),
        textStyle: AppText.button(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size(64, kMinTouchTarget),
        side: const BorderSide(color: AppColors.border, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppText.body(weight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(48, kMinTouchTarget),
        textStyle: AppText.body(weight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      labelStyle: AppText.caption(),
    ),
  );
}
