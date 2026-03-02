import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as pdfx;

import '../../domain/entities/compression_level.dart';
import 'compress_pdf_datasource.dart';

class CompressPdfDatasourceImpl implements CompressPdfDatasource {
  @override
  Future<String> compressAndSave({
    required String inputPath,
    required CompressionLevel level,
    required void Function(int current, int total) onProgress,
  }) async {
    // 1. Open source PDF via pdfx
    final document = await pdfx.PdfDocument.openFile(inputPath);
    final pageCount = document.pagesCount;

    // 2. Build a new PDF document page by page
    final newPdf = pw.Document(compress: true);

    for (int i = 1; i <= pageCount; i++) {
      onProgress(i, pageCount);

      final page = await document.getPage(i);
      final originalWidth = page.width;
      final originalHeight = page.height;

      // Render at the scale defined by the compression level
      final renderWidth = (originalWidth * level.renderScale).round();
      final renderHeight = (originalHeight * level.renderScale).round();

      // ✅ Fix 1: Render directly at target quality — no double encode
      final pageImage = await page.render(
        width: renderWidth.toDouble(),
        height: renderHeight.toDouble(),
        format: pdfx.PdfPageImageFormat.jpeg,
        quality: level.imageQuality,
        backgroundColor: '#FFFFFF',
      );

      await page.close();

      if (pageImage == null) continue;

      // ✅ Use bytes directly — no decode/re-encode cycle
      final pdfImage = pw.MemoryImage(pageImage.bytes);

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

    // 3. Save the new PDF to the app's documents directory
    final outputDir = await getApplicationDocumentsDirectory();

    final scannedDir = Directory(
      p.join(outputDir.path, 'Scanned_Pdfs'),
    );

    if (!scannedDir.existsSync()) {
      scannedDir.createSync(recursive: true);
    }

    final originalName = p.basenameWithoutExtension(inputPath);
    final outputFileName =
        '${originalName}_compressed_${level.label.toLowerCase()}.pdf';
    final outputPath = p.join(scannedDir.path, outputFileName);

    final outputBytes = await newPdf.save();
    await File(outputPath).writeAsBytes(outputBytes);

    // ✅ Fix 2: Always keep the smaller file
    final originalSize = await File(inputPath).length();
    final compressedSize = await File(outputPath).length();

    if (compressedSize >= originalSize) {
      // Compressed is not smaller — copy original instead
      await File(outputPath).delete();
      await File(inputPath).copy(outputPath);
    }

    return outputPath;
  }
}