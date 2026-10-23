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
          Text("My Info", style: AppText.title()),
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
                    Expanded(child: _infoTile("Name", appState.patientName)),
                    const SizedBox(width: 12),
                    Expanded(child: _infoTile("Diabetes Type", appState.diabetesType)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _infoTile("Date of Birth", appState.birthDate)),
                    const SizedBox(width: 12),
                    Expanded(child: _infoTile("Registered", appState.regDate)),
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
                Text("Target Glucose Range", style: AppText.caption()),
                const SizedBox(height: 6),
                Text(
                  "${appState.targetLow.toInt()}–${appState.targetHigh.toInt()} mg/dL",
                  style: AppText.sectionTitle(),
                ),
                const SizedBox(height: 8),
                Text(
                  "Set by Dr. Jeonghwan Park (Endocrinology). Patients can view this but only your clinician can change it.",
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

/// Guardian alerts (SOS) — supports registering a guardian and previewing
/// what an alert would say. Real delivery needs a backend and isn't
/// included in this version.
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
        title: const Text("Add Guardian"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            const SizedBox(height: 10),
            TextField(controller: relationController, decoration: const InputDecoration(labelText: "Relationship (e.g. child, spouse)")),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) return;
              appState.addGuardian(
                GuardianContact(
                  name: nameController.text.trim(),
                  relation: relationController.text.trim().isEmpty ? "Guardian" : relationController.text.trim(),
                  phone: phoneController.text.trim(),
                ),
              );
              Navigator.of(ctx).pop();
            },
            child: const Text("Add"),
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
        title: const Text("Alert Preview"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${guardian.name} (${guardian.relation}) will receive an alert like this.",
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
                      "[HY-MATCH] ${appState.patientName}'s glucose is 54 mg/dL, a danger-range reading. Please check on them.",
                      style: AppText.body(weight: FontWeight.w600, color: AppColors.statusSevere),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "This is a preview only — sending real alerts isn't supported yet.",
              style: AppText.caption(color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Close")),
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
              Expanded(child: Text("Guardian Alerts (SOS)", style: AppText.sectionTitle())),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "If a dangerous low or high reading is detected, registered guardians are notified. A preview is available now.",
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
              child: Text("No guardians have been added yet.", style: AppText.body(color: AppColors.textMuted)),
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
                      child: const Text("Preview"),
                    ),
                    IconButton(
                      onPressed: () => appState.removeGuardian(index),
                      tooltip: "Remove guardian ${guardian.name}",
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openAddGuardianDialog(context),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text("Add a Guardian"),
            ),
          ),
        ],
      ),
    );
  }
}
