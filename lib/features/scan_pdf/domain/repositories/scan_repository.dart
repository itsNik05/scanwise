/// ------------------------------------------------------------
/// ScanRepository
/// ------------------------------------------------------------
/// Abstract contract for scanning and saving documents.
/// Domain depends only on this interface.
/// ------------------------------------------------------------

import '../entities/scanned_document.dart';

abstract class ScanRepository {
  Future<ScannedDocument> scanDocument();
  Future<void> saveDocument(ScannedDocument document);
}