import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class DoctorPortalScreen extends StatelessWidget {
  const DoctorPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Row(
      children: [
        // Doctor Patient Selection Sidebar
        Container(
          width: 180,
          color: const Color(0xFF0F1816),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "담당 환자 (3)",
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ),
              _patientTile("김민지", "2형 · 1985-03-12", true),
              _patientTile("이도현", "2형 · 1972-11-02", false),
              _patientTile("최서연", "1형 · 1990-05-27", false),
            ],
          ),
        ),
        const VerticalDivider(width: 1, color: Color(0xFF23322E)),

        // Doctor Detail Body
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "김민지",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "2형 · 여 · 1985-03-12",
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Doctor Sub-Tabs (개요, 추세, 처방/계획, 이행률)
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
        color: isSelected ? const Color(0xFF1B3B32) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 환자 이름이 길어지면 옆의 점 아이콘과 겹쳐 넘칠 수 있어 Expanded로 방어
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.circle, color: Colors.amber, size: 8),
            ],
          ),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _subTab(String title, int index, AppState appState) {
    bool isSelected = appState.doctorSubTabIndex == index;
    return GestureDetector(
      onTap: () => appState.setDoctorSubTabIndex(index),
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF26B089) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF26B089) : Colors.white60,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _getDoctorTabContent(AppState appState) {
    if (appState.doctorSubTabIndex == 3) {
      // 이행률 View
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
              color: const Color(0xFF16221F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "발생시각                상태                응답시간",
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const Divider(color: Color(0xFF23322E)),
                _historyRow("2026-08-14 21:56", "이행", "6분"),
                _historyRow("2026-08-13 21:56", "이행", "22분"),
                _historyRow("2026-08-12 21:56", "미이행", "—"),
              ],
            ),
          ),
        ],
      );
    }

    // Default Overview View
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16221F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("최근 측정값", style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 8),
                Text(
                  "${appState.currentGlucose.toInt()} mg/dL",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const Text("2026-08-16 19:45", style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16221F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("목표 혈당범위 설정", style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: appState.targetLow.toInt().toString(),
                        decoration: const InputDecoration(
                          labelText: "저혈당 기준",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: appState.targetHigh.toInt().toString(),
                        decoration: const InputDecoration(
                          labelText: "고혈당 기준",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26B089),
                  ),
                  child: const Text(
                    "저장 (새 버전으로 이력 관리)",
                    style: TextStyle(color: Colors.black),
                  ),
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
        color: const Color(0xFF16221F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 6),
          Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
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
          Text(time, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(
            status,
            style: TextStyle(
              color: status == "이행" ? Colors.greenAccent : Colors.redAccent,
              fontSize: 12,
            ),
          ),
          Text(resp, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}