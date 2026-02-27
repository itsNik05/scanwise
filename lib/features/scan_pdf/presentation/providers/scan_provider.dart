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

/// Datasource Provider
final scanLocalDatasourceProvider = Provider<ScanLocalDatasource>((ref) {
  return ScanLocalDatasource();
});

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