import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("식품교환표", style: AppText.title()),
          const SizedBox(height: 4),
          Text(
            "같은 교환단위 안의 식품은 서로 바꿔 먹어도 혈당·칼로리에 미치는 영향이 비슷합니다.",
            style: AppText.body(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("오늘 섭취 기록", style: AppText.caption()),
                const SizedBox(height: 4),
                Text("0 / 1800kcal", style: AppText.sectionTitle()),
                const SizedBox(height: 12),
                _unitRow("곡류군", "0 / 8단위"),
                _unitRow("어육류군", "0 / 6단위"),
                _unitRow("채소군", "0 / 8단위"),
                _unitRow("지방군", "0 / 5단위"),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: AppText.body(),
                        decoration: const InputDecoration(
                          hintText: "음식 이름 입력 (예: 사과, 쌀밥)",
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: kMinTouchTarget,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text("추가하기"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _unitRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.body()),
          Text(value, style: AppText.caption(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
