/// ------------------------------------------------------------
/// Injection
/// ------------------------------------------------------------
/// Manual dependency injection for ScanWise.
/// Connects repositories and services.
/// No service locator.
/// Everything exposed through Riverpod providers.
/// ------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Example global provider (will expand later)
final appInitializedProvider = Provider<bool>((ref) {
  return true;
});