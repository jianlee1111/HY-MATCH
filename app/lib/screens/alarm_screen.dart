import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("용량조절 알림", style: AppText.title()),
          const SizedBox(height: 4),
          Text("담당 의료진이 설정한 계획에 따라 알림을 받습니다.", style: AppText.body(color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          _alarmCard("기저 인슐린 · 12U", "매일 21:00", "정기"),
          const SizedBox(height: 12),
          _alarmCard("속효 인슐린 · 4U", "최근 3회 연속 혈당이 150mg/dL 이상일 때", "조건기반"),
          const SizedBox(height: 24),

          Text("알림 이력", style: AppText.sectionTitle()),
          const SizedBox(height: 12),
          _historyTile("기저 인슐린 용량조절 알림", "2026-08-14 21:56", "이행 완료"),
          _historyTile("기저 인슐린 용량조절 알림", "2026-08-13 21:56", "이행 완료"),
        ],
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
                child: Text(tag, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: AppText.caption(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
              child: const Text(
                "알림 미리보기 (데모)",
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
