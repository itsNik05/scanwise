#!/bin/bash
# Run this from the ROOT of your scanwise project
# chmod +x create_merge_pdf.sh && ./create_merge_pdf.sh

set -e  # stop on first error

# ── 1. Create all directories ─────────────────────────────────────────────────

mkdir -p lib/features/merge_pdf/domain/entities
mkdir -p lib/features/merge_pdf/domain/repositories
mkdir -p lib/features/merge_pdf/domain/usecases
mkdir -p lib/features/merge_pdf/data/datasources
mkdir -p lib/features/merge_pdf/data/repositories
mkdir -p lib/features/merge_pdf/presentation/pages
mkdir -p lib/features/merge_pdf/presentation/providers
mkdir -p lib/features/merge_pdf/presentation/widgets
mkdir -p lib/config/di

echo "✅  Directories created"

# ── 2. domain/entities/merged_document.dart ──────────────────────────────────

cat > lib/features/merge_pdf/domain/entities/merged_document.dart << 'DART'
class MergedDocument {
  final List<String> sourcePaths;
  final String outputPath;
  final String outputName;
  final int totalPages;
  final int outputSize;

  const MergedDocument({
    required this.sourcePaths,
    required this.outputPath,
    required this.outputName,
    required this.totalPages,
    required this.outputSize,
  });

  int get fileCount => sourcePaths.length;

