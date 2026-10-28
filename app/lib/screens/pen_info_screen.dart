import 'package:flutter/material.dart';
import '../data/pen_info.dart';
import '../data/pen_tutorial_steps.dart';
import '../services/pen_classifier_service.dart';
import '../theme/app_theme.dart';
import 'pen_tutorial_screen.dart';

/// Shown right after a pen is recognized or picked: usage timing and
/// storage, then a button into the step-by-step tutorial.
class PenInfoScreen extends StatelessWidget {
  final PenRecognitionResult result;
  const PenInfoScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final profile = result.profile;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(result.productName, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: profile.softColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: profile.color),
                  ),
                  child: Text(
                    profile.categoryLabel,
                    style: TextStyle(color: profile.color, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 20),

                _infoCard(
                  icon: Icons.schedule_rounded,
                  title: 'When to Inject',
                  body: profile.timingText,
                  color: profile.color,
                ),
                const SizedBox(height: 16),
                _infoCard(
                  icon: Icons.kitchen_outlined,
                  title: 'How to Store It',
                  body: kInsulinStorageText,
                  color: AppColors.primary,
                ),
                if (profile.needsRolling) ...[
                  const SizedBox(height: 16),
                  _infoCard(
                    icon: Icons.autorenew_rounded,
                    title: 'Before You Inject',
                    body: 'This type needs to be mixed first. The usage guide below starts with that step.',
                    color: AppColors.statusHigh,
                  ),
                ],
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 72)),
                    onPressed: () {
                      final steps = buildTutorialSteps(needsRolling: profile.needsRolling);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PenTutorialScreen(
                            productName: result.productName,
                            categoryColor: profile.color,
                            steps: steps,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book_rounded, size: 26),
                    label: const Text(
                      "View Usage Instructions",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard({required IconData icon, required String title, required String body, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: AppText.sectionTitle())),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: AppText.body(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
