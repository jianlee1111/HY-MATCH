// 인슐린 펜 이미지 분류 서비스.
//
// MobileNetV2 기반 2-head 분류 모델(assets/insulin_classifier.tflite, Insulin_Classifier.ipynb로 학습)을 사용합니다.
//   - sub_output (13class): 구체적인 제품명
//   - parent_output (4class): 작용 시간 카테고리 (장시간형/중간형/초속효형/혼합형)
//
// 라벨 순서는 학습 노트북의 `sorted(list(set(y_sub_labels)))` /
// `sorted(list(set(y_parent_labels)))` 결과와 동일해야 합니다. 모델을 다시
// 학습/변환하면 이 목록도 노트북 출력과 맞춰서 다시 확인해야 합니다.
//
// 주의: 컴파일된 .tflite 파일의 실제 출력 순서는 Keras 쪽
// `model.predict()`가 돌려주는 [parent_preds, sub_preds] 순서와 다릅니다.
// 변환된 모델의 subgraph 출력을 직접 확인한 결과, 출력 인덱스 0번이
// sub_output(13class), 1번이 parent_output(4class)입니다.
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
        return '초속효성';
      case InsulinActionProfile.longActing:
        return '지속성(장시간형)';
      case InsulinActionProfile.intermediateActing:
        return '중간형';
      case InsulinActionProfile.premixed:
        return '혼합형';
      case InsulinActionProfile.unknown:
        return '종류 확인 필요';
    }
  }
}

class PenClassifierService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  static const int inputSize = 300;

  static const List<String> _subLabels = [
    '노보래피드',
    '노보믹스30',
    '노보믹스50',
    '란투스',
    '레버미어',
    '애피드라',
    '투제오',
    '트레시바',
    '휴마로그',
    '휴마로그믹스25',
    '휴마로그믹스50',
    '휴물린 7030',
    '휴물린 엔',
  ];

  static const List<String> _parentLabels = ['장시간형', '중간형', '초속효형', '혼합형'];

  static const Map<String, InsulinActionProfile> _parentToProfile = {
    '장시간형': InsulinActionProfile.longActing,
    '중간형': InsulinActionProfile.intermediateActing,
    '초속효형': InsulinActionProfile.rapidActing,
    '혼합형': InsulinActionProfile.premixed,
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

    // 모델 로드 또는 추론 실패 시 데모 폴백.
    await Future.delayed(const Duration(milliseconds: 600));
    return const PenRecognitionResult(
      productName: '노보래피드 플렉스타치 (데모 인식 결과)',
      profile: InsulinActionProfile.rapidActing,
      confidence: 0,
    );
  }

  Future<PenRecognitionResult> _runInference(File image) async {
    final bytes = await image.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('이미지를 디코딩할 수 없습니다.');
    }
    final resized = img.copyResize(decoded, width: inputSize, height: inputSize);

    // 학습 시 전처리(tf.image.resize 후 /255.0)와 동일하게 0~1로 정규화.
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
