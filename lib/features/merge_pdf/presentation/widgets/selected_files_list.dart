import 'package:flutter/material.dart';

import '../../domain/entities/pdf_file_item.dart';

class SelectedFilesList extends StatelessWidget {
  final List<PdfFileItem> files;
  final void Function(String id) onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  const SelectedFilesList({
    super.key,
    required this.files,
    required this.onRemove,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: files.length,
      onReorder: onReorder,
      proxyDecorator: (child, index, animation) => Material(
        elevation: 0,
        color: Colors.transparent,
        child: child,
      ),
      itemBuilder: (context, index) {
        final file = files[index];
        return _FileTile(
          key: ValueKey(file.id),
          file: file,
          index: index,
          onRemove: () => onRemove(file.id),
        );
      },
    );
  }
}

class _FileTile extends StatelessWidget {
  final PdfFileItem file;
  final int index;
  final VoidCallback onRemove;

  const _FileTile({
    super.key,
    required this.file,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131316),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.drag_handle_rounded, size: 18, color: Color(0xFF444455)),
          ),
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B2B).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFF6B2B).withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontFamily: 'Syne', fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFFF6B2B)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1F),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF2A2A35)),
            ),
            child: const Center(
              child: Text('PDF',
                style: TextStyle(fontFamily: 'Syne', fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFFFF6B2B), letterSpacing: 0.3)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name,
                  style: const TextStyle(fontFamily: 'Syne', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFF0EEE8)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(file.sizeFormatted, style: const TextStyle(fontSize: 10, color: Color(0xFF888899))),
                    if (file.pageCount != null) ...[
                      const Text(' · ', style: TextStyle(fontSize: 10, color: Color(0xFF444455))),
                      Text('${file.pageCount} ${file.pageCount == 1 ? 'page' : 'pages'}',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF888899))),
                    ] else
                      const Text(' · counting…', style: TextStyle(fontSize: 10, color: Color(0xFF444455))),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1F),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A2A35)),
              ),
              child: const Center(
                child: Text('✕', style: TextStyle(fontSize: 11, color: Color(0xFF888899))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
