// 앱 전체에서 공유하는 색상·타이포그래피 토큰.
// 색상/글자 크기를 화면마다 따로 정의하지 않고 여기서만 바꾸면
// 전체 앱에 일관되게 반영되도록 하기 위한 파일입니다.
//
// 디자인 방향: 고령 사용자 가독성을 1순위로 둔 고대비·라이트 테마.
// - 배경은 눈부심이 적은 저채도 아이보리, 글자는 짙은 차콜(순검정 아님).
// - 상태(정상/저혈당/고혈당)는 색상 단독이 아니라 색 + 아이콘 + 텍스트로 항상 함께 표기.
// - 그라데이션·글로우·과도한 둥근 모서리 같은 장식 요소는 배제.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFFF7F5F0);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF0EEE6);
  // WCAG 1.4.11(Non-text Contrast, AA, 3:1) 충족: 배경/서피스 대비 각각 3.06:1 / 3.34:1.
  static const border = Color(0xFF8F8778);

  static const textPrimary = Color(0xFF1C211E);
  static const textSecondary = Color(0xFF52584F);
  // WCAG 1.4.3(Contrast Minimum, AA, 일반 텍스트 4.5:1) 충족: 이 색이 실제로 쓰이는
  // 모든 배경(background/surface/surfaceAlt/primarySoft) 각각에서 4.5:1 이상.
  static const textMuted = Color(0xFF656A62);

  static const primary = Color(0xFF1F6F52);
  static const primarySoft = Color(0xFFDDEDE3);
  static const onPrimary = Color(0xFFFFFFFF);

  // 아래 네 상태 색은 각자의 Soft 배경, 그리고 흰색 surface 위에서 모두
  // 4.5:1 이상(WCAG 1.4.3 AA, 일반 텍스트)이 되도록 보정한 값입니다.
  // 뱃지/칩처럼 작은 글자에 그대로 쓰이기 때문에 "큰 텍스트" 완화 기준(3:1)을 적용하지 않았습니다.

  // 정상 범위 — soft 대비 4.55:1, 흰색 대비 5.39:1
  static const statusNormal = Color(0xFF2C784C);
  static const statusNormalSoft = Color(0xFFDFF0E4);

  // 저혈당(경계) — soft 대비 4.53:1, 흰색 대비 5.42:1
  static const statusLow = Color(0xFFAB4F18);
  static const statusLowSoft = Color(0xFFFBE7D8);

  // 고혈당(경계) — soft 대비 4.52:1, 흰색 대비 5.29:1
  static const statusHigh = Color(0xFF8E6400);
  static const statusHighSoft = Color(0xFFF7EDCF);

  // 중증 저혈당(위험) — soft 대비 4.57:1, 흰색 대비 5.90:1
  static const statusSevere = Color(0xFFC02727);
  static const statusSevereSoft = Color(0xFFF8DCDC);
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

/// 모든 탭 가능 영역의 최소 크기(접근성 가이드 기준 48dp 이상).
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
