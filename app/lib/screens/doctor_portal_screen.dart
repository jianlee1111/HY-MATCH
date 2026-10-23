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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text("My Patients (3)", style: AppText.caption(color: AppColors.textMuted)),
                ),
                _patientTile("Minji Kim", "Type 2 · 1985-03-12", true),
                _patientTile("Dohyun Lee", "Type 2 · 1972-11-02", false),
                _patientTile("Seoyeon Choi", "Type 1 · 1990-05-27", false),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1, color: AppColors.border),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Minji Kim", style: AppText.title()),
                const SizedBox(height: 2),
                Text("Type 2 · Female · 1985-03-12", style: AppText.body(color: AppColors.textSecondary)),
                const SizedBox(height: 16),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _subTab("Overview", 0, appState),
                      _subTab("Trend", 1, appState),
                      _subTab("Prescription/Plan", 2, appState),
                      _subTab("Adherence", 3, appState),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(child: SingleChildScrollView(child: _getDoctorTabContent(appState))),
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
    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => appState.setDoctorSubTabIndex(index),
          child: Container(
            constraints: const BoxConstraints(minHeight: kMinTouchTarget),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
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
              Expanded(child: _doctorStat("Adherence (28d)", "75%")),
              const SizedBox(width: 12),
              Expanded(child: _doctorStat("Avg. Response Time", "11 min")),
              const SizedBox(width: 12),
              Expanded(child: _doctorStat("Total Alerts", "4")),
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
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text("Time", style: AppText.caption(color: AppColors.textMuted)),
                    ),
                    Expanded(child: Text("Status", style: AppText.caption(color: AppColors.textMuted))),
                    Expanded(child: Text("Response Time", style: AppText.caption(color: AppColors.textMuted))),
                  ],
                ),
                const Divider(color: AppColors.border),
                _historyRow("2026-08-14 21:56", "Completed", "6 min"),
                _historyRow("2026-08-13 21:56", "Completed", "22 min"),
                _historyRow("2026-08-12 21:56", "Missed", "—"),
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
                Text("Most Recent Reading", style: AppText.caption()),
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
                Text("Set Target Glucose Range", style: AppText.caption()),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: appState.targetLow.toInt().toString(),
                        decoration: const InputDecoration(labelText: "Low Threshold"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: appState.targetHigh.toInt().toString(),
                        decoration: const InputDecoration(labelText: "High Threshold"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Save (tracked as a new version)"),
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
        children: [
          Expanded(
            flex: 3,
            child: Text(time, style: AppText.body(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              status,
              style: AppText.body(
                weight: FontWeight.w700,
                color: status == "Completed" ? AppColors.statusNormal : AppColors.statusSevere,
              ),
            ),
          ),
          Expanded(
            child: Text(resp, style: AppText.body(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
