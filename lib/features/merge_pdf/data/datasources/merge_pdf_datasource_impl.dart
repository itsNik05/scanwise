import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' show PdfPageFormat;

import 'package:pdfx/pdfx.dart' as pdfx;
import 'merge_pdf_datasource.dart';

class MergePdfDatasourceImpl implements MergePdfDatasource {
  static const double _renderScale = 1.5;
  static const int _jpegQuality = 88;

  @override
  Future<int> getPageCount(String path) async {
    final doc = await pdfx.PdfDocument.openFile(path);
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
      final doc = await pdfx.PdfDocument.openFile(path);
      totalPages += doc.pagesCount;
      await doc.close();
    }

    final newPdf = pw.Document(compress: true);
    int processedPages = 0;

    for (final inputPath in inputPaths) {
      final document = await pdfx.PdfDocument.openFile(inputPath);

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
          format: pdfx.PdfPageImageFormat.jpeg,
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
    final mergedDir = Directory(
      p.join(outputDir.path, 'Scanned_Pdfs'),
    );
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
