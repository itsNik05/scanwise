/// ------------------------------------------------------------
/// ScanLocalDatasource
/// ------------------------------------------------------------
/// Handles scanning + saving using StorageService.
/// ------------------------------------------------------------

import 'package:scanwise/core/services/storage_service.dart';

class ScanLocalDatasource {
  final StorageService storageService;

  ScanLocalDatasource(this.storageService);

  Future<String> scanDocument() async {
    final fileName =
        "scanned_${DateTime.now().millisecondsSinceEpoch}.pdf";

    final filePath =
    await storageService.createEmptyPdf(fileName);

    return filePath;
  }

  Future<void> saveDocument(String filePath) async {
    // Already saved during scan
  }
}