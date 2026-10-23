import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Food Exchange Guide", style: AppText.title()),
          const SizedBox(height: 4),
          Text(
            "Foods within the same exchange unit have a similar effect on blood glucose and calories, so you can swap them freely.",
            style: AppText.body(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's Intake Log", style: AppText.caption()),
                const SizedBox(height: 4),
                Text("0 / 1800kcal", style: AppText.sectionTitle()),
                const SizedBox(height: 12),
                _unitRow("Grains", "0 / 8 units"),
                _unitRow("Meat & Fish", "0 / 6 units"),
                _unitRow("Vegetables", "0 / 8 units"),
                _unitRow("Fats", "0 / 5 units"),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: AppText.body(),
                        decoration: const InputDecoration(
                          hintText: "Enter a food name (e.g. apple, rice)",
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: kMinTouchTarget,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text("Add"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _unitRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.body()),
          Text(value, style: AppText.caption(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
