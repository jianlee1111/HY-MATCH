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
            "Trial (demo) version — not connected to a real device or server. All readings and guidance shown are examples, not medical advice.",
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
                    const SnackBar(content: Text("Demo data has been reset.")),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text("Reset"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _roleButton("Patient View", 0, appState)),
              const SizedBox(width: 8),
              Expanded(child: _roleButton("Clinician View", 1, appState)),
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
            connected ? "Sensor Connected" : "Sensor Disconnected",
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _roleButton(String title, int roleIndex, AppState appState) {
    bool isSelected = appState.currentRoleMode == roleIndex;
    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => appState.setRoleMode(roleIndex),
          child: Container(
            constraints: const BoxConstraints(minHeight: kMinTouchTarget),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
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
              "Current status: ${status.label} (${appState.currentGlucose.toInt()} mg/dL) — see what to do",
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
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': Icons.water_drop_outlined, 'label': 'Measure'},
      {'icon': Icons.show_chart, 'label': 'Trend'},
      {'icon': Icons.notifications_none, 'label': 'Alerts'},
      {'icon': Icons.apple_outlined, 'label': 'Food Guide'},
      {'icon': Icons.camera_alt_outlined, 'label': 'Pen Guide'},
      {'icon': Icons.person_outline, 'label': 'My Info'},
    ];

    return Container(
      width: 148,
      color: AppColors.surface,
      child: ListView.builder(
        itemCount: navItems.length,
        itemBuilder: (context, index) {
          bool isSelected = (appState.currentRoleMode == 0) && (appState.selectedTabIndex == index);
          final label = navItems[index]['label'] as String;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: Semantics(
                button: true,
                selected: isSelected,
                label: label,
                excludeSemantics: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    appState.setRoleMode(0);
                    appState.setTabIndex(index);
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: kMinTouchTarget),
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
                              label,
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
