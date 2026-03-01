import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../files/presentation/providers/file_provider.dart';
import '../providers/scan_provider.dart';

class ScanSavePage extends ConsumerStatefulWidget {
  const ScanSavePage({super.key});

  @override
  ConsumerState<ScanSavePage> createState() =>
      _ScanSavePageState();
}

class _ScanSavePageState
    extends ConsumerState<ScanSavePage> {
  final TextEditingController _nameController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text =
    "Scan_${DateTime.now().millisecondsSinceEpoch}";
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Save Document"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pages scanned: ${scanState.pages.length}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            const Text("Document Name"),
            const SizedBox(height: 8),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            // 🔥 Scan More Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await ref
                      .read(scanProvider.notifier)
                      .scanMore();
                },
                child: const Text("Scan More"),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(scanProvider.notifier)
                      .save(_nameController.text);

                  if (context.mounted) {
                    ref.invalidate(fileProvider(null));
                    context.go('/files');
                  }
                },
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}