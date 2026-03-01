import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/scan_mlkit_datasource_impl.dart';
import '../../data/datasources/image_processing_datasource_impl.dart';
import '../../data/repositories/scan_repository_impl.dart';
import '../../domain/usecases/scan_document_usecase.dart';
import '../../domain/usecases/save_scanned_document_usecase.dart';
import '../../domain/repositories/scan_repository.dart';
import '../../data/datasources/scan_mlkit_datasource.dart';
import '../../data/datasources/image_processing_datasource.dart';

final scanMlkitDatasourceProvider =
Provider<ScanMlkitDatasource>(
        (ref) => ScanMlkitDatasourceImpl());

final imageProcessingDatasourceProvider =
Provider<ImageProcessingDatasource>(
        (ref) => ImageProcessingDatasourceImpl());

final scanRepositoryProvider =
Provider<ScanRepository>((ref) {
  return ScanRepositoryImpl(
    mlkitDatasource: ref.read(scanMlkitDatasourceProvider),
    imageDatasource: ref.read(imageProcessingDatasourceProvider),
  );
});

final scanDocumentUseCaseProvider = Provider((ref) {
  return ScanDocumentUseCase(
    ref.read(scanRepositoryProvider),
  );
});

final saveScannedDocumentUseCaseProvider =
Provider((ref) {
  return SaveScannedDocumentUseCase(
    ref.read(scanRepositoryProvider),
  );
});