import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Dose Adjustment Alerts", style: AppText.title()),
          const SizedBox(height: 4),
          Text("You'll be notified according to the plan your clinician set up.", style: AppText.body(color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          _alarmCard("Basal insulin · 12U", "Daily at 21:00", "Scheduled"),
          const SizedBox(height: 12),
          _alarmCard("Rapid-acting insulin · 4U", "", "Condition-based"),
          const SizedBox(height: 24),

          Text("Alert History", style: AppText.sectionTitle()),
          const SizedBox(height: 12),
          _historyTile("Basal insulin dose adjustment alert", "2026-08-14 21:56", "Completed"),
          _historyTile("Basal insulin dose adjustment alert", "2026-08-13 21:56", "Completed"),
        ],
      ),
      ),
    );
  }

  Widget _alarmCard(String title, String subtitle, String tag) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(title, overflow: TextOverflow.ellipsis, style: AppText.bodyStrong()),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(8)),
                child: Text(tag, style: const TextStyle(color: AppColors.primaryText, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(subtitle, style: AppText.caption(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
              child: const Text(
                "Preview Alert (Demo)",
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyTile(String title, String time, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, overflow: TextOverflow.ellipsis, style: AppText.body(weight: FontWeight.w600)),
                Text(time, style: AppText.caption(color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.statusNormalSoft, borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.statusNormal),
                const SizedBox(width: 4),
                Text(status, style: const TextStyle(color: AppColors.statusNormal, fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
