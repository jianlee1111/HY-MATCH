// 인슐린 펜 이미지 분류를 위한 서비스.
//
// 아직 이미지 분류 모델이 없으므로, classify()는 지금은 잠시 대기한 뒤
// 데모용 고정 결과를 돌려줍니다. 호출하는 쪽(PenGuideScreen)은 이 클래스의
// 공개 인터페이스(classify의 입력/출력 타입)에만 의존하므로, 나중에 실제
// 모델이 준비되면 이 파일 내부 구현만 바꾸면 됩니다. 교체 방법은
// README의 "인슐린 펜 인식 모델 연결하기" 항목을 참고하세요.
import 'dart:io';

enum InsulinActionProfile { rapidActing, longActing, unknown }

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
        return '지속성';
      case InsulinActionProfile.unknown:
        return '종류 확인 필요';
    }
  }
}

class PenClassifierService {
  Future<PenRecognitionResult> classify(File image) async {
    await Future.delayed(const Duration(milliseconds: 1600));

    // TODO: 실제 모델 연결 지점.
    // glucose_model.tflite를 TFLiteBleService에서 불러오는 것과 같은 방식으로,
    // 여기서 두 번째 TFLite 자산(예: assets/pen_model.tflite)을 불러와
    // image를 전처리(리사이즈/정규화)한 뒤 추론하고, 출력 인덱스를
    // 아래 라벨 목록 같은 펜 종류 목록에 매핑하면 됩니다.
    return const PenRecognitionResult(
      productName: '노보래피드 플렉스타치 (데모 인식 결과)',
      profile: InsulinActionProfile.rapidActing,
      confidence: 0,
    );
  }
}
