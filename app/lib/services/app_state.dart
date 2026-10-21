import 'package:flutter/foundation.dart';

class GlucoseRecord {
  final DateTime timestamp;
  final double value;
  final String note;

  GlucoseRecord({required this.timestamp, required this.value, this.note = ''});
}

class GuardianContact {
  final String name;
  final String relation;
  final String phone;

  const GuardianContact({
    required this.name,
    required this.relation,
    required this.phone,
  });
}

class AppState extends ChangeNotifier {
  // Mode: 0 = Patient App, 1 = Medical Staff Portal
  int _currentRoleMode = 0;
  int get currentRoleMode => _currentRoleMode;

  // Selected Nav Tab index
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  // Medical Portal Doctor view tab index (0: 개요, 1: 추세, 2: 처방/계획, 3: 이행률)
  int _doctorSubTabIndex = 0;
  int get doctorSubTabIndex => _doctorSubTabIndex;

  // Patient Info
  String patientName = "김민지";
  String diabetesType = "2형";
  String birthDate = "1985-03-12";
  String regDate = "2026-07-01";
  double targetLow = 80.0;
  double targetHigh = 140.0;

  // Meals Log
  String? breakfastTime = "08:00";
  String? lunchTime = "12:30";
  String? dinnerTime = "18:30";

  // Recent Glucose Values
  double _currentGlucose = 141.0;
  DateTime _lastMeasuredTime = DateTime.parse("2026-08-16 19:45:00");

  double get currentGlucose => _currentGlucose;
  DateTime get lastMeasuredTime => _lastMeasuredTime;

  final List<GlucoseRecord> _history = [
    GlucoseRecord(timestamp: DateTime.parse("2026-08-03 09:00:00"), value: 110),
    GlucoseRecord(timestamp: DateTime.parse("2026-08-05 09:00:00"), value: 142),
    GlucoseRecord(timestamp: DateTime.parse("2026-08-08 09:00:00"), value: 65),
    GlucoseRecord(timestamp: DateTime.parse("2026-08-10 09:00:00"), value: 125),
    GlucoseRecord(timestamp: DateTime.parse("2026-08-13 09:00:00"), value: 198),
    GlucoseRecord(timestamp: DateTime.parse("2026-08-14 09:00:00"), value: 48),
    GlucoseRecord(timestamp: DateTime.parse("2026-08-15 09:00:00"), value: 115),
    GlucoseRecord(timestamp: DateTime.parse("2026-08-16 19:45:00"), value: 141),
  ];

  List<GlucoseRecord> get history => List.unmodifiable(_history);

  // Food Log Units
  int grainUnit = 0;
  int meatUnit = 0;
  int vegUnit = 0;
  int fatUnit = 0;

  // BLE 기기 연결 상태 — 실제 스캔/페어링 로직은 아직 없고,
  // 측정 화면에서 측정을 한 번 시작하면 true로 표시됩니다(데모).
  bool _isDeviceConnected = false;
  bool get isDeviceConnected => _isDeviceConnected;

  void setDeviceConnected(bool connected) {
    _isDeviceConnected = connected;
    notifyListeners();
  }

  // 보호자 알림(SOS) — 지금은 보호자 등록과 알림 미리보기까지만 제공합니다.
  // 실제 푸시 발송은 백엔드(FCM 등)가 필요해 아직 구현되어 있지 않습니다.
  final List<GuardianContact> _guardians = [];
  List<GuardianContact> get guardians => List.unmodifiable(_guardians);

  void addGuardian(GuardianContact guardian) {
    _guardians.add(guardian);
    notifyListeners();
  }

  void removeGuardian(int index) {
    _guardians.removeAt(index);
    notifyListeners();
  }

  void setRoleMode(int mode) {
    _currentRoleMode = mode;
    notifyListeners();
  }

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setDoctorSubTabIndex(int index) {
    _doctorSubTabIndex = index;
    notifyListeners();
  }

  void addMeasurement(double value) {
    _currentGlucose = value;
    _lastMeasuredTime = DateTime.now();
    _history.add(GlucoseRecord(timestamp: _lastMeasuredTime, value: value));
    notifyListeners();
  }

  void updateMealTime(String meal, String time) {
    if (meal == 'breakfast') breakfastTime = time;
    if (meal == 'lunch') lunchTime = time;
    if (meal == 'dinner') dinnerTime = time;
    notifyListeners();
  }

  void updateTargetRange(double low, double high) {
    targetLow = low;
    targetHigh = high;
    notifyListeners();
  }

  void resetDemoData() {
    _currentGlucose = 141.0;
    _lastMeasuredTime = DateTime.parse("2026-08-16 19:45:00");
    grainUnit = 0;
    meatUnit = 0;
    vegUnit = 0;
    fatUnit = 0;
    _isDeviceConnected = false;
    notifyListeners();
  }
}
