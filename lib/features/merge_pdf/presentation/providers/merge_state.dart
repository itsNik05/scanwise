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
