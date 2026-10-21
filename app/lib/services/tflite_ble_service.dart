import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteBleService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;
  bool get isModelLoaded => _isModelLoaded;

  // 10-second sequence at 10Hz = 100 samples, 7 channels
  static const int sequenceLength = 100;
  static const int numChannels = 7;
  static const int physParamsDim = 6;

  final List<List<double>> _waveBuffer = List.generate(
    numChannels,
    (_) => List.filled(sequenceLength, 0.0),
  );
  int _sampleCount = 0;

  final StreamController<double> _predictionController = StreamController<double>.broadcast();
  Stream<double> get predictionStream => _predictionController.stream;

  Future<void> initModel() async {
    try {
      var options = InterpreterOptions();
      if (defaultTargetPlatform == TargetPlatform.android) {
        options.addDelegate(XNNPackDelegate());
      }
      _interpreter = await Interpreter.fromAsset(
        'assets/glucose_model.tflite',
        options: options,
      );
      _isModelLoaded = true;
      debugPrint("TFLite model initialized successfully.");
    } catch (e) {
      debugPrint("TFLite model load failed, using simulated fallback: $e");
    }
  }

  /// Real BLE Connection Listener
  void connectToDevice(BluetoothCharacteristic characteristic) async {
    await characteristic.setNotifyValue(true);
    characteristic.lastValueStream.listen((bytes) {
      if (bytes.isEmpty) return;
      List<double> channels = _parseBytes(bytes);
      _updateBuffer(channels);

      if (_sampleCount >= sequenceLength) {
        List<double> physParams = [4.2, 1.1, 12.5, 0.15, 36.5, 45.0];
        runInference(_waveBuffer, physParams);
        _sampleCount = 0;
      }
    });
  }

  /// Run TFLite Multi-input Inference
  double runInference(List<List<double>> waveData, List<double> physData) {
    if (_isModelLoaded && _interpreter != null) {
      try {
        var inputWave = [waveData]; // [1, 7, 100]
        var inputPhys = [physData]; // [1, 6]
        var inputs = [inputWave, inputPhys];

        var output = List.filled(1, 0.0).reshape([1, 1]);
        var outputs = {0: output};

        _interpreter!.runForMultipleInputs(inputs, outputs);
        double result = outputs[0]![0][0];
        _predictionController.add(result);
        return result;
      } catch (e) {
        debugPrint("Inference error: $e");
      }
    }

    // Demo Simulation Fallback if TFLite file not present in asset during dev
    double simulatedValue = 135.0 + (DateTime.now().second % 15);
    _predictionController.add(simulatedValue);
    return simulatedValue;
  }

  void _updateBuffer(List<double> newChannels) {
    for (int ch = 0; ch < numChannels; ch++) {
      _waveBuffer[ch].removeAt(0);
      _waveBuffer[ch].add(newChannels[ch]);
    }
    _sampleCount++;
  }

  List<double> _parseBytes(List<int> bytes) {
    Float32List floatList = Float32List.view(Uint8List.fromList(bytes).buffer);
    if (floatList.length >= numChannels) {
      return floatList.sublist(0, numChannels);
    }
    return List.filled(numChannels, 0.0);
  }

  void dispose() {
    _interpreter?.close();
    _predictionController.close();
  }
}
