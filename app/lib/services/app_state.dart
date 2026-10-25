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

  // Medical Portal Doctor view tab index (0: Overview, 1: Trend, 2: Plan, 3: Adherence)
  int _doctorSubTabIndex = 0;
  int get doctorSubTabIndex => _doctorSubTabIndex;

  // Patient Info
  String patientName = "Minji Kim";
  String diabetesType = "Type 2";
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

  // BLE device connection state — there's no real scan/pairing logic yet;
  // this flips to true once the user starts a measurement (demo only).
  bool _isDeviceConnected = false;
  bool get isDeviceConnected => _isDeviceConnected;

  void setDeviceConnected(bool connected) {
    _isDeviceConnected = connected;
    notifyListeners();
  }

  // Guardian alerts (SOS) — for now this only supports registering a
  // guardian and previewing what an alert would say. Real push delivery
  // needs a backend (e.g. FCM) and isn't implemented yet.
  final List<GuardianContact> _guardians = [
    GuardianContact(name: "Jiho Kim", relation: "Son", phone: "010-1234-5678"),
  ];
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
