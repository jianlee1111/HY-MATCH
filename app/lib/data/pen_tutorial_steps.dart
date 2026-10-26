// Step-by-step injection instructions, sourced from the manufacturer's
// patient brochure ("펜형 인슐린 주사법" — BD embecta). A copy of the
// source content lives in the project's docs for reference.
//
// Video mapping (assets/pen_tutorial/<n>.mp4), as confirmed by the user:
//   0  = mixing/rolling step (intermediate-acting / premixed only)
//   1  = open the pen cap
//   2  = disinfect the rubber membrane
//   3  = attach the needle (remove seal, align straight)
//   4  = screw the needle clockwise until tight
//   5  = remove both the outer and inner caps
//   6  = dial 1-2 units, point up, tap 3-4 times
//   7  = press the button, confirm a drop appears
//   8  = dial to the prescribed dose
//   9  = double-check the dose
//   10 = clean the site and let it dry
//   11 = insert the needle and hold 10+ seconds
//   12 = remove the needle and dispose of it safely
//   13 = cap the pen and store it
// "Choose an injection site" has no video (site selection is just a
// choice, not a filmable action) and "don't let the needle bend"
// caution text from the brochure was intentionally left out, per the
// user's instruction.
import 'package:flutter/material.dart';
import '../services/pen_classifier_service.dart';

enum StepAnimation { none, rotate, pulse, countdown }

class TutorialStep {
  final String title;
  final String body;
  final IconData icon;
  final StepAnimation animation;

  /// Path to this step's looping video asset (declared under
  /// flutter/assets in pubspec.yaml). Null for the one step that has no
  /// video — the built-in icon animation is shown instead.
  final String? videoAssetPath;

  const TutorialStep({
    required this.title,
    required this.body,
    required this.icon,
    this.animation = StepAnimation.none,
    this.videoAssetPath,
  });
}

const TutorialStep _rollStep = TutorialStep(
  title: 'Mix the insulin',
  body: 'Gently roll the pen between your palms and tilt it up and down until the liquid looks evenly cloudy. '
      "Don't shake it hard, and don't use it if clumps remain.",
  icon: Icons.autorenew_rounded,
  animation: StepAnimation.rotate,
  videoAssetPath: 'assets/pen_tutorial/0.mp4',
);

const List<TutorialStep> _baseSteps = [
  TutorialStep(
    title: 'Choose an injection site',
    body: 'Pick a site: the abdomen, the thigh, or the outer side of the upper arm.',
    icon: Icons.accessibility_new_rounded,
  ),
  TutorialStep(
    title: 'Open the pen cap',
    body: 'Remove the cap from the insulin pen.',
    icon: Icons.lock_open_rounded,
    videoAssetPath: 'assets/pen_tutorial/1.mp4',
  ),
  TutorialStep(
    title: 'Disinfect the rubber membrane',
    body: "Clean the pen's rubber membrane with an alcohol swab.",
    icon: Icons.clean_hands_rounded,
    videoAssetPath: 'assets/pen_tutorial/2.mp4',
  ),
  TutorialStep(
    title: 'Attach the needle',
    body: "Remove the needle's paper seal, then line it up straight with the pen and attach it.",
    icon: Icons.align_vertical_center_rounded,
    videoAssetPath: 'assets/pen_tutorial/3.mp4',
  ),
  TutorialStep(
    title: 'Screw the needle on',
    body: 'Turn the needle clockwise until it is fully tightened.',
    icon: Icons.sync_rounded,
    animation: StepAnimation.rotate,
    videoAssetPath: 'assets/pen_tutorial/4.mp4',
  ),
  TutorialStep(
    title: 'Remove both needle caps',
    body: 'Take off both the outer cap and the inner (green) cap.',
    icon: Icons.remove_circle_outline_rounded,
    videoAssetPath: 'assets/pen_tutorial/5.mp4',
  ),
  TutorialStep(
    title: 'Run a safety check',
    body: 'Dial to 1–2 units, point the needle upward, and tap the pen 3–4 times.',
    icon: Icons.touch_app_rounded,
    animation: StepAnimation.pulse,
    videoAssetPath: 'assets/pen_tutorial/6.mp4',
  ),
  TutorialStep(
    title: 'Confirm a drop appears',
    body: 'Press the injection button fully and confirm a drop of insulin appears at the needle tip.',
    icon: Icons.water_drop_outlined,
    animation: StepAnimation.pulse,
    videoAssetPath: 'assets/pen_tutorial/7.mp4',
  ),
  TutorialStep(
    title: 'Set your dose',
    body: 'Turn the dial to your prescribed number of units.',
    icon: Icons.tune_rounded,
    videoAssetPath: 'assets/pen_tutorial/8.mp4',
  ),
  TutorialStep(
    title: 'Double-check your dose',
    body: 'Check the number on the dial again before injecting.',
    icon: Icons.fact_check_outlined,
    videoAssetPath: 'assets/pen_tutorial/9.mp4',
  ),
  TutorialStep(
    title: 'Clean the site',
    body: 'Clean the injection site with an alcohol swab and let it dry.',
    icon: Icons.clean_hands_rounded,
    videoAssetPath: 'assets/pen_tutorial/10.mp4',
  ),
  TutorialStep(
    title: 'Inject',
    body: 'Insert the needle straight into the skin, press the button fully, and hold for at least 10 seconds.',
    icon: Icons.vaccines_rounded,
    animation: StepAnimation.countdown,
    videoAssetPath: 'assets/pen_tutorial/11.mp4',
  ),
  TutorialStep(
    title: 'Remove the needle',
    body: 'Put the outer cap back on the needle, twist it off counter-clockwise, and dispose of it in a sharps container.',
    icon: Icons.delete_outline_rounded,
    videoAssetPath: 'assets/pen_tutorial/12.mp4',
  ),
  TutorialStep(
    title: 'Store the pen',
    body: 'Cap the pen and store it at room temperature.',
    icon: Icons.kitchen_outlined,
    videoAssetPath: 'assets/pen_tutorial/13.mp4',
  ),
];

/// Builds the full step list for a pen, inserting the mixing step first
/// when [needsRolling] is true (intermediate-acting / premixed pens).
List<TutorialStep> buildTutorialSteps({required bool needsRolling}) {
  return needsRolling ? [_rollStep, ..._baseSteps] : _baseSteps;
}