  String get outputSizeFormatted {
    if (outputSize < 1024) return '$outputSize B';
    if (outputSize < 1024 * 1024) {
      return '${(outputSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(outputSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
DART

echo "✅  merged_document.dart"

# ── 3. domain/entities/pdf_file_item.dart ────────────────────────────────────

cat > lib/features/merge_pdf/domain/entities/pdf_file_item.dart << 'DART'
class PdfFileItem {
  final String id;
  final String path;
  final String name;
  final int size;
  final int? pageCount;

  const PdfFileItem({
    required this.id,
    required this.path,
    required this.name,
    required this.size,
    this.pageCount,
  });

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  PdfFileItem copyWith({int? pageCount}) {
    return PdfFileItem(
      id: id,
      path: path,
      name: name,
      size: size,
      pageCount: pageCount ?? this.pageCount,
    );
  }
}
DART

echo "✅  pdf_file_item.dart"

# ── 4. domain/repositories/merge_pdf_repository.dart ─────────────────────────

cat > lib/features/merge_pdf/domain/repositories/merge_pdf_repository.dart << 'DART'
import '../entities/merged_document.dart';

abstract class MergePdfRepository {
  Future<MergedDocument> mergePdfs({
    required List<String> inputPaths,
    required String outputName,
  });
}
DART

echo "✅  merge_pdf_repository.dart"

# ── 5. domain/usecases/merge_pdf_usecase.dart ────────────────────────────────

cat > lib/features/merge_pdf/domain/usecases/merge_pdf_usecase.dart << 'DART'
import '../entities/merged_document.dart';
import '../repositories/merge_pdf_repository.dart';

class MergePdfUsecase {
  final MergePdfRepository _repository;

  const MergePdfUsecase(this._repository);

  Future<MergedDocument> call({
    required List<String> inputPaths,
    required String outputName,
  }) {
    return _repository.mergePdfs(
      inputPaths: inputPaths,
      outputName: outputName,
    );
  }
}
DART

echo "✅  merge_pdf_usecase.dart"

# ── 6. data/datasources/merge_pdf_datasource.dart ────────────────────────────

cat > lib/features/merge_pdf/data/datasources/merge_pdf_datasource.dart << 'DART'
abstract class MergePdfDatasource {
  Future<String> mergeAndSave({
    required List<String> inputPaths,
    required String outputName,
    required void Function(int current, int total) onProgress,
  });

  Future<int> getPageCount(String path);
}
DART

echo "✅  merge_pdf_datasource.dart"

# ── 7. data/datasources/merge_pdf_datasource_impl.dart ───────────────────────

cat > lib/features/merge_pdf/data/datasources/merge_pdf_datasource_impl.dart << 'DART'
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart';

import 'merge_pdf_datasource.dart';

class MergePdfDatasourceImpl implements MergePdfDatasource {
  static const double _renderScale = 1.5;
  static const int _jpegQuality = 88;

  @override
  Future<int> getPageCount(String path) async {
    final doc = await PdfDocument.openFile(path);
    final count = doc.pagesCount;
    await doc.close();
    return count;
  }

  @override
  Future<String> mergeAndSave({
    required List<String> inputPaths,
    required String outputName,
    required void Function(int current, int total) onProgress,
  }) async {
    int totalPages = 0;
    for (final path in inputPaths) {
      final doc = await PdfDocument.openFile(path);
      totalPages += doc.pagesCount;
      await doc.close();
    }

    final newPdf = pw.Document(compress: true);
    int processedPages = 0;

    for (final inputPath in inputPaths) {
      final document = await PdfDocument.openFile(inputPath);

      for (int i = 1; i <= document.pagesCount; i++) {
        processedPages++;
        onProgress(processedPages, totalPages);

        final page = await document.getPage(i);
        final originalWidth = page.width;
        final originalHeight = page.height;

        final renderWidth = (originalWidth * _renderScale).round();
        final renderHeight = (originalHeight * _renderScale).round();

        final pageImage = await page.render(
          width: renderWidth.toDouble(),
          height: renderHeight.toDouble(),
          format: PdfPageImageFormat.jpeg,
          quality: 100,
          backgroundColor: '#FFFFFF',
        );

        await page.close();
        if (pageImage == null) continue;

        final rawImage = img.decodeImage(pageImage.bytes);
        if (rawImage == null) continue;

        final compressedBytes = Uint8List.fromList(
          img.encodeJpg(rawImage, quality: _jpegQuality),
        );

        final pdfImage = pw.MemoryImage(compressedBytes);

        newPdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(
              originalWidth * PdfPageFormat.point,
              originalHeight * PdfPageFormat.point,
            ),
            margin: pw.EdgeInsets.zero,
            build: (_) => pw.Image(pdfImage, fit: pw.BoxFit.fill),
          ),
        );
      }

      await document.close();
    }

    final outputDir = await getApplicationDocumentsDirectory();
    final mergedDir = Directory(p.join(outputDir.path, 'merged'));
    if (!mergedDir.existsSync()) {
      mergedDir.createSync(recursive: true);
    }

    final safeName = outputName.trim().isEmpty ? 'merged' : outputName.trim();
    final fileName = safeName.endsWith('.pdf') ? safeName : '$safeName.pdf';
    final outputPath = p.join(mergedDir.path, fileName);

    final outputBytes = await newPdf.save();
    await File(outputPath).writeAsBytes(outputBytes);

    return outputPath;
  }
}
DART

echo "✅  merge_pdf_datasource_impl.dart"

# ── 8. data/repositories/merge_pdf_repository_impl.dart ──────────────────────

cat > lib/features/merge_pdf/data/repositories/merge_pdf_repository_impl.dart << 'DART'
import 'dart:io';

import '../../domain/entities/merged_document.dart';
import '../../domain/repositories/merge_pdf_repository.dart';
import '../datasources/merge_pdf_datasource.dart';

class MergePdfRepositoryImpl implements MergePdfRepository {
  final MergePdfDatasource _datasource;

  MergePdfDatasource get datasource => _datasource;

  void Function(int current, int total)? onProgress;

  MergePdfRepositoryImpl(this._datasource);

  @override
  Future<MergedDocument> mergePdfs({
    required List<String> inputPaths,
    required String outputName,
  }) async {
    int totalPages = 0;
    for (final path in inputPaths) {
      totalPages += await _datasource.getPageCount(path);
    }

    final outputPath = await _datasource.mergeAndSave(
      inputPaths: inputPaths,
      outputName: outputName,
      onProgress: onProgress ?? (_, __) {},
    );

    final outputSize = await File(outputPath).length();
    final outputFile = File(outputPath);

    return MergedDocument(
      sourcePaths: inputPaths,
      outputPath: outputPath,
      outputName: outputFile.uri.pathSegments.last,
      totalPages: totalPages,
      outputSize: outputSize,
    );
  }
}
DART

echo "✅  merge_pdf_repository_impl.dart"

# ── 9. presentation/providers/merge_state.dart ───────────────────────────────

cat > lib/features/merge_pdf/presentation/providers/merge_state.dart << 'DART'
import '../../domain/entities/merged_document.dart';
import '../../domain/entities/pdf_file_item.dart';

enum MergeStatus { idle, picking, merging, done, error }

class MergeState {
  final MergeStatus status;
  final List<PdfFileItem> selectedFiles;
  final String outputName;
  final int currentPage;
  final int totalPages;
  final MergedDocument? result;
  final String? errorMessage;

