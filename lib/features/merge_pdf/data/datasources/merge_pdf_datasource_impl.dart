import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'merge_pdf_datasource.dart';
import 'native_merge_channel.dart';

class MergePdfDatasourceImpl implements MergePdfDatasource {
  final _channel = NativeMergeChannel();

  @override
  Future<int> getPageCount(String path) async {
    // Optional: you can keep pdfx for this
    return 0;
  }

  @override
  Future<String> mergeAndSave({
    required List<String> inputPaths,
    required String outputName,
    required void Function(int current, int total) onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final scannedDir =
    Directory(p.join(dir.path, 'Scanned_Pdfs'));

    if (!scannedDir.existsSync()) {
      scannedDir.createSync(recursive: true);
    }

    final safeName =
    outputName.trim().isEmpty ? 'merged' : outputName.trim();

    final fileName =
    safeName.endsWith('.pdf') ? safeName : '$safeName.pdf';

    final outputPath = p.join(scannedDir.path, fileName);

    return await _channel.merge(
      inputPaths: inputPaths,
      outputPath: outputPath,
    );
  }
}