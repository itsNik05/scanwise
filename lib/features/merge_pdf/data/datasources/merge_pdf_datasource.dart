abstract class MergePdfDatasource {
  Future<String> mergeAndSave({
    required List<String> inputPaths,
    required String outputName,
    required void Function(int current, int total) onProgress,
  });

  Future<int> getPageCount(String path);
}
