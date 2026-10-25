import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class DoctorPortalScreen extends StatelessWidget {
  const DoctorPortalScreen({super.key});

  static const double _narrowBreakpoint = 640;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < _narrowBreakpoint;
        return isNarrow ? _buildNarrowLayout(appState) : _buildWideLayout(appState);
      },
    );
  }

  Widget _buildWideLayout(AppState appState) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                _buildSubTabRow(appState),
                const SizedBox(height: 20),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(child: _getDoctorTabContent(appState)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Stacked layout for narrow (phone-width) screens: patients become a
  /// horizontally-scrollable chip row up top, and everything below —
  /// including the detail content — scrolls vertically together, so
  /// nothing is ever forced to squeeze sideways or overflow.
  Widget _buildNarrowLayout(AppState appState) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My Patients (3)", style: AppText.caption(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _patientChip("Minji Kim", true),
                  const SizedBox(width: 8),
                  _patientChip("Dohyun Lee", false),
                  const SizedBox(width: 8),
                  _patientChip("Seoyeon Choi", false),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text("Minji Kim", style: AppText.title()),
            const SizedBox(height: 2),
            Text("Type 2 · Female · 1985-03-12", style: AppText.body(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            _buildSubTabRow(appState),
            const SizedBox(height: 20),
            _getDoctorTabContent(appState),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTabRow(AppState appState) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _subTab("Overview", 0, appState),
          _subTab("Trend", 1, appState),
          _subTab("Prescription/Plan", 2, appState),
          _subTab("Adherence", 3, appState),
        ],
      ),
    );
  }

  Widget _patientChip(String name, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primarySoft : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: AppText.body(
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              weight: FontWeight.w700,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 6),
            const Icon(Icons.circle, color: AppColors.primary, size: 8),
          ],
        ],
      ),
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

  /// Lays out [children] side by side when there's enough width, and
  /// stacks them vertically otherwise, so stat/detail cards never get
  /// squeezed into unreadable, overflowing slivers on a narrow screen.
  Widget _responsiveRow(List<Widget> children, {double minColumnWidth = 160, double spacing = 12}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fitsInRow = constraints.maxWidth >= minColumnWidth * children.length + spacing * (children.length - 1);
        if (fitsInRow) {
          final rowChildren = <Widget>[];
          for (var i = 0; i < children.length; i++) {
            if (i > 0) rowChildren.add(SizedBox(width: spacing));
            rowChildren.add(Expanded(child: children[i]));
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: rowChildren);
        }
        final columnChildren = <Widget>[];
        for (var i = 0; i < children.length; i++) {
          if (i > 0) columnChildren.add(SizedBox(height: spacing));
          columnChildren.add(children[i]);
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: columnChildren);
      },
    );
  }

  Widget _getDoctorTabContent(AppState appState) {
    if (appState.doctorSubTabIndex == 3) {
      return Column(
        children: [
          _responsiveRow([
            _doctorStat("Adherence (28d)", "75%"),
            _doctorStat("Avg. Response Time", "11 min"),
            _doctorStat("Total Alerts", "4"),
          ], minColumnWidth: 130),
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
                      child: Text("Time", style: AppText.caption(color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
                    ),
                    Expanded(child: Text("Status", style: AppText.caption(color: AppColors.textMuted), overflow: TextOverflow.ellipsis)),
                    Expanded(child: Text("Response Time", style: AppText.caption(color: AppColors.textMuted), overflow: TextOverflow.ellipsis, maxLines: 1)),
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

    return _responsiveRow([
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
            Text("Most Recent Reading", style: AppText.caption()),
            const SizedBox(height: 8),
            Text("${appState.currentGlucose.toInt()} mg/dL", style: AppText.hero(color: AppColors.statusHigh).copyWith(fontSize: 32)),
            Text("2026-08-16 19:45", style: AppText.caption(color: AppColors.textMuted)),
          ],
        ),
      ),
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
    ], minColumnWidth: 220);
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
          Text(title, style: AppText.caption(), overflow: TextOverflow.ellipsis, maxLines: 1),
          const SizedBox(height: 6),
          Text(val, style: AppText.sectionTitle().copyWith(fontSize: 24), overflow: TextOverflow.ellipsis, maxLines: 1),
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
            child: Text(time, style: AppText.body(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis, maxLines: 1),
          ),
          Expanded(
            child: Text(
              status,
              style: AppText.body(
                weight: FontWeight.w700,
                color: status == "Completed" ? AppColors.statusNormal : AppColors.statusSevere,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            child: Text(resp, style: AppText.body(color: AppColors.textSecondary), overflow: TextOverflow.ellipsis, maxLines: 1),
          ),
        ],
      ),
    );
  }
}
