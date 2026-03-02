import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/merge_pdf_datasource.dart';
import 'data/datasources/merge_pdf_datasource_impl.dart';
import 'data/repositories/merge_pdf_repository_impl.dart';
import 'domain/repositories/merge_pdf_repository.dart';
import 'domain/usecases/merge_pdf_usecase.dart';

final mergePdfDatasourceProvider =
Provider<MergePdfDatasource>((ref) {
  return MergePdfDatasourceImpl();
});

final mergePdfRepositoryProvider =
Provider<MergePdfRepository>((ref) {
  final datasource = ref.read(mergePdfDatasourceProvider);
  return MergePdfRepositoryImpl(datasource);
});

final mergePdfUsecaseProvider =
Provider<MergePdfUsecase>((ref) {
  final repository = ref.read(mergePdfRepositoryProvider);
  return MergePdfUsecase(repository);
});