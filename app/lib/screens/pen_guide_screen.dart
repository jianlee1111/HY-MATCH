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

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }

  // The 13 products the model can recognize, plus an "Other" option. Each
  // product's action profile matches the _parentToProfile mapping in
  // pen_classifier_service.dart.
  static const List<MapEntry<String, InsulinActionProfile>> _manualPens = [
    MapEntry("NovoRapid", InsulinActionProfile.rapidActing),
    MapEntry("Apidra", InsulinActionProfile.rapidActing),
    MapEntry("Humalog", InsulinActionProfile.rapidActing),
    MapEntry("Lantus", InsulinActionProfile.longActing),
    MapEntry("Levemir", InsulinActionProfile.longActing),
    MapEntry("Toujeo", InsulinActionProfile.longActing),
    MapEntry("Tresiba", InsulinActionProfile.longActing),
    MapEntry("Humulin N", InsulinActionProfile.intermediateActing),
    MapEntry("NovoMix 30", InsulinActionProfile.premixed),
    MapEntry("NovoMix 50", InsulinActionProfile.premixed),
    MapEntry("Humalog Mix 25", InsulinActionProfile.premixed),
    MapEntry("Humalog Mix 50", InsulinActionProfile.premixed),
    MapEntry("Humulin 70/30", InsulinActionProfile.premixed),
    MapEntry("Other / Not Listed", InsulinActionProfile.unknown),
  ];

  Future<void> _captureAndClassify() async {
    setState(() => _captureError = null);

    XFile? picked;
    try {
      picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    } catch (e) {
      setState(() => _captureError = "Couldn't open the camera. Please allow camera access in Settings.");
      return;
    }
    if (picked == null) return; // User canceled the capture

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
    final entry = _manualPens[index];
    final result = PenRecognitionResult(
      productName: entry.key,
      profile: entry.value,
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

    // Premixed insulin (which contains a rapid-acting component) is also
    // taken before meals, so it gets the same warning as rapid-acting.
    final isMealtimeDose = result.profile == InsulinActionProfile.rapidActing ||
        result.profile == InsulinActionProfile.premixed;
    final needsWarning = isMealtimeDose &&
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
            Expanded(child: Text("Check before you inject", style: AppText.sectionTitle())),
          ],
        ),
        content: Text(
          "Your current glucose is ${glucose.toInt()} mg/dL. Taking rapid-acting insulin now could make a low reading worse. Please check with your clinician before injecting.",
          style: AppText.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Got it"),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Insulin Pen Guide", style: AppText.title()),
          const SizedBox(height: 6),
          Text("Take a photo to identify your pen and see how to use it.", style: AppText.body(color: AppColors.textSecondary)),
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
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _captureAndClassify,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: Text(_isAnalyzing ? "Analyzing" : "Take a Photo to Check"),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "This is a trial (demo) stage, so the recognized result may differ from the actual product. Always follow your prescribed dose and method.",
                  textAlign: TextAlign.center,
                  style: AppText.caption(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text("Or Choose From the List", style: AppText.sectionTitle()),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _manualPens.length,
            itemBuilder: (context, index) {
              return OutlinedButton(
                onPressed: () => _selectManualPen(index),
                child: Text(
                  _manualPens[index].key,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
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
            Text("Frame the whole pen in the shot", style: AppText.caption()),
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
            Text("Type: ${result.profileLabel}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
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
    "Disinfect the injection site (abdomen, thigh, arm, etc.) with an alcohol swab.",
    "Remove the pen cap, attach a new needle straight on, then remove its protective cap.",
    "Dial up to your prescribed dose (in Units).",
    "Pinch the skin gently, insert the needle at 90 degrees, and press the button all the way down.",
    "Hold for about 10 seconds, then slowly withdraw the needle.",
    "Rotate injection sites slightly each time — avoid repeating the same spot.",
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
              Text("${result.profileLabel} insulin · how to use it", style: AppText.body(color: AppColors.textSecondary)),
              const SizedBox(height: 16),

              // Placeholder for a video tutorial.
              // Once a real video asset is ready, replace this area with a
              // video_player (or chewie) widget. See the README section
              // "Adding a video tutorial" for details.
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
                      Text("Video tutorial coming soon", style: AppText.caption()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text("Injection Steps", style: AppText.sectionTitle()),
              const SizedBox(height: 12),
              ..._steps.asMap().entries.map((e) => _StepRow(index: e.key + 1, text: e.value)),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Got it"),
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
