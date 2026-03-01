import '../../domain/entities/scanned_document.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/scan_mlkit_datasource.dart';
import '../datasources/image_processing_datasource.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ScanMlkitDatasource mlkitDatasource;
  final ImageProcessingDatasource imageDatasource;

  ScanRepositoryImpl({
    required this.mlkitDatasource,
    required this.imageDatasource,
  });

  @override
  Future<List<String>> scanPages() {
    return mlkitDatasource.scanPages();
  }

  @override
  Future<String> cropPage({
    required String imagePath,
    required List<double> cropPoints,
  }) {
    return imageDatasource.crop(
      imagePath: imagePath,
      cropPoints: cropPoints,
    );
  }

  @override
  Future<String> applyFilter({
    required String imagePath,
    required String filterType,
  }) {
    return imageDatasource.applyFilter(
      imagePath: imagePath,
      filterType: filterType,
    );
  }

  @override
  Future<ScannedDocument> saveDocument({
    required List<String> pagePaths,
    required String fileName,
    required String? folderId,
  }) async {

    final PdfDocument document = PdfDocument();

    for (final imagePath in pagePaths) {
      final File imageFile = File(imagePath);
      final List<int> imageBytes = await imageFile.readAsBytes();

      final PdfPage page = document.pages.add();
      final PdfBitmap bitmap = PdfBitmap(imageBytes);

      page.graphics.drawImage(
        bitmap,
        Rect.fromLTWH(
          0,
          0,
          page.getClientSize().width,
          page.getClientSize().height,
        ),
      );
    }

    final List<int> pdfBytes = await document.save();
    document.dispose();

    final appDir = await getApplicationDocumentsDirectory();

    final scannedDir = Directory(
      '${appDir.path}/Scanned_Pdfs',
    );

    if (!await scannedDir.exists()) {
      await scannedDir.create(recursive: true);
    }

    // 🔥 DO NOT REDECLARE fileName
    // Just modify if needed
    String finalName = fileName.trim();

    if (finalName.isEmpty) {
      finalName = 'Scan_${DateTime.now().millisecondsSinceEpoch}';
    }

    if (!finalName.toLowerCase().endsWith('.pdf')) {
      finalName = '$finalName.pdf';
    }

    final String filePath =
        '${scannedDir.path}/$finalName';

    final File pdfFile = File(filePath);
    await pdfFile.writeAsBytes(pdfBytes);

    print("📄 Saved as: $filePath");

    return ScannedDocument(
      id: filePath,
      pagePaths: [filePath],
      folderId: folderId,
      createdAt: DateTime.now(),
    );
  }
}