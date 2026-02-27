/// ------------------------------------------------------------
/// Scan Providers
/// ------------------------------------------------------------
/// Handles dependency injection and state management
/// for scan feature using Riverpod.
/// ------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/scan_local_datasource.dart';
import '../../data/repositories/scan_repository_impl.dart';
import '../../domain/repositories/scan_repository.dart';
import '../../domain/usecases/scan_document_usecase.dart';
import '../../../../core/services/storage_service.dart';

/// Repository Provider
final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  final datasource = ref.read(scanLocalDatasourceProvider);
  return ScanRepositoryImpl(datasource);
});

/// UseCase Provider
final scanDocumentUseCaseProvider = Provider<ScanDocumentUseCase>((ref) {
  final repository = ref.read(scanRepositoryProvider);
  return ScanDocumentUseCase(repository);
});

/// Scan State Provider (Async)
final scanControllerProvider =
FutureProvider.autoDispose((ref) async {
  final useCase = ref.read(scanDocumentUseCaseProvider);
  return await useCase();
});

/// ------------------------------------------------------------
/// Dependency Injection - Scan Feature
/// ------------------------------------------------------------
/// This section wires the Scan feature dependencies using Riverpod.
///
/// Flow:
/// UI → UseCase → Repository → Datasource → StorageService
///
/// storageServiceProvider:
///     Provides core file storage functionality from core layer.
///     Responsible for creating ScanWise folder and saving files.
///
/// scanLocalDatasourceProvider:
///     Injects StorageService into ScanLocalDatasource.
///     Datasource handles actual file creation logic.
///
/// IMPORTANT:
/// - No object creation inside UI
/// - All dependencies are provided here
/// - Maintains Clean Architecture separation
/// ------------------------------------------------------------

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final scanLocalDatasourceProvider =
Provider<ScanLocalDatasource>((ref) {
  final storage = ref.read(storageServiceProvider);
  return ScanLocalDatasource(storage);
});