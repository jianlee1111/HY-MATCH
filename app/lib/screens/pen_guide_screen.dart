import 'package:flutter/material.dart';

class PenGuideScreen extends StatelessWidget {
  const PenGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pens = [
      "란투스 솔로스타",
      "노보래피드 플렉스타치",
      "휴마로그 콰트펜",
      "레버미어 플렉스타치",
      "투제오 솔로스타",
      "기타 / 목록에 없음"
    ];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("인슐린 펜 가이드", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          const Text("카메라로 촬영하면 펜 종류를 자동으로 인식합니다.", style: TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF16221F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF23322E)),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt, color: Colors.black),
                    label: const Text("카메라로 인식하기", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26B089)),
                  ),
                ),
                const SizedBox(height: 8),
                const Text("데모: 실제 이미지 인식 모델이 아닌 시뮬레이션 결과입니다.", style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text("또는 목록에서 직접 선택", style: TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 12),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: pens.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF16221F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF23322E)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cleaning_services_outlined, color: Color(0xFF26B089), size: 20),
                      const SizedBox(height: 4),
                      Text(pens[index], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
