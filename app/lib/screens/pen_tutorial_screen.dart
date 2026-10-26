import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../data/pen_tutorial_steps.dart';
import '../theme/app_theme.dart';
import '../widgets/step_animations.dart';

/// Step-by-step usage tutorial: one step per page, Next/Previous to move
/// between them, and an optional spoken read-out of each step via TTS.
class PenTutorialScreen extends StatefulWidget {
  final String productName;
  final Color categoryColor;
  final List<TutorialStep> steps;

  const PenTutorialScreen({
    super.key,
    required this.productName,
    required this.categoryColor,
    required this.steps,
  });

  @override
  State<PenTutorialScreen> createState() => _PenTutorialScreenState();
}

class _PenTutorialScreenState extends State<PenTutorialScreen> {
  final PageController _pageController = PageController();
  final FlutterTts _tts = FlutterTts();

  int _currentIndex = 0;
  bool _voiceEnabled = true;
  bool _ttsReady = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      _ttsReady = true;
      _speakCurrentStep();
    } catch (_) {
      _ttsReady = false;
    }
  }

  Future<void> _speakCurrentStep() async {
    if (!_ttsReady || !_voiceEnabled) return;
    final step = widget.steps[_currentIndex];
    await _tts.stop();
    await _tts.speak("Step ${_currentIndex + 1}. ${step.title}. ${step.body}");
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.steps;
    final isLast = _currentIndex == steps.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "${widget.productName} — Usage Guide",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Semantics(
            button: true,
            label: _voiceEnabled ? "Voice guidance on, tap to mute" : "Voice guidance off, tap to unmute",
            child: IconButton(
              onPressed: () {
                setState(() => _voiceEnabled = !_voiceEnabled);
                if (_voiceEnabled) {
                  _speakCurrentStep();
                } else {
                  _tts.stop();
                }
              },
              icon: Icon(_voiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded),
              tooltip: _voiceEnabled ? "Mute voice guidance" : "Turn on voice guidance",
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressDots(steps.length),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: steps.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  _speakCurrentStep();
                },
                itemBuilder: (context, index) => _buildStepPage(steps[index], index),
              ),
            ),
            _buildNavBar(isLast, steps.length),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDots(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final isActive = i == _currentIndex;
          return Container(
            width: isActive ? 14 : 10,
            height: isActive ? 14 : 10,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? widget.categoryColor : AppColors.border,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepPage(TutorialStep step, int index) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Text(
              "Step ${index + 1} of ${widget.steps.length}",
              style: AppText.caption(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            StepMedia(step: step, color: widget.categoryColor),
            const SizedBox(height: 24),
            Text(
              step.title,
              textAlign: TextAlign.center,
              style: AppText.title().copyWith(fontSize: 24),
            ),
            const SizedBox(height: 14),
            Text(
              step.body,
              textAlign: TextAlign.center,
              style: AppText.body(color: AppColors.textSecondary).copyWith(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _speakCurrentStep,
              icon: const Icon(Icons.replay_rounded),
              label: const Text("Read this step aloud again"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(bool isLast, int stepCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        children: [
          if (_currentIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 72)),
                onPressed: () => _goTo(_currentIndex - 1),
                icon: const Icon(Icons.arrow_back_rounded, size: 26),
                label: const Text("Previous", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
          if (_currentIndex > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 72)),
              onPressed: () {
                if (isLast) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } else {
                  _goTo(_currentIndex + 1);
                }
              },
              icon: Icon(isLast ? Icons.check_rounded : Icons.arrow_forward_rounded, size: 26),
              label: Text(
                isLast ? "Finish" : "Next",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
