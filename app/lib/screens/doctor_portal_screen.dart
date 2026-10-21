import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class DoctorPortalScreen extends StatelessWidget {
  const DoctorPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Row(
      children: [
        Container(
          width: 180,
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text("담당 환자 (3)", style: AppText.caption(color: AppColors.textMuted)),
              ),
              _patientTile("김민지", "2형 · 1985-03-12", true),
              _patientTile("이도현", "2형 · 1972-11-02", false),
              _patientTile("최서연", "1형 · 1990-05-27", false),
            ],
          ),
        ),
        const VerticalDivider(width: 1, color: AppColors.border),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("김민지", style: AppText.title()),
                const SizedBox(height: 2),
                Text("2형 · 여 · 1985-03-12", style: AppText.body(color: AppColors.textSecondary)),
                const SizedBox(height: 16),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _subTab("개요", 0, appState),
                      _subTab("추세", 1, appState),
                      _subTab("처방/계획", 2, appState),
                      _subTab("이행률", 3, appState),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(child: _getDoctorTabContent(appState)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _patientTile(String name, String sub, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (isSelected) const Icon(Icons.circle, color: AppColors.primary, size: 8),
            ],
          ),
          const SizedBox(height: 2),
          Text(sub, style: AppText.caption(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _subTab(String title, int index, AppState appState) {
    bool isSelected = appState.doctorSubTabIndex == index;
    return GestureDetector(
      onTap: () => appState.setDoctorSubTabIndex(index),
      child: Container(
        constraints: const BoxConstraints(minHeight: kMinTouchTarget),
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _getDoctorTabContent(AppState appState) {
    if (appState.doctorSubTabIndex == 3) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _doctorStat("이행률(28일)", "75%")),
              const SizedBox(width: 12),
              Expanded(child: _doctorStat("평균 응답 시간", "11분")),
              const SizedBox(width: 12),
              Expanded(child: _doctorStat("총 알림", "4건")),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("발생시각                상태                응답시간", style: AppText.caption(color: AppColors.textMuted)),
                const Divider(color: AppColors.border),
                _historyRow("2026-08-14 21:56", "이행", "6분"),
                _historyRow("2026-08-13 21:56", "이행", "22분"),
                _historyRow("2026-08-12 21:56", "미이행", "—"),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("최근 측정값", style: AppText.caption()),
                const SizedBox(height: 8),
                Text("${appState.currentGlucose.toInt()} mg/dL", style: AppText.hero(color: AppColors.statusHigh).copyWith(fontSize: 32)),
                Text("2026-08-16 19:45", style: AppText.caption(color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("목표 혈당범위 설정", style: AppText.caption()),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: appState.targetLow.toInt().toString(),
                        decoration: const InputDecoration(labelText: "저혈당 기준"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: appState.targetHigh.toInt().toString(),
                        decoration: const InputDecoration(labelText: "고혈당 기준"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("저장 (새 버전으로 이력 관리)"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _doctorStat(String title, String val) {
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
          Text(title, style: AppText.caption()),
          const SizedBox(height: 6),
          Text(val, style: AppText.sectionTitle().copyWith(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _historyRow(String time, String status, String resp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(time, style: AppText.body(color: AppColors.textSecondary)),
          Text(
            status,
            style: AppText.body(
              weight: FontWeight.w700,
              color: status == "이행" ? AppColors.statusNormal : AppColors.statusSevere,
            ),
          ),
          Text(resp, style: AppText.body(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
