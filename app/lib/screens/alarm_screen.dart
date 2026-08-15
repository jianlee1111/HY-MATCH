import 'package:flutter/material.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("용량조절 알림", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          const Text("담당 의료진이 설정한 계획에 따라 알림을 받습니다.", style: TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 20),

          _alarmCard("기저 인슐린 · 12U", "매일 21:00", "정기"),
          const SizedBox(height: 12),
          _alarmCard("속효 인슐린 · 4U", "최근 3회 연속 혈당이 150mg/dL 이상일 때", "조건기반"),
          const SizedBox(height: 24),

          const Text("알림 이력", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
        color: const Color(0xFF16221F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF23322E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF1F3B32), borderRadius: BorderRadius.circular(8)),
                child: Text(tag, style: const TextStyle(color: Color(0xFF26B089), fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white38)),
            child: const Text("지금 알림 시뮬레이션 (데모)", style: TextStyle(color: Colors.white, fontSize: 11)),
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
        color: const Color(0xFF16221F),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
              Text(time, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: const TextStyle(color: Colors.greenAccent, fontSize: 11)),
          )
        ],
      ),
    );
  }
}
