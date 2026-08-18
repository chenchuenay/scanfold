import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ScanFoldApp());
}

class ScanFoldApp extends StatelessWidget {
  const ScanFoldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanFold',
      debugShowCheckedModeBanner: false,
      theme: ScanFoldTheme.dark,
      home: const HomeScreen(),
    );
  }
}
