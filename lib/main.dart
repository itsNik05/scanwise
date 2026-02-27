/// ------------------------------------------------------------
/// main.dart
/// ------------------------------------------------------------
/// Entry point of ScanWise.
/// Initializes Riverpod and launches the app.
/// ------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ScanWiseApp()));
}