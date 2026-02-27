/// ------------------------------------------------------------
/// ScannedDocumentModel
/// ------------------------------------------------------------
/// Data layer representation of ScannedDocument.
/// Converts between JSON / file system and domain entity.
/// ------------------------------------------------------------

import '../../domain/entities/scanned_document.dart';

class ScannedDocumentModel extends ScannedDocument {
  const ScannedDocumentModel({
    required super.filePath,
    required super.createdAt,
    required super.pageCount,
  });

  factory ScannedDocumentModel.fromEntity(ScannedDocument entity) {
    return ScannedDocumentModel(
      filePath: entity.filePath,
      createdAt: entity.createdAt,
      pageCount: entity.pageCount,
    );
  }
}