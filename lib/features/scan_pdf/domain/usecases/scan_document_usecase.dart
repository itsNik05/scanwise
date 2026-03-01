import '../repositories/scan_repository.dart';

class ScanDocumentUseCase {
  final ScanRepository repository;

  ScanDocumentUseCase(this.repository);

  Future<List<String>> call() {
    return repository.scanPages();
  }
}