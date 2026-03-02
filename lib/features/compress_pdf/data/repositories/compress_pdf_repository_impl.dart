import 'dart:io';

import '../../domain/entities/compress_result.dart';
import '../../domain/entities/compression_level.dart';
import '../../domain/repositories/compress_pdf_repository.dart';
import '../datasources/compress_pdf_datasource.dart';

class CompressPdfRepositoryImpl implements CompressPdfRepository {
  final CompressPdfDatasource _datasource;

  // Exposed so the provider can listen to live progress
  void Function(int current, int total)? onProgress;

  CompressPdfRepositoryImpl(this._datasource);

  @override
  Future<CompressResult> compressPdf({
    required String inputPath,
    required CompressionLevel level,
  }) async {
    final originalFile = File(inputPath);
    final originalSize = await originalFile.length();
    final fileName = originalFile.uri.pathSegments.last;

    final compressedPath = await _datasource.compressAndSave(
      inputPath: inputPath,
      level: level,
      onProgress: onProgress ?? (_, __) {},
    );

    final compressedSize = await File(compressedPath).length();

    return CompressResult(
      originalPath: inputPath,
      compressedPath: compressedPath,
      fileName: fileName,
      originalSize: originalSize,
      compressedSize: compressedSize,
      level: level,
    );
  }
}