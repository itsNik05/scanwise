import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/compress_pdf_datasource.dart';
import 'data/datasources/compress_pdf_datasource_impl.dart';
import 'data/repositories/compress_pdf_repository_impl.dart';
import 'domain/repositories/compress_pdf_repository.dart';
import 'domain/usecases/compress_pdf_usecase.dart';

final compressPdfDatasourceProvider =
Provider<CompressPdfDatasource>((ref) {
  return CompressPdfDatasourceImpl();
});

final compressPdfRepositoryProvider =
Provider<CompressPdfRepository>((ref) {
  final datasource = ref.read(compressPdfDatasourceProvider);
  return CompressPdfRepositoryImpl(datasource);
});

final compressPdfUsecaseProvider =
Provider<CompressPdfUsecase>((ref) {
  final repository = ref.read(compressPdfRepositoryProvider);
  return CompressPdfUsecase(repository);
});