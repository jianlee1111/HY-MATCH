import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'services/tflite_ble_service.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        Provider(create: (_) => TFLiteBleService()),
      ],
      child: const HyMatchApp(),
    ),
  );
}

class HyMatchApp extends StatelessWidget {
  const HyMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HY-MATCH',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const MainShell(),
    );
  }
}
