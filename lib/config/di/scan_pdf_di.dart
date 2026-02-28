import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/scan_pdf/data/datasources/scan_local_datasource.dart';
import '../../features/scan_pdf/data/repositories/scan_repository_impl.dart';
import '../../features/scan_pdf/domain/repositories/scan_repository.dart';
import '../../features/scan_pdf/domain/usecases/generate_pdf_usecase.dart';
import '../../features/scan_pdf/domain/usecases/save_scanned_file_usecase.dart';

final scanLocalDatasourceProvider =
Provider((ref) => ScanLocalDatasource());

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepositoryImpl(
    ref.read(scanLocalDatasourceProvider),
  );
});

final generatePdfUseCaseProvider =
Provider((ref) => GeneratePdfUseCase(
  ref.read(scanRepositoryProvider),
));

final saveScannedFileUseCaseProvider =
Provider((ref) => SaveScannedFileUseCase(
  ref.read(scanRepositoryProvider),
));