  const MergeState({
    this.status = MergeStatus.idle,
    this.selectedFiles = const [],
    this.outputName = '',
    this.currentPage = 0,
    this.totalPages = 0,
    this.result,
    this.errorMessage,
  });

  bool get hasFiles => selectedFiles.isNotEmpty;
  bool get canMerge => selectedFiles.length >= 2;
  bool get isMerging => status == MergeStatus.merging;

  double get progress =>
      totalPages == 0 ? 0.0 : currentPage / totalPages;

  int get totalSelectedPages =>
      selectedFiles.fold(0, (sum, f) => sum + (f.pageCount ?? 0));

  MergeState copyWith({
    MergeStatus? status,
    List<PdfFileItem>? selectedFiles,
    String? outputName,
    int? currentPage,
    int? totalPages,
    MergedDocument? result,
    String? errorMessage,
  }) {
    return MergeState(
      status: status ?? this.status,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      outputName: outputName ?? this.outputName,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  MergeState reset() => const MergeState();
}
DART

echo "✅  merge_state.dart"

# ── 10. presentation/providers/merge_provider.dart ───────────────────────────

cat > lib/features/merge_pdf/presentation/providers/merge_provider.dart << 'DART'
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/merge_pdf_datasource_impl.dart';
import '../../data/repositories/merge_pdf_repository_impl.dart';
import '../../domain/entities/pdf_file_item.dart';
import '../../domain/usecases/merge_pdf_usecase.dart';
import 'merge_state.dart';

final mergePdfProvider =
    StateNotifierProvider.autoDispose<MergeNotifier, MergeState>(
  (ref) {
    final datasource = MergePdfDatasourceImpl();
    final repository = MergePdfRepositoryImpl(datasource);
    final usecase = MergePdfUsecase(repository);
    return MergeNotifier(usecase, repository);
  },
);

class MergeNotifier extends StateNotifier<MergeState> {
  final MergePdfUsecase _usecase;
  final MergePdfRepositoryImpl _repository;
  final _uuid = const Uuid();

  MergeNotifier(this._usecase, this._repository) : super(const MergeState());

  Future<void> pickFiles() async {
    state = state.copyWith(status: MergeStatus.picking);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        state = state.copyWith(status: MergeStatus.idle);
        return;
      }

      final newItems = <PdfFileItem>[];
      for (final file in result.files) {
        final path = file.path;
        if (path == null) continue;
        if (state.selectedFiles.any((f) => f.path == path)) continue;

        final size = await File(path).length();
        newItems.add(PdfFileItem(
          id: _uuid.v4(),
          path: path,
          name: file.name,
          size: size,
        ));
      }

      final updated = [...state.selectedFiles, ...newItems];
      state = state.copyWith(
        status: MergeStatus.idle,
        selectedFiles: updated,
        errorMessage: null,
      );

      _loadPageCounts(newItems);
    } catch (e) {
      state = state.copyWith(
        status: MergeStatus.error,
        errorMessage: 'Failed to pick files: $e',
      );
    }
  }

  Future<void> _loadPageCounts(List<PdfFileItem> items) async {
    for (final item in items) {
      try {
        final count = await _repository.datasource.getPageCount(item.path);
        if (!mounted) return;
        final updated = state.selectedFiles.map((f) {
          return f.id == item.id ? f.copyWith(pageCount: count) : f;
        }).toList();
        state = state.copyWith(selectedFiles: updated);
      } catch (_) {}
    }
  }

  void removeFile(String id) {
    final updated = state.selectedFiles.where((f) => f.id != id).toList();
    state = state.copyWith(selectedFiles: updated, result: null);
  }

  void reorderFiles(int oldIndex, int newIndex) {
    final list = [...state.selectedFiles];
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = state.copyWith(selectedFiles: list, result: null);
  }

  void setOutputName(String name) {
    state = state.copyWith(outputName: name);
  }

