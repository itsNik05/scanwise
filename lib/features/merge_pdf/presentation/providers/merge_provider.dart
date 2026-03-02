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
import '../../merge_pdf_providers.dart';

final mergePdfProvider =
StateNotifierProvider.autoDispose<MergeNotifier, MergeState>(
      (ref) {
    final usecase = ref.read(mergePdfUsecaseProvider);
    final repository =
    ref.read(mergePdfRepositoryProvider) as MergePdfRepositoryImpl;

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
