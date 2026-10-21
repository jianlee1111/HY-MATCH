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
          Text("안녕하세요, ${appState.patientName}님", style: AppText.title()),
          const SizedBox(height: 4),
          Text("최근 측정과 오늘의 안내를 확인하세요.", style: AppText.body(color: AppColors.textSecondary)),
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
                Text("$dateStr 측정", style: AppText.caption(color: AppColors.textMuted)),
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
                              "측정 시점: 식후 1시간 15분 · 저녁 식사 기준",
                              style: AppText.caption(color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text("식후 혈당은 정상 범위입니다", style: AppText.sectionTitle()),
                      const SizedBox(height: 4),
                      Text(
                        "식사 후 혈당은 어느 정도 오르는 것이 자연스럽습니다. 식후 목표(180 mg/dL 미만) 이내이므로 지금은 별도 조치가 필요하지 않습니다.",
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
                      child: Text("최근 측정 중 목표범위 내 비율", style: AppText.body(weight: FontWeight.w700)),
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

                // Quick Action — 원터치로 바로 측정 또는 펜 촬영으로 이동
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () => appState.setTabIndex(1),
                          icon: const Icon(Icons.water_drop_outlined),
                          label: const Text("새 혈당 측정 시작"),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => appState.setTabIndex(5),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text("인슐린 펜 사진으로 확인하기"),
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
                Text("식사 기록", style: AppText.sectionTitle()),
                const SizedBox(height: 4),
                Text(
                  "식사 시각을 기록해두면 측정값이 공복인지 식후인지 자동으로 구분해 더 알맞은 안내를 보여드립니다.",
                  style: AppText.body(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _mealChip("아침 08:00 삭제"),
                    _mealChip("점심 12:30 삭제"),
                    _mealChip("저녁 18:30 삭제"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _statCard("최근 7일 측정", "16회", "")),
              const SizedBox(width: 12),
              Expanded(child: _statCard("알림 이행률(28일)", "75%", "3건 이행 · 1건 미이행")),
              const SizedBox(width: 12),
              Expanded(child: _statCard("다음 정기 알림", "21:00", "기저 인슐린")),
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
