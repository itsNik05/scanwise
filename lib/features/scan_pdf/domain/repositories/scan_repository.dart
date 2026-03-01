import '../entities/scanned_document.dart';

abstract class ScanRepository {
  Future<List<String>> scanPages();

  Future<String> cropPage({
    required String imagePath,
    required List<double> cropPoints,
  });

  Future<String> applyFilter({
    required String imagePath,
    required String filterType,
  });

  Future<ScannedDocument> saveDocument({
    required List<String> pagePaths,
    required String fileName,
    required String? folderId,
  });
}