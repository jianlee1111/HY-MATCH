// Lightweight, code-only "micro-animations" for the Pen Guide tutorial.
// These need no image/video assets, so they work as a sensible default
// right away. When a real video is added for a step (see
// pen_tutorial_steps.dart's `videoAssetPath`), that video is shown
// instead — see _StepVideo below.
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../data/pen_tutorial_steps.dart';

/// Picks the right visual for a tutorial step: a video if one is set for
/// this step, otherwise the matching built-in icon animation.
class StepMedia extends StatelessWidget {
  final TutorialStep step;
  final Color color;

  const StepMedia({super.key, required this.step, required this.color});

  @override
  Widget build(BuildContext context) {
    if (step.videoAssetPath != null) {
      return _StepVideo(assetPath: step.videoAssetPath!, fallbackIcon: step.icon, color: color);
    }
    switch (step.animation) {
      case StepAnimation.rotate:
        return _RotatingIcon(icon: step.icon, color: color);
      case StepAnimation.pulse:
        return _PulsingIcon(icon: step.icon, color: color);
      case StepAnimation.countdown:
        return _CountdownRing(icon: step.icon, color: color);
      case StepAnimation.none:
        return _StaticIcon(icon: step.icon, color: color);
    }
  }
}

const double _kMediaSize = 140;

class _StaticIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _StaticIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return _mediaCircle(color: color, child: Icon(icon, size: 64, color: color));
  }
}

class _RotatingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  const _RotatingIcon({required this.icon, required this.color});

  @override
  State<_RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<_RotatingIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _mediaCircle(
      color: widget.color,
      child: RotationTransition(
        turns: _controller,
        child: Icon(widget.icon, size: 64, color: widget.color),
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  const _PulsingIcon({required this.icon, required this.color});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
        ..repeat(reverse: true);
  late final Animation<double> _scale = Tween(begin: 0.85, end: 1.1).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _mediaCircle(
      color: widget.color,
      child: ScaleTransition(
        scale: _scale,
        child: Icon(widget.icon, size: 64, color: widget.color),
      ),
    );
  }
}

class _CountdownRing extends StatefulWidget {
  final IconData icon;
  final Color color;
  const _CountdownRing({required this.icon, required this.color});

  @override
  State<_CountdownRing> createState() => _CountdownRingState();
}

class _CountdownRingState extends State<_CountdownRing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kMediaSize,
      height: _kMediaSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final secondsLeft = (10 - (_controller.value * 10)).ceil().clamp(1, 10);
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: _kMediaSize,
                height: _kMediaSize,
                child: CircularProgressIndicator(
                  value: _controller.value,
                  strokeWidth: 6,
                  backgroundColor: widget.color.withValues(alpha: 0.15),
                  color: widget.color,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 36, color: widget.color),
                  const SizedBox(height: 4),
                  Text(
                    "${secondsLeft}s",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: widget.color),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _mediaCircle({required Color color, required Widget child}) {
  return Container(
    width: _kMediaSize,
    height: _kMediaSize,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.12)),
    alignment: Alignment.center,
    child: child,
  );
}

/// Plays a looping, muted-by-default local video asset for a step. Falls
/// back to the static icon if the asset fails to load (e.g. it hasn't
/// been added to pubspec.yaml yet).
class _StepVideo extends StatefulWidget {
  final String assetPath;
  final IconData fallbackIcon;
  final Color color;
  const _StepVideo({required this.assetPath, required this.fallbackIcon, required this.color});

  @override
  State<_StepVideo> createState() => _StepVideoState();
}

class _StepVideoState extends State<_StepVideo> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final controller = VideoPlayerController.asset(widget.assetPath);
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      if (mounted) setState(() => _controller = controller);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || _controller == null) {
      return _StaticIcon(icon: widget.fallbackIcon, color: widget.color);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}
