import 'package:flutter/material.dart';
import 'dart:async';

import 'services/pro_service.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(ProService.instance.initialize());
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
