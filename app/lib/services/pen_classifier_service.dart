// Insulin pen image classification service.
//
// Uses a MobileNetV2-based 2-head classifier (assets/insulin_classifier.tflite,
// trained in Insulin_Classifier.ipynb):
//   - sub_output (13 classes): the specific product.
//   - parent_output (4 classes): the action-timing category
//     (long-acting / intermediate-acting / rapid-acting / premixed).
//
// Label order must exactly match the training notebook's
// `sorted(list(set(y_sub_labels)))` / `sorted(list(set(y_parent_labels)))`
// output (that output was Korean product/category names — English display
// names below are listed in the exact same positions). If the model is
// retrained/reconverted, re-check this list against the notebook's output.
//
// Important: the compiled .tflite file's actual output order does NOT
// match the order Keras's `model.predict()` returns
// ([parent_preds, sub_preds]). Inspecting the converted model's subgraph
// outputs directly shows output index 0 is sub_output (13 classes) and
// index 1 is parent_output (4 classes).
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

enum InsulinActionProfile { rapidActing, longActing, intermediateActing, premixed, unknown }

class PenRecognitionResult {
  final String productName;
  final InsulinActionProfile profile;
  final double confidence;

  const PenRecognitionResult({
    required this.productName,
    required this.profile,
    required this.confidence,
  });

  String get profileLabel {
    switch (profile) {
      case InsulinActionProfile.rapidActing:
        return 'Rapid-acting';
      case InsulinActionProfile.longActing:
        return 'Long-acting';
      case InsulinActionProfile.intermediateActing:
        return 'Intermediate-acting';
      case InsulinActionProfile.premixed:
        return 'Premixed';
      case InsulinActionProfile.unknown:
        return 'Type unconfirmed';
    }
  }
}

class PenClassifierService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  static const int inputSize = 300;

  // Position-for-position with the training notebook's sorted Korean
  // label order: 노보래피드, 노보믹스30, 노보믹스50, 란투스, 레버미어,
  // 애피드라, 투제오, 트레시바, 휴마로그, 휴마로그믹스25, 휴마로그믹스50,
  // 휴물린 7030, 휴물린 엔.
  static const List<String> _subLabels = [
    'NovoRapid',
    'NovoMix 30',
    'NovoMix 50',
    'Lantus',
    'Levemir',
    'Apidra',
    'Toujeo',
    'Tresiba',
    'Humalog',
    'Humalog Mix 25',
    'Humalog Mix 50',
    'Humulin 70/30',
    'Humulin N',
  ];

  // Position-for-position with the notebook's sorted Korean category
  // order: 장시간형, 중간형, 초속효형, 혼합형.
  static const List<String> _parentLabels = [
    'Long-acting',
    'Intermediate-acting',
    'Rapid-acting',
    'Premixed',
  ];

  static const Map<String, InsulinActionProfile> _parentToProfile = {
    'Long-acting': InsulinActionProfile.longActing,
    'Intermediate-acting': InsulinActionProfile.intermediateActing,
    'Rapid-acting': InsulinActionProfile.rapidActing,
    'Premixed': InsulinActionProfile.premixed,
  };

  Future<void> initModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/insulin_classifier.tflite');
      _isModelLoaded = true;
      debugPrint("Insulin pen classifier model initialized successfully.");
    } catch (e) {
      debugPrint("Insulin pen classifier model load failed, using simulated fallback: $e");
    }
  }

  Future<PenRecognitionResult> classify(File image) async {
    if (!_isModelLoaded || _interpreter == null) {
      await initModel();
    }

    if (_isModelLoaded && _interpreter != null) {
      try {
        return await _runInference(image);
      } catch (e) {
        debugPrint("Pen classification inference error, using demo fallback: $e");
      }
    }

    // Demo fallback if the model fails to load or run.
    await Future.delayed(const Duration(milliseconds: 600));
    return const PenRecognitionResult(
      productName: 'NovoRapid FlexTouch (demo result)',
      profile: InsulinActionProfile.rapidActing,
      confidence: 0,
    );
  }

  Future<PenRecognitionResult> _runInference(File image) async {
    final bytes = await image.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Could not decode the image.');
    }
    final resized = img.copyResize(decoded, width: inputSize, height: inputSize);

    // Normalize to [0, 1], matching training preprocessing
    // (tf.image.resize followed by /255.0).
    final input = [
      List.generate(inputSize, (y) {
        return List.generate(inputSize, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        });
      }),
    ];

    final outputSub = List.filled(_subLabels.length, 0.0).reshape([1, _subLabels.length]);
    final outputParent = List.filled(_parentLabels.length, 0.0).reshape([1, _parentLabels.length]);

    _interpreter!.runForMultipleInputs([input], {0: outputSub, 1: outputParent});

    final List subScores = outputSub[0];
    final List parentScores = outputParent[0];

    final subIdx = _argmax(subScores);
    final parentIdx = _argmax(parentScores);

    final parentLabel = _parentLabels[parentIdx];
    final profile = _parentToProfile[parentLabel] ?? InsulinActionProfile.unknown;

    return PenRecognitionResult(
      productName: _subLabels[subIdx],
      profile: profile,
      confidence: (subScores[subIdx] as num).toDouble(),
    );
  }

  int _argmax(List values) {
    int best = 0;
    for (int i = 1; i < values.length; i++) {
      if ((values[i] as num) > (values[best] as num)) best = i;
    }
    return best;
  }

  void dispose() {
    _interpreter?.close();
  }
}
