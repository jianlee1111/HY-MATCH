import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'home_screen.dart';
import 'measure_screen.dart';
import 'trend_screen.dart';
import 'alarm_screen.dart';
import 'food_screen.dart';
import 'pen_guide_screen.dart';
import 'my_info_screen.dart';
import 'doctor_portal_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar (Demo Banner, Mode Switcher, Reset)
            _buildTopHeaderBar(context, appState),
            
            // Status Warning Bar
            _buildStatusWarningBanner(context, appState),

            // Main Area (Sidebar + Content Body)
            Expanded(
              child: Row(
                children: [
                  // Left Navigation Drawer / Sidebar
                  _buildSidebar(context, appState),
                  const VerticalDivider(width: 1, color: Color(0xFF23322E)),
                  
                  // Main Screen Body according to active tab or mode
                  Expanded(
                    child: appState.currentRoleMode == 1
                        ? const DoctorPortalScreen()
                        : _getPatientScreen(appState.selectedTabIndex),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeaderBar(BuildContext context, AppState appState) {
    return Container(
      color: const Color(0xFF0B1210),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          const Text(
            "프로토타입 데모 — 실제 기기·서버와 연동되지 않았습니다. 측정값·판정·가이드 문구는 시뮬레이션이며 실제 의료 자문이 아닙니다.",
            style: TextStyle(color: Colors.grey, fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.circle, color: Color(0xFF26B089), size: 10),
              const SizedBox(width: 8),
              const Text(
                "HY-MATCH",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(width: 6),
              const Text("자가관리 앱 프로토타입", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const Spacer(),
              // Patient App / Medical Portal Switcher
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2825),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _roleButton("환자 앱", 0, appState),
                    _roleButton("의료진 포털", 1, appState),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  appState.resetDemoData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("데모 데이터가 초기화되었습니다.")),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text("데모 초기화", style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roleButton(String title, int roleIndex, AppState appState) {
    bool isSelected = appState.currentRoleMode == roleIndex;
    return GestureDetector(
      onTap: () => appState.setRoleMode(roleIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF26B089) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusWarningBanner(BuildContext context, AppState appState) {
    bool isHigh = appState.currentGlucose > appState.targetHigh;
    if (!isHigh) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: const Color(0xFF332912), // Warning Dark Yellow
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.circle, color: Colors.amber, size: 10),
          const SizedBox(width: 8),
          Text(
            "현재 상태: 고혈당 (${appState.currentGlucose.toInt()} mg/dL) — 대응 가이드 보기",
            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward, color: Colors.amber, size: 16),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AppState appState) {
    final navItems = [
      {'icon': Icons.home_outlined, 'label': '홈'},
      {'icon': Icons.water_drop_outlined, 'label': '측정'},
      {'icon': Icons.show_chart, 'label': '추세'},
      {'icon': Icons.notifications_none, 'label': '알림'},
      {'icon': Icons.apple_outlined, 'label': '식품표'},
      {'icon': Icons.cleaning_services_outlined, 'label': '펜가이드'},
      {'icon': Icons.person_outline, 'label': '내정보'},
    ];

    return Container(
      width: 140,
      color: const Color(0xFF0B1210),
      child: ListView.builder(
        itemCount: navItems.length,
        itemBuilder: (context, index) {
          bool isSelected = (appState.currentRoleMode == 0) && (appState.selectedTabIndex == index);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1B3B32) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              dense: true,
              leading: Icon(
                navItems[index]['icon'] as IconData,
                color: isSelected ? const Color(0xFF26B089) : Colors.white60,
                size: 20,
              ),
              title: Text(
                navItems[index]['label'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              onTap: () {
                appState.setRoleMode(0); // Switch to patient app mode
                appState.setTabIndex(index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _getPatientScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const MeasureScreen();
      case 2:
        return const TrendScreen();
      case 3:
        return const AlarmScreen();
      case 4:
        return const FoodScreen();
      case 5:
        return const PenGuideScreen();
      case 6:
        return const MyInfoScreen();
      default:
        return const HomeScreen();
    }
  }
}
