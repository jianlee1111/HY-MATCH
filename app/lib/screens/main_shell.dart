import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/glucose_status.dart';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeaderBar(context, appState),
            _buildStatusWarningBanner(context, appState),
            Expanded(
              child: Row(
                children: [
                  _buildSidebar(context, appState),
                  const VerticalDivider(width: 1, color: AppColors.border),
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
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Text(
            "시험(데모) 버전 — 실제 기기·서버와 연동되지 않았습니다. 측정값과 안내 문구는 모두 예시이며 의료 자문이 아닙니다.",
            style: AppText.caption(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: Text(
                  "HY-MATCH",
                  style: AppText.sectionTitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              _buildConnectionChip(appState.isDeviceConnected),
              const Spacer(),
              OutlinedButton(
                onPressed: () {
                  appState.resetDemoData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("데모 데이터를 초기 상태로 되돌렸습니다.")),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text("초기화"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _roleButton("환자 화면", 0, appState)),
              const SizedBox(width: 8),
              Expanded(child: _roleButton("의료진 화면", 1, appState)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionChip(bool connected) {
    final color = connected ? AppColors.primary : AppColors.textMuted;
    final bg = connected ? AppColors.primarySoft : AppColors.surfaceAlt;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            connected ? Icons.bluetooth_connected_rounded : Icons.bluetooth_disabled_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            connected ? "센서 연결됨" : "센서 연결 안 됨",
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
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
        constraints: const BoxConstraints(minHeight: kMinTouchTarget),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusWarningBanner(BuildContext context, AppState appState) {
    final status = GlucoseStatus.fromValue(appState.currentGlucose, appState.targetLow, appState.targetHigh);
    if (status.level == GlucoseLevel.normal) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: status.softColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(status.icon, color: status.color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "현재 상태: ${status.label} (${appState.currentGlucose.toInt()} mg/dL) — 대응 방법 확인하기",
              style: TextStyle(color: status.color, fontWeight: FontWeight.w700, fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_rounded, color: status.color, size: 18),
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
      {'icon': Icons.camera_alt_outlined, 'label': '펜가이드'},
      {'icon': Icons.person_outline, 'label': '내정보'},
    ];

    return Container(
      width: 148,
      color: AppColors.surface,
      child: ListView.builder(
        itemCount: navItems.length,
        itemBuilder: (context, index) {
          bool isSelected = (appState.currentRoleMode == 0) && (appState.selectedTabIndex == index);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  appState.setRoleMode(0);
                  appState.setTabIndex(index);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  child: Row(
                    children: [
                      Icon(
                        navItems[index]['icon'] as IconData,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          navItems[index]['label'] as String,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
