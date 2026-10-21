import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class MyInfoScreen extends StatelessWidget {
  const MyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("내 정보", style: AppText.title()),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _infoTile("이름", appState.patientName)),
                    const SizedBox(width: 12),
                    Expanded(child: _infoTile("당뇨 유형", appState.diabetesType)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _infoTile("생년월일", appState.birthDate)),
                    const SizedBox(width: 12),
                    Expanded(child: _infoTile("등록일", appState.regDate)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("목표 혈당범위", style: AppText.caption()),
                const SizedBox(height: 6),
                Text(
                  "${appState.targetLow.toInt()}–${appState.targetHigh.toInt()} mg/dL",
                  style: AppText.sectionTitle(),
                ),
                const SizedBox(height: 8),
                Text(
                  "박정환 선생님(내분비내과)이 설정했습니다. 환자는 조회만 할 수 있고, 수정은 담당 의료진만 가능합니다.",
                  style: AppText.caption(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _GuardianSection(appState: appState),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.caption()),
        const SizedBox(height: 4),
        Text(value, overflow: TextOverflow.ellipsis, style: AppText.bodyStrong()),
      ],
    );
  }
}

/// 보호자 알림(SOS) — 보호자 등록과 알림 미리보기까지 제공합니다.
/// 실제 발송은 백엔드 연동이 필요해 이 버전에는 포함되어 있지 않습니다.
class _GuardianSection extends StatelessWidget {
  final AppState appState;
  const _GuardianSection({required this.appState});

  void _openAddGuardianDialog(BuildContext context) {
    final nameController = TextEditingController();
    final relationController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("보호자 등록"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "이름")),
            const SizedBox(height: 10),
            TextField(controller: relationController, decoration: const InputDecoration(labelText: "관계 (예: 자녀, 배우자)")),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "전화번호"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("취소")),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) return;
              appState.addGuardian(
                GuardianContact(
                  name: nameController.text.trim(),
                  relation: relationController.text.trim().isEmpty ? "보호자" : relationController.text.trim(),
                  phone: phoneController.text.trim(),
                ),
              );
              Navigator.of(ctx).pop();
            },
            child: const Text("등록하기"),
          ),
        ],
      ),
    );
  }

  void _openPreviewDialog(BuildContext context, GuardianContact guardian) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("알림 미리보기"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${guardian.name}님(${guardian.relation})에게 아래와 같은 알림이 전송될 예정입니다.",
              style: AppText.body(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.statusSevereSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notifications_active_rounded, color: AppColors.statusSevere),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "[HY-MATCH] ${appState.patientName}님의 혈당이 54mg/dL로 위험 범위입니다. 확인이 필요합니다.",
                      style: AppText.body(weight: FontWeight.w600, color: AppColors.statusSevere),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "지금은 미리보기만 제공되며, 실제 알림 발송은 아직 지원하지 않습니다.",
              style: AppText.caption(color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("닫기")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guardians = appState.guardians;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_border_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text("보호자 알림 (SOS)", style: AppText.sectionTitle())),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "저혈당·고혈당 위험 수치가 감지되면 등록된 보호자에게 알림을 보냅니다. 지금은 미리보기까지 제공됩니다.",
            style: AppText.body(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          if (guardians.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text("등록된 보호자가 없습니다.", style: AppText.body(color: AppColors.textMuted)),
            )
          else
            ...guardians.asMap().entries.map((entry) {
              final index = entry.key;
              final guardian = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${guardian.name} · ${guardian.relation}", style: AppText.bodyStrong()),
                          Text(guardian.phone, style: AppText.caption(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => _openPreviewDialog(context, guardian),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                      child: const Text("미리보기"),
                    ),
                    IconButton(
                      onPressed: () => appState.removeGuardian(index),
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _openAddGuardianDialog(context),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text("보호자 등록하기"),
            ),
          ),
        ],
      ),
    );
  }
}
