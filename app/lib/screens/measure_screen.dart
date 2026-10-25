import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/tflite_ble_service.dart';
import '../theme/app_theme.dart';

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
    appState.setDeviceConnected(true);

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
          Text("Measure", style: AppText.title()),
          const SizedBox(height: 6),
          Text("Put on the ear-clip device, then start your measurement.", style: AppText.body(color: AppColors.textSecondary)),
          const SizedBox(height: 40),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bluetooth, color: AppColors.primary, size: 40),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isMeasuring ? "Analyzing your glucose reading" : "Tap the button to find and connect your device.",
                      textAlign: TextAlign.center,
                      style: AppText.body(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    _isMeasuring
                        ? const CircularProgressIndicator(color: AppColors.primary)
                        : SizedBox(
                            width: 220,
                            child: ElevatedButton(
                              onPressed: () => _startMeasurement(context),
                              child: const Text("Start Measurement"),
                            ),
                          ),
                  ],
                ),
              ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
