/// ------------------------------------------------------------
/// ScanPage
/// ------------------------------------------------------------
/// UI layer for scan feature.
/// Listens to scanControllerProvider.
/// ------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/scan_provider.dart';

class ScanPage extends ConsumerWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Scan Document")),
      body: Center(
        child: scanState.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text("Error: $error"),
          data: (document) => Text(
            "Scanned:\n${document.filePath}",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}