  Future<void> merge() async {
    if (!state.canMerge) return;

    _repository.onProgress = (current, total) {
      if (mounted) {
        state = state.copyWith(currentPage: current, totalPages: total);
      }
    };

    state = state.copyWith(
      status: MergeStatus.merging,
      currentPage: 0,
      totalPages: 0,
      result: null,
      errorMessage: null,
    );

    try {
      final outputName = state.outputName.trim().isEmpty
          ? 'merged_${DateTime.now().millisecondsSinceEpoch}'
          : state.outputName.trim();

      final result = await _usecase(
        inputPaths: state.selectedFiles.map((f) => f.path).toList(),
        outputName: outputName,
      );

      state = state.copyWith(status: MergeStatus.done, result: result);
    } catch (e) {
      state = state.copyWith(
        status: MergeStatus.error,
        errorMessage: 'Merge failed: $e',
      );
    } finally {
      _repository.onProgress = null;
    }
  }

  Future<void> shareResult() async {
    final path = state.result?.outputPath;
    if (path == null) return;
    await Share.shareXFiles([XFile(path)], text: 'Merged PDF');
  }

  void reset() => state = state.reset();
}
DART

echo "✅  merge_provider.dart"

# ── 11. presentation/widgets/selected_files_list.dart ────────────────────────

cat > lib/features/merge_pdf/presentation/widgets/selected_files_list.dart << 'DART'
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
DART

echo "✅  selected_files_list.dart"

# ── 12. presentation/widgets/merge_result_card.dart ──────────────────────────

cat > lib/features/merge_pdf/presentation/widgets/merge_result_card.dart << 'DART'
import 'package:flutter/material.dart';

import '../../domain/entities/merged_document.dart';

class MergeResultCard extends StatelessWidget {
  final MergedDocument result;
  final VoidCallback onShare;
  final VoidCallback onReset;

  const MergeResultCard({
    super.key,
    required this.result,
    required this.onShare,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131316),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.27), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF60A5FA).withOpacity(0.07), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF60A5FA).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.3)),
                ),
                child: const Center(child: Text('✅', style: TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Merge Complete',
                      style: TextStyle(fontFamily: 'Syne', fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFF0EEE8))),
                    Text(result.outputName,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF888899)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatChip(icon: '📄', label: 'Files merged', value: '${result.fileCount}', color: const Color(0xFF60A5FA)),
              const SizedBox(width: 10),
              _StatChip(icon: '📑', label: 'Total pages', value: '${result.totalPages}', color: const Color(0xFFFF6B2B)),
              const SizedBox(width: 10),
              _StatChip(icon: '💾', label: 'Output size', value: result.outputSizeFormatted, color: const Color(0xFF4ADE80)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF1A1A1F), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Text('🔗', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(result.outputName,
                    style: const TextStyle(fontFamily: 'Syne', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFF0EEE8)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _ActionButton(label: 'Share', icon: '📤', isPrimary: true, onTap: onShare)),
              const SizedBox(width: 10),
              Expanded(child: _ActionButton(label: 'Merge Again', icon: '🔗', isPrimary: false, onTap: onReset)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontFamily: 'Syne', fontSize: 15, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
              style: const TextStyle(fontSize: 9, color: Color(0xFF888899), letterSpacing: 0.3),
              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final String icon;
  final bool isPrimary;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.isPrimary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFFF6B2B) : const Color(0xFF1A1A1F),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: const Color(0xFF2A2A35)),
          boxShadow: isPrimary
              ? [BoxShadow(color: const Color(0xFFFF6B2B).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                style: TextStyle(
                  fontFamily: 'Syne', fontSize: 12, fontWeight: FontWeight.w700,
                  color: isPrimary ? const Color(0xFF0D0D0F) : const Color(0xFFF0EEE8)),
                overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
DART

echo "✅  merge_result_card.dart"

# ── 13. presentation/pages/merge_pdf_page.dart ───────────────────────────────

cat > lib/features/merge_pdf/presentation/pages/merge_pdf_page.dart << 'DART'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/merge_provider.dart';
import '../providers/merge_state.dart';
import '../widgets/merge_result_card.dart';
import '../widgets/selected_files_list.dart';

class MergePdfPage extends ConsumerWidget {
  const MergePdfPage({super.key});

  static const _bg            = Color(0xFF0D0D0F);
  static const _card2         = Color(0xFF1A1A1F);
  static const _border        = Color(0xFF2A2A35);
  static const _accent        = Color(0xFFFF6B2B);
  static const _textPrimary   = Color(0xFFF0EEE8);
  static const _textSecondary = Color(0xFF888899);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(mergePdfProvider);
    final notifier = ref.read(mergePdfProvider.notifier);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _card2, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: _textSecondary),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Merge PDFs',
              style: TextStyle(fontFamily: 'Syne', fontSize: 17, fontWeight: FontWeight.w800, color: _textPrimary)),
            Text('Combine multiple PDFs into one',
              style: TextStyle(fontSize: 10, color: _textSecondary)),
          ],
        ),
        actions: [
          if (state.status == MergeStatus.done)
            GestureDetector(
              onTap: notifier.reset,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _card2, borderRadius: BorderRadius.circular(8), border: Border.all(color: _border)),
                child: const Text('New',
                  style: TextStyle(fontFamily: 'Syne', fontSize: 12, fontWeight: FontWeight.w700, color: _accent)),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state.status == MergeStatus.done && state.result != null
              ? _ResultView(state: state, notifier: notifier)
              : _MainView(state: state, notifier: notifier),
        ),
      ),
    );
  }
}

