import '../entities/scanned_document.dart';
import '../repositories/scan_repository.dart';

class SaveScannedDocumentUseCase {
  final ScanRepository repository;

  SaveScannedDocumentUseCase(this.repository);

  Future<ScannedDocument> call({
    required List<String> pagePaths,
    required String fileName,
    String? folderId,
  }) {
    return repository.saveDocument(
      pagePaths: pagePaths,
      fileName: fileName,
      folderId: folderId,
    );
  }
}