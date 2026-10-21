import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class TrendScreen extends StatelessWidget {
  const TrendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("혈당 추세", style: AppText.title()),
                    const SizedBox(height: 4),
                    Text(
                      "목표범위 ${appState.targetLow.toInt()}–${appState.targetHigh.toInt()} mg/dL",
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                child: const Text("표로 보기"),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              _filterChip("7일", false),
              const SizedBox(width: 8),
              _filterChip("14일", true),
              const SizedBox(width: 8),
              _filterChip("30일", false),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.border, strokeWidth: 1),
                        ),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: AppText.caption(color: AppColors.textMuted).copyWith(fontSize: 11),
                              ),
                            ),
                          ),
                          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        maxY: 250,
                        lineBarsData: [
                          LineChartBarData(
                            spots: appState.history.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value.value);
                            }).toList(),
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _legendItem(AppColors.statusSevere, "중증 저혈당"),
                      _legendItem(AppColors.statusLow, "저혈당"),
                      _legendItem(AppColors.statusNormal, "정상범위"),
                      _legendItem(AppColors.statusHigh, "고혈당"),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 5),
        Text(label, style: AppText.caption(color: AppColors.textSecondary)),
      ],
    );
  }
}
