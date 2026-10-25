import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Help tab — one button per patient screen. Tapping a button shows the
/// full explanatory text that was trimmed from that screen elsewhere in
/// the app (the screens themselves were simplified for a cleaner look,
/// but the full explanation is always available here).
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpTopic {
  final String title;
  final IconData icon;
  final String detail;
  const _HelpTopic({required this.title, required this.icon, required this.detail});
}

class _HelpScreenState extends State<HelpScreen> {
  static const List<_HelpTopic> _topics = [
    _HelpTopic(
      title: "Home",
      icon: Icons.home_outlined,
      detail: "Check your latest reading and today's guidance.\n\n"
          "It's normal for glucose to rise somewhat after eating. Being under 180 mg/dL after a meal is within the after-meal target, so no action is needed right now.\n\n"
          "Logging meal times lets the app tell fasting readings from after-meal readings automatically, for more accurate guidance.",
    ),
    _HelpTopic(
      title: "Measure",
      icon: Icons.water_drop_outlined,
      detail: "Analyzed on-device using the ear-clip sensor's 7-channel signal.",
    ),
    _HelpTopic(
      title: "Trend",
      icon: Icons.show_chart,
      detail: "The Glucose Trend screen charts your recent readings and lets you switch between 7, 14, and 30-day views. "
          "Use the \"View as Table\" button under the title to see the same readings listed as a table instead of a chart.",
    ),
    _HelpTopic(
      title: "Alerts",
      icon: Icons.notifications_none,
      detail: "The rapid-acting insulin dose alert is condition-based: it is sent when glucose has been 150 mg/dL or higher for 3 readings in a row.",
    ),
    _HelpTopic(
      title: "Food Guide",
      icon: Icons.rice_bowl,
      detail: "Foods within the same exchange unit have a similar effect on blood glucose and calories, so you can swap them freely.",
    ),
    _HelpTopic(
      title: "Pen Guide",
      icon: Icons.camera_alt_outlined,
      detail: "This is a trial (demo) stage, so the recognized result may differ from the actual product. Always follow your prescribed dose and method.",
    ),
    _HelpTopic(
      title: "My Info",
      icon: Icons.person_outline,
      detail: "The target glucose range is set by Dr. Jeonghwan Park (Endocrinology). Patients can view this, but only your clinician can change it.\n\n"
          "Guardian Alerts (SOS): if a dangerous low or high reading is detected, registered guardians are notified. A preview is available now.",
    ),
  ];

  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: _selectedIndex == null ? _buildMenu() : _buildDetail(_topics[_selectedIndex!]),
    );
  }

  Widget _buildMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Help", style: AppText.title()),
        const SizedBox(height: 6),
        Text(
          "Tap a screen to see its full explanation.",
          style: AppText.body(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView.separated(
              itemCount: _topics.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) => _helpButton(_topics[index], index),
            ),
          ),
        ),
      ],
    );
  }

  Widget _helpButton(_HelpTopic topic, int index) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => setState(() => _selectedIndex = index),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 76),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          alignment: Alignment.centerLeft,
        ),
        child: Row(
          children: [
            Icon(topic.icon, color: AppColors.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                topic.title,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 26),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(_HelpTopic topic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(topic.icon, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(topic.title, style: AppText.title())),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  topic.detail,
                  style: AppText.body(color: AppColors.textSecondary).copyWith(fontSize: 18, height: 1.5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _selectedIndex = null),
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 72)),
            icon: const Icon(Icons.arrow_back_rounded, size: 28),
            label: const Text(
              "Back",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
