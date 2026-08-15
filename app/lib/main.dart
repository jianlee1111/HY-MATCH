import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'services/tflite_ble_service.dart';
import 'screens/main_shell.dart';

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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1715), // Deep Dark Olive Gray
        cardColor: const Color(0xFF16221F),
        primaryColor: const Color(0xFF26B089), // Mint Green accent
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF26B089),
          secondary: Color(0xFF26B089),
          surface: Color(0xFF16221F),
          background: Color(0xFF0F1715),
          error: Color(0xFFE53935),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F1715),
          elevation: 0,
        ),
      ),
      home: const MainShell(),
    );
  }
}
