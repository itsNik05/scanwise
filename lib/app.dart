/// ------------------------------------------------------------
/// app.dart
/// ------------------------------------------------------------
/// Root widget of ScanWise.
/// Connects theme and router.
/// ------------------------------------------------------------

import 'package:flutter/material.dart';
import 'config/routes/app_router.dart';
import 'core/theme/app_theme.dart';

class ScanWiseApp extends StatelessWidget {
  const ScanWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ScanWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}