import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(appState.lastMeasuredTime);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "안녕하세요, ${appState.patientName}님",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text("최근 측정과 오늘의 안내를 확인하세요.", style: TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 20),

          // Main Glucose Status Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF16221F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF23322E)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 큰 숫자(48sp) + "mg/dL" + 배지가 한 줄에 다 안 들어가 넘치던 부분
                    // -> Flexible + FittedBox로 감싸서 공간이 부족하면 숫자 쪽이 자동으로 줄어들게 함
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "${appState.currentGlucose.toInt()}",
                              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.amber),
                            ),
                            const SizedBox(width: 6),
                            const Text("mg/dL", style: TextStyle(color: Colors.white70, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.amber, size: 8),
                          SizedBox(width: 4),
                          Text("고혈당", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                Text("$dateStr 측정", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 16),

                // Guide Sub-Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1816),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: const [
                          Icon(Icons.circle, color: Color(0xFF26B089), size: 8),
                          SizedBox(width: 6),
                          Text("측정 시점: ", style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Text("식후 1시간 15분", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(" · 저녁 식사 기준", style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B3B32),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text("식후 목표(180 미만) 이내", style: TextStyle(color: Color(0xFF26B089), fontSize: 11)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "식후 혈당은 정상 범위입니다",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "식사 후 혈당은 어느 정도 오르는 것이 자연스럽습니다. ADA 식후 목표(180 mg/dL 미만) 이내이므로 특별한 조치가 필요하지 않습니다.",
                        style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => appState.setTabIndex(1), // Go to Measure tab
                    icon: const Icon(Icons.water_drop_outlined, color: Colors.black),
                    label: const Text("새 측정 시작", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26B089),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
              color: const Color(0xFF16221F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF23322E)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("식사 기록", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                const Text(
                  "식사 시각을 기록해두면 측정값이 공복인지 식후인지 자동으로 구분해 더 알맞은 안내를 보여드려요.",
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _mealChip("아침 08:00 x"),
                    _mealChip("점심 12:30 x"),
                    _mealChip("저녁 18:30 x"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Stats Grid
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1F3B32),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF26B089), fontSize: 12)),
    );
  }

  Widget _statCard(String title, String mainValue, String subText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16221F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF23322E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 8),
          Text(mainValue, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          if (subText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subText, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ]
        ],
      ),
    );
  }
}