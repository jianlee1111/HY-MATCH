// Per-category reference info for the Pen Guide screen, sourced from the
// manufacturer's own patient brochure ("펜형 인슐린 주사법" /
// "내가 맞는 인슐린은 무엇일까요?" — BD embecta). A copy of that content
// lives in the project's docs for reference.
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/pen_classifier_service.dart';

extension PenCategoryInfo on InsulinActionProfile {
  String get categoryLabel {
    switch (this) {
      case InsulinActionProfile.longActing:
        return 'Long-acting';
      case InsulinActionProfile.rapidActing:
        return 'Rapid-acting';
      case InsulinActionProfile.intermediateActing:
        return 'Intermediate-acting';
      case InsulinActionProfile.premixed:
        return 'Premixed';
      case InsulinActionProfile.unknown:
        return 'Type unconfirmed';
    }
  }

  Color get color {
    switch (this) {
      case InsulinActionProfile.longActing:
        return AppColors.penLongActing;
      case InsulinActionProfile.rapidActing:
        return AppColors.penRapidActing;
      case InsulinActionProfile.intermediateActing:
        return AppColors.penIntermediateActing;
      case InsulinActionProfile.premixed:
        return AppColors.penPremixed;
      case InsulinActionProfile.unknown:
        return AppColors.textMuted;
    }
  }

  Color get softColor {
    switch (this) {
      case InsulinActionProfile.longActing:
        return AppColors.penLongActingSoft;
      case InsulinActionProfile.rapidActing:
        return AppColors.penRapidActingSoft;
      case InsulinActionProfile.intermediateActing:
        return AppColors.penIntermediateActingSoft;
      case InsulinActionProfile.premixed:
        return AppColors.penPremixedSoft;
      case InsulinActionProfile.unknown:
        return AppColors.surfaceAlt;
    }
  }

  /// When during the day/meal cycle this type is typically injected.
  String get timingText {
    switch (this) {
      case InsulinActionProfile.longActing:
        return 'Once a day, at the same time every day.';
      case InsulinActionProfile.rapidActing:
        return '15 minutes to right before a meal (breakfast, lunch, and dinner).';
      case InsulinActionProfile.intermediateActing:
        return '30 minutes before a meal (breakfast, lunch, and dinner).';
      case InsulinActionProfile.premixed:
        return '15–30 minutes before a meal, or once a day depending on the product — check your prescription.';
      case InsulinActionProfile.unknown:
        return 'Check your prescription label or ask your clinician for the exact timing.';
    }
  }

  /// Whether this type needs to be rolled/mixed before each injection.
  bool get needsRolling =>
      this == InsulinActionProfile.intermediateActing || this == InsulinActionProfile.premixed;
}

/// Storage guidance — the same for every insulin type per the brochure.
const String kInsulinStorageText =
    'Unopened insulin: store in the refrigerator (2–8°C).\n'
    'Insulin currently in use: store at room temperature (check the product\'s own instructions).\n'
    'Flying? Always carry your insulin in your carry-on bag.';
