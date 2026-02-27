/// ------------------------------------------------------------
/// ScannedDocument
/// ------------------------------------------------------------
/// Core domain entity representing a scanned PDF document.
/// Pure Dart. No Flutter imports.
/// ------------------------------------------------------------

class ScannedDocument {
  final String filePath;
  final DateTime createdAt;
  final int pageCount;

  const ScannedDocument({
    required this.filePath,
    required this.createdAt,
    required this.pageCount,
  });
}