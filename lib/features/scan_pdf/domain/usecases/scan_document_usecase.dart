/// ------------------------------------------------------------
/// ScanDocumentUseCase
/// ------------------------------------------------------------
/// Executes scanning logic using ScanRepository.
/// Keeps business logic separated from UI.
/// ------------------------------------------------------------

import '../entities/scanned_document.dart';
import '../repositories/scan_repository.dart';

class ScanDocumentUseCase {
  final ScanRepository repository;

  ScanDocumentUseCase(this.repository);

  Future<ScannedDocument> call() async {
    final document = await repository.scanDocument();
    await repository.saveDocument(document);
    return document;
  }
}