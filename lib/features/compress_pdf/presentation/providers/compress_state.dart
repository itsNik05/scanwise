import '../../domain/entities/compress_result.dart';
import '../../domain/entities/compression_level.dart';

enum CompressStatus { idle, picking, compressing, done, error }

class CompressState {
  final CompressStatus status;
  final String? selectedFilePath;
  final String? selectedFileName;
  final int? selectedFileSize;
  final CompressionLevel level;
  final int currentPage;
  final int totalPages;
  final CompressResult? result;
  final String? errorMessage;

  const CompressState({
    this.status = CompressStatus.idle,
    this.selectedFilePath,
    this.selectedFileName,
    this.selectedFileSize,
    this.level = CompressionLevel.medium,
    this.currentPage = 0,
    this.totalPages = 0,
    this.result,
    this.errorMessage,
  });

  double get progress =>
      totalPages == 0 ? 0.0 : currentPage / totalPages;

  bool get hasFile => selectedFilePath != null;

  bool get isCompressing => status == CompressStatus.compressing;

  CompressState copyWith({
    CompressStatus? status,
    String? selectedFilePath,
    String? selectedFileName,
    int? selectedFileSize,
    CompressionLevel? level,
    int? currentPage,
    int? totalPages,
    CompressResult? result,
    String? errorMessage,
  }) {
    return CompressState(
      status: status ?? this.status,
      selectedFilePath: selectedFilePath ?? this.selectedFilePath,
      selectedFileName: selectedFileName ?? this.selectedFileName,
      selectedFileSize: selectedFileSize ?? this.selectedFileSize,
      level: level ?? this.level,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  CompressState reset() => const CompressState();
}