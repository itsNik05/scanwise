/// ------------------------------------------------------------
/// ScanLocalDatasource
/// ------------------------------------------------------------
/// Handles actual scanning and saving logic.
/// Later this will integrate:
/// - Camera
/// - ML Kit
/// - PDF generation
/// ------------------------------------------------------------

import 'dart:io';

class ScanLocalDatasource {
  Future<String> scanDocument() async {
    // TODO: integrate camera + PDF generation
    // Simulating a scanned file path
    await Future.delayed(const Duration(seconds: 1));
    return "scanned_document_${DateTime.now().millisecondsSinceEpoch}.pdf";
  }

  Future<void> saveDocument(String filePath) async {
    // TODO: integrate real file storage
    await Future.delayed(const Duration(milliseconds: 500));
  }
}