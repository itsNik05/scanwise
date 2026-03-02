class MergedDocument {
  final List<String> sourcePaths;
  final String outputPath;
  final String outputName;
  final int totalPages;
  final int outputSize;

  const MergedDocument({
    required this.sourcePaths,
    required this.outputPath,
    required this.outputName,
    required this.totalPages,
    required this.outputSize,
  });

  int get fileCount => sourcePaths.length;

  String get outputSizeFormatted {
    if (outputSize < 1024) return '$outputSize B';
    if (outputSize < 1024 * 1024) {
      return '${(outputSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(outputSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
