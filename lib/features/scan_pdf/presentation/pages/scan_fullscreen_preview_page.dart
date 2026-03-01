import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/scan_provider.dart';

class FullScreenPreviewPage extends ConsumerStatefulWidget {
  final List<String> pages;
  final int initialIndex;

  const FullScreenPreviewPage({
    super.key,
    required this.pages,
    required this.initialIndex,
  });

  @override
  ConsumerState<FullScreenPreviewPage> createState() =>
      _FullScreenPreviewPageState();
}

class _FullScreenPreviewPageState
    extends ConsumerState<FullScreenPreviewPage> {

  late PageController _controller;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _controller =
        PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final pages = ref.watch(scanProvider).pages;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme:
        const IconThemeData(color: Colors.white),
        actions: [

          // 🔥 Delete from Full Screen
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              final path = pages[currentIndex];

              ref.read(scanProvider.notifier)
                  .removePage(path);

              if (pages.length <= 1) {
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: Stack(
        children: [

          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Image.file(
                    File(pages[index]),
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          // 🔥 Page Index Indicator
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Text(
                  "${currentIndex + 1} / ${pages.length}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}