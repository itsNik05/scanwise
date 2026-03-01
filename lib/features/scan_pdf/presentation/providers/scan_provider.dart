import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/scan_document_usecase.dart';
import '../../domain/usecases/save_scanned_document_usecase.dart';

import 'scan_state.dart';
import 'scan_di_provider.dart';

class ScanNotifier extends StateNotifier<ScanState> {
  final ScanDocumentUseCase scanUseCase;
  final SaveScannedDocumentUseCase saveScannedDocumentUseCase;

  ScanNotifier(
      this.scanUseCase,
      this.saveScannedDocumentUseCase,
      ) : super(const ScanState());

  Future<bool> scan() async {
    state = state.copyWith(isScanning: true);

    try {
      final pages = await scanUseCase();

      state = state.copyWith(
        isScanning: false,
        pages: pages,
      );

      return pages.isNotEmpty;
    } catch (e) {
      state = state.copyWith(isScanning: false);
      print("Scan error: $e");
      return false;
    }
  }

  Future<void> save(String fileName) async {
    final pages = state.pages;

    if (pages.isEmpty) return;

    await saveScannedDocumentUseCase(
      pagePaths: pages,
      fileName: fileName,
      folderId: null,
    );

    reset();
  }

  void reset() {
    state = const ScanState();
  }

  Future<void> scanMore() async {
    state = state.copyWith(isScanning: true);

    try {
      final newPages = await scanUseCase();

      if (newPages.isNotEmpty) {
        state = state.copyWith(
          isScanning: false,
          pages: [...state.pages, ...newPages], // 🔥 append
        );
      } else {
        state = state.copyWith(isScanning: false);
      }
    } catch (e) {
      state = state.copyWith(isScanning: false);
      print("Scan more error: $e");
    }
  }

  void removePage(String path) {
    final updated =
    state.pages.where((p) => p != path).toList();

    state = state.copyWith(pages: updated);
  }

  void reorderPages(int oldIndex, int newIndex) {
    final pages = [...state.pages];

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = pages.removeAt(oldIndex);
    pages.insert(newIndex, item);

    state = state.copyWith(pages: pages);
  }


}

final scanProvider =
StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier(
    ref.read(scanDocumentUseCaseProvider),
    ref.read(saveScannedDocumentUseCaseProvider),
  );
});