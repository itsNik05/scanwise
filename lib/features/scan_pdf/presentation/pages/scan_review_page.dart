import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/scan_provider.dart';
import '../../../files/presentation/providers/file_provider.dart';
import 'scan_fullscreen_preview_page.dart';
import '../../../../config/routes/route_names.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class ScanReviewPage extends ConsumerStatefulWidget {
  const ScanReviewPage({super.key});

  @override
  ConsumerState<ScanReviewPage> createState() =>
      _ScanReviewPageState();
}

class _ScanReviewPageState
    extends ConsumerState<ScanReviewPage> {

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
        title: const Text("Review Pages"),
      ),
      body: Column(
        children: [

          // 🔹 Page Count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Pages: ${scanState.pages.length}",
              style: const TextStyle(fontSize: 18),
            ),
          ),

          // 🔹 Thumbnails Grid
          // 🔥 Reorderable Thumbnails List
          Expanded(
            child: ReorderableGridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: scanState.pages.length,
              onReorder: (oldIndex, newIndex) {
                ref.read(scanProvider.notifier)
                    .reorderPages(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final path = scanState.pages[index];

                return Container(
                  key: ValueKey(path),
                  child: Stack(
                    children: [

                      // 🔍 Tap to full screen
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FullScreenPreviewPage(
                                      pages: scanState.pages,
                                      initialIndex: index,
                                    ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(12),
                            child: Image.file(
                              File(path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // ❌ Delete
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            ref.read(scanProvider.notifier)
                                .removePage(path);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 🔹 Document Name Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "PDF Name",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // 🔹 Bottom Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [

                // 🔁 Scan More
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref.read(scanProvider.notifier).scanMore();
                    },
                    child: const Text("Scan More"),
                  ),
                ),

                const SizedBox(width: 16),

                // 💾 Export PDF
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {

                      await ref
                          .read(scanProvider.notifier)
                          .save(_nameController.text);

                      if (context.mounted) {
                        ref.invalidate(
                            fileProvider(null));
                        context.go(RouteNames.files);
                      }
                    },
                    child: const Text("Export PDF"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}