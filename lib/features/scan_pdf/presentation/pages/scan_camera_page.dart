import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/scan_provider.dart';

class ScanCameraPage extends ConsumerWidget {
  const ScanCameraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Document"),
      ),
      body: Center(
        child: scanState.isScanning
            ? const CircularProgressIndicator()
            : ElevatedButton(
          onPressed: () async {
            final success =
            await ref.read(scanProvider.notifier).scan();

            if (success && context.mounted) {
              context.push('/scan-review');
            }
          },
          child: const Text("Start Scanning"),
        ),
      ),
    );
  }
}