class _MainView extends StatelessWidget {
  final MergeState state;
  final MergeNotifier notifier;
  const _MainView({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AddFilesButton(
            fileCount: state.selectedFiles.length,
            onTap: notifier.pickFiles,
            isLoading: state.status == MergeStatus.picking,
          ),
          if (state.hasFiles) ...[
            const SizedBox(height: 20),
            _SectionLabel(
              label: 'Selected Files',
              trailing: '${state.selectedFiles.length} files'
                  '${state.totalSelectedPages > 0 ? ' · ${state.totalSelectedPages} pages' : ''}',
            ),
            const SizedBox(height: 10),
            SelectedFilesList(
              files: state.selectedFiles,
              onRemove: notifier.removeFile,
              onReorder: notifier.reorderFiles,
            ),
          ],
          if (state.canMerge) ...[
            const SizedBox(height: 20),
            const _SectionLabel(label: 'Output File Name'),
            const SizedBox(height: 10),
            _OutputNameField(initialValue: state.outputName, onChanged: notifier.setOutputName),
          ],
          if (state.isMerging) ...[
            const SizedBox(height: 20),
            _ProgressSection(state: state),
          ],
          if (state.status == MergeStatus.error && state.errorMessage != null) ...[
            const SizedBox(height: 16),
            _ErrorBanner(message: state.errorMessage!),
          ],
          if (state.canMerge && !state.isMerging) ...[
            const SizedBox(height: 24),
            _MergeButton(onTap: notifier.merge),
          ],
          if (state.hasFiles && !state.canMerge && !state.isMerging) ...[
            const SizedBox(height: 16),
            _HintBanner(),
          ],
          const SizedBox(height: 32),
          _InfoNote(),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final MergeState state;
  final MergeNotifier notifier;
  const _ResultView({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: MergeResultCard(result: state.result!, onShare: notifier.shareResult, onReset: notifier.reset),
    );
  }
}

class _AddFilesButton extends StatelessWidget {
  final int fileCount;
  final VoidCallback onTap;
  final bool isLoading;
  const _AddFilesButton({required this.fileCount, required this.onTap, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (fileCount == 0) {
      return GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF131316),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2A2A35), width: 1.5),
          ),
          child: Column(
            children: [
              const Text('🔗', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 14),
              const Text('Select PDFs to merge',
                style: TextStyle(fontFamily: 'Syne', fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFF0EEE8))),
              const SizedBox(height: 6),
              const Text('Choose 2 or more PDF files in any order',
                style: TextStyle(fontSize: 11, color: Color(0xFF888899))),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B2B),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: const Color(0xFFFF6B2B).withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 4))],
                ),
                child: isLoading
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D0D0F)))
                    : const Text('Browse Files',
                        style: TextStyle(fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0D0D0F))),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF131316),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFF6B2B).withOpacity(0.35), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B2B).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('+', style: TextStyle(fontSize: 18, color: Color(0xFFFF6B2B)))),
            ),
            const SizedBox(width: 10),
            const Text('Add More PDFs',
              style: TextStyle(fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFFF6B2B))),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final String? trailing;
  const _SectionLabel({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label.toUpperCase(),
          style: const TextStyle(fontFamily: 'Syne', fontSize: 11, fontWeight: FontWeight.w700,
            letterSpacing: 1.5, color: Color(0xFF888899))),
        if (trailing != null)
          Text(trailing!, style: const TextStyle(fontSize: 11, color: Color(0xFF444455))),
      ],
    );
  }
}

