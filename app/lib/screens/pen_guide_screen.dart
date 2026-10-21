import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/pen_classifier_service.dart';
import '../theme/app_theme.dart';
import '../theme/glucose_status.dart';

class PenGuideScreen extends StatefulWidget {
  const PenGuideScreen({super.key});

  @override
  State<PenGuideScreen> createState() => _PenGuideScreenState();
}

class _PenGuideScreenState extends State<PenGuideScreen> {
  final ImagePicker _picker = ImagePicker();
  final PenClassifierService _classifier = PenClassifierService();

  File? _capturedImage;
  PenRecognitionResult? _result;
  bool _isAnalyzing = false;
  String? _captureError;

  static const List<String> _manualPens = [
    "란투스 솔로스타",
    "노보래피드 플렉스타치",
    "휴마로그 콰트펜",
    "레버미어 플렉스타치",
    "투제오 솔로스타",
    "기타 / 목록에 없음",
  ];

  Future<void> _captureAndClassify() async {
    setState(() => _captureError = null);

    XFile? picked;
    try {
      picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    } catch (e) {
      setState(() => _captureError = "카메라를 열 수 없습니다. 설정에서 카메라 권한을 허용해주세요.");
      return;
    }
    if (picked == null) return; // 사용자가 촬영을 취소한 경우

    final file = File(picked.path);
    setState(() {
      _capturedImage = file;
      _result = null;
      _isAnalyzing = true;
    });

    final result = await _classifier.classify(file);
    if (!mounted) return;

    setState(() {
      _result = result;
      _isAnalyzing = false;
    });

    _runSafetyCheck(result);
  }

  void _selectManualPen(int index) {
    final result = PenRecognitionResult(
      productName: _manualPens[index],
      profile: index == _manualPens.length - 1
          ? InsulinActionProfile.unknown
          : InsulinActionProfile.rapidActing,
      confidence: 1,
    );
    setState(() {
      _result = result;
      _capturedImage = null;
    });
    _runSafetyCheck(result);
  }

  void _runSafetyCheck(PenRecognitionResult result) {
    final appState = Provider.of<AppState>(context, listen: false);
    final status = GlucoseStatus.fromValue(appState.currentGlucose, appState.targetLow, appState.targetHigh);

    final needsWarning = result.profile == InsulinActionProfile.rapidActing &&
        (status.level == GlucoseLevel.low || status.level == GlucoseLevel.severeLow);

    if (needsWarning) {
      _showSafetyAlert(appState.currentGlucose);
    } else {
      _showTutorialSheet(result);
    }
  }

  void _showSafetyAlert(double glucose) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.statusSevere, size: 26),
            const SizedBox(width: 10),
            Expanded(child: Text("투여 전 확인이 필요합니다", style: AppText.sectionTitle())),
          ],
        ),
        content: Text(
          "현재 혈당이 ${glucose.toInt()}mg/dL입니다. 이 상태에서 초속효성 인슐린을 투여하면 저혈당이 더 심해질 수 있습니다. 투여 전 담당 의료진에게 먼저 확인하세요.",
          style: AppText.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("확인했습니다"),
          ),
        ],
      ),
    );
  }

  void _showTutorialSheet(PenRecognitionResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _TutorialSheet(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("인슐린 펜 가이드", style: AppText.title()),
          const SizedBox(height: 6),
          Text("사진을 찍으면 펜 종류를 확인하고 사용법을 안내합니다.", style: AppText.body(color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildViewfinder(),
                const SizedBox(height: 16),
                if (_captureError != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.statusSevere, size: 18),
                      const SizedBox(width: 6),
                      Expanded(child: Text(_captureError!, style: AppText.body(color: AppColors.statusSevere))),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _captureAndClassify,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: Text(_isAnalyzing ? "분석 중입니다" : "사진 촬영하고 확인하기"),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "지금은 시험(데모) 단계로, 인식 결과가 실제 제품과 다를 수 있습니다. 투여량과 방법은 반드시 처방 내용을 따르세요.",
                  textAlign: TextAlign.center,
                  style: AppText.caption(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text("또는 목록에서 직접 선택하기", style: AppText.sectionTitle()),
          const SizedBox(height: 12),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _manualPens.length,
              itemBuilder: (context, index) {
                return OutlinedButton(
                  onPressed: () => _selectManualPen(index),
                  child: Text(
                    _manualPens[index],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewfinder() {
    if (_capturedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(_capturedImage!, fit: BoxFit.cover),
              if (_isAnalyzing)
                Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
              if (_result != null) _buildRecognitionOverlay(_result!),
            ],
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1.4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.center_focus_strong_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text("펜 전체가 보이도록 촬영해주세요", style: AppText.caption()),
          ],
        ),
      ),
    );
  }

  Widget _buildRecognitionOverlay(PenRecognitionResult result) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.productName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 2),
            Text("종류: ${result.profileLabel}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _TutorialSheet extends StatelessWidget {
  final PenRecognitionResult result;
  const _TutorialSheet({required this.result});

  static const List<String> _steps = [
    "주사 부위(복부, 허벅지, 팔 등)를 알코올 솜으로 소독합니다.",
    "펜 뚜껑을 열고 새 주사침을 똑바로 끼운 다음 보호 캡을 벗깁니다.",
    "처방받은 단위(Unit)에 다이얼을 맞춥니다.",
    "피부를 가볍게 잡고 90도로 찔러 넣은 뒤 버튼을 끝까지 누릅니다.",
    "그대로 10초 정도 센 뒤 바늘을 천천히 뺍니다.",
    "매번 주사 부위를 조금씩 바꿔가며 놓습니다. 같은 자리를 반복해서 놓지 않습니다.",
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(result.productName, style: AppText.title()),
              const SizedBox(height: 4),
              Text("${result.profileLabel} 인슐린 · 사용 방법 안내", style: AppText.body(color: AppColors.textSecondary)),
              const SizedBox(height: 16),

              // 영상 튜토리얼 자리.
              // 실제 영상 에셋이 준비되면 이 영역을 video_player(또는 chewie)
              // 위젯으로 교체하면 됩니다. README의 "영상 튜토리얼 추가 방법" 참고.
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_outline_rounded, size: 40, color: AppColors.textMuted),
                      const SizedBox(height: 6),
                      Text("영상 튜토리얼 준비 중", style: AppText.caption()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text("주사 순서", style: AppText.sectionTitle()),
              const SizedBox(height: 12),
              ..._steps.asMap().entries.map((e) => _StepRow(index: e.key + 1, text: e.value)),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("확인했습니다"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int index;
  final String text;
  const _StepRow({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: Text("$index", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppText.body())),
        ],
      ),
    );
  }
}
