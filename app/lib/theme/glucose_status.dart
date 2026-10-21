// 혈당 수치 -> (라벨, 색상, 아이콘) 매핑을 한 곳에서 관리합니다.
// 색상만으로 상태를 구분하지 않고 항상 아이콘 + 텍스트를 함께 쓰기 위한 목적이며,
// 홈 화면 히어로 카드, 상단 경고 배너, 추세 화면 범례가 모두 이 매핑을 공유합니다.
import 'package:flutter/material.dart';
import 'app_theme.dart';

enum GlucoseLevel { severeLow, low, normal, high }

class GlucoseStatus {
  final GlucoseLevel level;
  final String label;
  final Color color;
  final Color softColor;
  final IconData icon;

  const GlucoseStatus._(
    this.level,
    this.label,
    this.color,
    this.softColor,
    this.icon,
  );

  static const double severeLowThreshold = 54;

  factory GlucoseStatus.fromValue(double value, double targetLow, double targetHigh) {
    if (value < severeLowThreshold) {
      return const GlucoseStatus._(
        GlucoseLevel.severeLow,
        '중증 저혈당',
        AppColors.statusSevere,
        AppColors.statusSevereSoft,
        Icons.emergency_rounded,
      );
    }
    if (value < targetLow) {
      return const GlucoseStatus._(
        GlucoseLevel.low,
        '저혈당',
        AppColors.statusLow,
        AppColors.statusLowSoft,
        Icons.arrow_downward_rounded,
      );
    }
    if (value > targetHigh) {
      return const GlucoseStatus._(
        GlucoseLevel.high,
        '고혈당',
        AppColors.statusHigh,
        AppColors.statusHighSoft,
        Icons.arrow_upward_rounded,
      );
    }
    return const GlucoseStatus._(
      GlucoseLevel.normal,
      '정상 범위',
      AppColors.statusNormal,
      AppColors.statusNormalSoft,
      Icons.check_circle_rounded,
    );
  }
}
