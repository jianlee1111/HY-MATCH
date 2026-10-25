// Maps a glucose value -> (label, color, icon) in one place.
// The goal is to never rely on color alone to show status — color +
// icon + text are always shown together. The home hero card, the top
// warning banner, and the trend screen legend all share this mapping.
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
        'Severe Low',
        AppColors.statusSevere,
        AppColors.statusSevereSoft,
        Icons.emergency_rounded,
      );
    }
    if (value < targetLow) {
      return const GlucoseStatus._(
        GlucoseLevel.low,
        'Low',
        AppColors.statusLow,
        AppColors.statusLowSoft,
        Icons.arrow_downward_rounded,
      );
    }
    if (value > targetHigh) {
      return const GlucoseStatus._(
        GlucoseLevel.high,
        'High',
        AppColors.statusHigh,
        AppColors.statusHighSoft,
        Icons.arrow_upward_rounded,
      );
    }
    return const GlucoseStatus._(
      GlucoseLevel.normal,
      'In Range',
      AppColors.statusNormal,
      AppColors.statusNormalSoft,
      Icons.check_circle_rounded,
    );
  }
}
