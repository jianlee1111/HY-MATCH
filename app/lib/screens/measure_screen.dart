import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/tflite_ble_service.dart';

class MeasureScreen extends StatefulWidget {
  const MeasureScreen({super.key});

  @override
  State<MeasureScreen> createState() => _MeasureScreenState();
}

class _MeasureScreenState extends State<MeasureScreen> {
  bool _isMeasuring = false;

  void _startMeasurement(BuildContext context) {
    setState(() => _isMeasuring = true);

    final bleService = Provider.of<TFLiteBleService>(context, listen: false);
    final appState = Provider.of<AppState>(context, listen: false);

    // Simulate 3-second BLE acquisition & TFLite inference
    Future.delayed(const Duration(seconds: 3), () {
      List<List<double>> dummyWave = List.generate(7, (_) => List.filled(100, 1.2));
      List<double> dummyPhys = [4.2, 1.1, 12.5, 0.15, 36.5, 45.0];

      double predicted = bleService.runInference(dummyWave, dummyPhys);
      appState.addMeasurement(predicted);

      if (mounted) {
        setState(() => _isMeasuring = false);
        appState.setTabIndex(0); // Return to home screen to view result
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("측정", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          const Text("귀클립형 기기를 착용한 상태에서 측정을 시작하세요.", style: TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 40),

          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF16221F),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF23322E)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1D3B33),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bluetooth, color: Color(0xFF26B089), size: 40),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isMeasuring ? "BLE 데이터 수신 및 TFLite 추론 중..." : "버튼을 누르면 BLE로 기기를 검색하고 연결합니다.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "(귀클립 센서 7채널 + TFLite On-device AI 추론)",
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    const SizedBox(height: 32),
                    _isMeasuring
                        ? const CircularProgressIndicator(color: Color(0xFF26B089))
                        : ElevatedButton(
                            onPressed: () => _startMeasurement(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF26B089),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("측정 시작", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
