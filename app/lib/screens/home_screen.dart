import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/glucose_status.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(appState.lastMeasuredTime);
    final status = GlucoseStatus.fromValue(appState.currentGlucose, appState.targetLow, appState.targetHigh);

    final history = appState.history;
    final inRange = history.where((r) => r.value >= appState.targetLow && r.value <= appState.targetHigh).length;
    final tirPercent = history.isEmpty ? 0 : ((inRange / history.length) * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hello, ${appState.patientName}", style: AppText.title()),
          const SizedBox(height: 4),
          Text("Check your latest reading and today's guidance.", style: AppText.body(color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          // Hero Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text("${appState.currentGlucose.toInt()}", style: AppText.hero(color: status.color)),
                            const SizedBox(width: 6),
                            Text("mg/dL", style: AppText.body(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(color: status.softColor, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(status.icon, color: status.color, size: 16),
                          const SizedBox(width: 5),
                          Text(status.label, style: TextStyle(color: status.color, fontSize: 13, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text("Measured $dateStr", style: AppText.caption(color: AppColors.textMuted)),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Timing: 1h 15m after eating · based on dinner",
                              style: AppText.caption(color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text("Your after-meal glucose is in range", style: AppText.sectionTitle()),
                      const SizedBox(height: 4),
                      Text(
                        "It's normal for glucose to rise somewhat after eating. This is within the after-meal target (under 180 mg/dL), so no action is needed right now.",
                        style: AppText.body(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Icon(Icons.timelapse_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text("Time in range (recent readings)", style: AppText.body(weight: FontWeight.w700)),
                    ),
                    Text("$tirPercent%", style: AppText.bodyStrong(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: tirPercent / 100,
                    minHeight: 10,
                    backgroundColor: AppColors.surfaceAlt,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),

                // Quick action — one tap straight to measuring or pen photo check
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => appState.setTabIndex(1),
                        icon: const Icon(Icons.water_drop_outlined),
                        label: const Text("Start New Measurement"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => appState.setTabIndex(5),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text("Check Insulin Pen with Camera"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Meal Logging Section
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
                Text("Meal Log", style: AppText.sectionTitle()),
                const SizedBox(height: 4),
                Text(
                  "Logging meal times lets the app tell fasting readings from after-meal readings automatically, for more accurate guidance.",
                  style: AppText.body(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _mealChip("Breakfast 08:00 · Remove"),
                    _mealChip("Lunch 12:30 · Remove"),
                    _mealChip("Dinner 18:30 · Remove"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _statCard("Readings, Last 7 Days", "16", "")),
              const SizedBox(width: 12),
              Expanded(child: _statCard("Alert Adherence (28d)", "75%", "3 done · 1 missed")),
              const SizedBox(width: 12),
              Expanded(child: _statCard("Next Scheduled Alert", "21:00", "Basal insulin")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mealChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }

  Widget _statCard(String title, String mainValue, String subText) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.caption(), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text(mainValue, style: AppText.sectionTitle()),
          if (subText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subText, style: AppText.caption(color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]
        ],
      ),
    );
  }
}