class _OutputNameField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  const _OutputNameField({required this.initialValue, required this.onChanged});

  @override
  State<_OutputNameField> createState() => _OutputNameFieldState();
}

class _OutputNameFieldState extends State<_OutputNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131316),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: const TextStyle(fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFF0EEE8)),
        decoration: const InputDecoration(
          hintText: 'e.g. merged_contract  (optional)',
          hintStyle: TextStyle(fontSize: 12, color: Color(0xFF444455)),
          suffixText: '.pdf',
          suffixStyle: TextStyle(fontSize: 12, color: Color(0xFF888899)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cursorColor: const Color(0xFFFF6B2B),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final MergeState state;
  const _ProgressSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = state.progress;
    final label = state.totalPages > 0
        ? 'Processing page \${state.currentPage} of \${state.totalPages}…'
        : 'Preparing…';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131316),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🔗  Merging…',
                style: TextStyle(fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFF0EEE8))),
              Text('\${(progress * 100).toInt()}%',
                style: const TextStyle(fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFFF6B2B))),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress > 0 ? progress : null,
              backgroundColor: const Color(0xFF2A2A35),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B2B)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF888899))),
        ],
      ),
    );
  }
}

class _MergeButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MergeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B2B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFFFF6B2B).withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 6))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🔗', style: TextStyle(fontSize: 18)),
            SizedBox(width: 10),
            Text('Merge PDFs',
              style: TextStyle(fontFamily: 'Syne', fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0D0D0F))),
          ],
        ),
      ),
    );
  }
}

class _HintBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF60A5FA).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.25)),
      ),
      child: const Row(
        children: [
          Text('💡', style: TextStyle(fontSize: 14)),
          SizedBox(width: 10),
          Expanded(
            child: Text('Add at least one more PDF to enable merging.',
              style: TextStyle(fontSize: 12, color: Color(0xFF60A5FA))),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF87171).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF87171).withOpacity(0.27)),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFFF87171)))),
        ],
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131316),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ℹ️  Tips',
            style: TextStyle(fontFamily: 'Syne', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF888899))),
          SizedBox(height: 8),
          Text(
            '• Drag the ≡ handle to reorder files before merging.\n'
            '• The output order matches the list from top to bottom.\n'
            '• The output name is optional — a timestamp is used if left blank.',
            style: TextStyle(fontSize: 11, color: Color(0xFF444455), height: 1.7),
          ),
        ],
      ),
    );
  }
}
DART

echo "✅  merge_pdf_page.dart"

# ── 14. config/di/merge_pdf_di.dart ──────────────────────────────────────────

cat > lib/config/di/merge_pdf_di.dart << 'DART'
import 'package:get_it/get_it.dart';

import '../../features/merge_pdf/data/datasources/merge_pdf_datasource.dart';
import '../../features/merge_pdf/data/datasources/merge_pdf_datasource_impl.dart';
import '../../features/merge_pdf/data/repositories/merge_pdf_repository_impl.dart';
import '../../features/merge_pdf/domain/repositories/merge_pdf_repository.dart';
import '../../features/merge_pdf/domain/usecases/merge_pdf_usecase.dart';

void setupMergePdfDi(GetIt sl) {
  sl.registerLazySingleton<MergePdfDatasource>(
    () => MergePdfDatasourceImpl(),
  );
  sl.registerLazySingleton<MergePdfRepository>(
    () => MergePdfRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<MergePdfUsecase>(
    () => MergePdfUsecase(sl()),
  );
}
DART

echo "✅  merge_pdf_di.dart"

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "🎉  All 14 files created successfully!"
echo ""
echo "Next steps:"
echo "  1. Add to pubspec.yaml:   uuid: ^4.3.3   (if not already present)"
echo "  2. Run:                   flutter pub get"
echo "  3. Add to injection.dart: setupMergePdfDi(sl);"
echo "  4. Add to route_names.dart:"
echo "       static const mergePdf = '/merge-pdf';"
echo "  5. Add to app_router.dart:"
echo "       GoRoute(path: RouteNames.mergePdf, builder: (_, __) => const MergePdfPage()),"
echo "  6. Navigate from dashboard:"
echo "       context.go(RouteNames.mergePdf);"
