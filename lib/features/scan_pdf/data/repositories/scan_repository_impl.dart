/// ------------------------------------------------------------
/// ScanRepositoryImpl
/// ------------------------------------------------------------
/// Implements ScanRepository.
/// Connects domain layer with datasource.
/// ------------------------------------------------------------

import '../../domain/entities/scanned_document.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/scan_local_datasource.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ScanLocalDatasource datasource;

  ScanRepositoryImpl(this.datasource);

  @override
  Future<ScannedDocument> scanDocument() async {
    final filePath = await datasource.scanDocument();

    return ScannedDocument(
      filePath: filePath,
      createdAt: DateTime.now(),
      pageCount: 1,
    );
  }

  @override
  Future<void> saveDocument(ScannedDocument document) async {
    await datasource.saveDocument(document.filePath);
  }
}