import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'scan_mlkit_datasource.dart';

class ScanMlkitDatasourceImpl implements ScanMlkitDatasource {

  @override
  Future<List<String>> scanPages() async {
    final scanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormat: DocumentFormat.jpeg,
        mode: ScannerMode.full,
      ),
    );

    try {
      final result = await scanner.scanDocument();

      if (result == null) {
        return [];
      }

      // Version 0.3.0 returns images as imagePaths
      return result.images;
    } finally {
      scanner.close();
    }
  }
}