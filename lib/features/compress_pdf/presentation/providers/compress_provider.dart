import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/datasources/compress_pdf_datasource_impl.dart';
import '../../data/repositories/compress_pdf_repository_impl.dart';
import '../../domain/entities/compression_level.dart';
import '../../domain/usecases/compress_pdf_usecase.dart';
import 'compress_state.dart';
import '../../compress_pdf_providers.dart';

// ── Providers ──────────────────────────────────────────────────────────────

final compressPdfProvider =
StateNotifierProvider.autoDispose<CompressNotifier, CompressState>(
      (ref) {
    final usecase = ref.read(compressPdfUsecaseProvider);
    final repository =
    ref.read(compressPdfRepositoryProvider) as CompressPdfRepositoryImpl;

    return CompressNotifier(usecase, repository);
  },
);

// ── Notifier ───────────────────────────────────────────────────────────────

class CompressNotifier extends StateNotifier<CompressState> {
  final CompressPdfUsecase _usecase;
  final CompressPdfRepositoryImpl _repository;

  CompressNotifier(this._usecase, this._repository)
      : super(const CompressState());

  // ── File picking ──────────────────────────────────────────────────────────

  Future<void> pickFile() async {
    state = state.copyWith(status: CompressStatus.picking);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        state = state.copyWith(status: CompressStatus.idle);
        return;
      }

      final file = result.files.first;
      final filePath = file.path;
      if (filePath == null) {
        state = state.copyWith(
          status: CompressStatus.error,
          errorMessage: 'Could not access the selected file.',
        );
        return;
      }

      final fileSize = await File(filePath).length();

      state = state.copyWith(
        status: CompressStatus.idle,
        selectedFilePath: filePath,
        selectedFileName: file.name,
        selectedFileSize: fileSize,
        result: null,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: CompressStatus.error,
        errorMessage: 'Failed to pick file: $e',
      );
    }
  }

  // ── Level selection ───────────────────────────────────────────────────────

  void setLevel(CompressionLevel level) {
    state = state.copyWith(level: level, result: null);
  }

  // ── Compression ───────────────────────────────────────────────────────────

  Future<void> compress() async {
    final filePath = state.selectedFilePath;
    if (filePath == null) return;

    // Wire up live page progress via the repository callback
    _repository.onProgress = (current, total) {
      if (mounted) {
        state = state.copyWith(
          currentPage: current,
          totalPages: total,
        );
      }
    };

    state = state.copyWith(
      status: CompressStatus.compressing,
      currentPage: 0,
      totalPages: 0,
      result: null,
      errorMessage: null,
    );

    try {
      final result = await _usecase(
        inputPath: filePath,
        level: state.level,
      );

      state = state.copyWith(
        status: CompressStatus.done,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        status: CompressStatus.error,
        errorMessage: 'Compression failed: $e',
      );
    } finally {
      _repository.onProgress = null;
    }
  }

  // ── Share ─────────────────────────────────────────────────────────────────

  Future<void> shareResult() async {
    final path = state.result?.compressedPath;
    if (path == null) return;
    await Share.shareXFiles([XFile(path)], text: 'Compressed PDF');
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void reset() => state = state.reset();
}