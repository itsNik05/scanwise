import '../entities/merged_document.dart';
import '../repositories/merge_pdf_repository.dart';

class MergePdfUsecase {
  final MergePdfRepository _repository;

  const MergePdfUsecase(this._repository);

  Future<MergedDocument> call({
    required List<String> inputPaths,
    required String outputName,
  }) {
    return _repository.mergePdfs(
      inputPaths: inputPaths,
      outputName: outputName,
    );
  }
}
