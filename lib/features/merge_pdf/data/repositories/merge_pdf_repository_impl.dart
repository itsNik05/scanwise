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
