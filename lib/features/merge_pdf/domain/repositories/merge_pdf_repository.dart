import '../entities/merged_document.dart';

abstract class MergePdfRepository {
  Future<MergedDocument> mergePdfs({
    required List<String> inputPaths,
    required String outputName,
  });
}
