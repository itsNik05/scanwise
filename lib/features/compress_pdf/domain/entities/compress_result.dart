import 'compression_level.dart';

class CompressResult {
  final String originalPath;
  final String compressedPath;
  final String fileName;
  final int originalSize;
  final int compressedSize;
  final CompressionLevel level;

  const CompressResult({
    required this.originalPath,
    required this.compressedPath,
    required this.fileName,
    required this.originalSize,
    required this.compressedSize,
    required this.level,
  });

  double get compressionRatio =>
      originalSize > 0 ? (1 - compressedSize / originalSize) : 0.0;

  int get savedBytes => originalSize - compressedSize;

  String get savedBytesFormatted => _formatBytes(savedBytes);
  String get originalSizeFormatted => _formatBytes(originalSize);
  String get compressedSizeFormatted => _formatBytes(compressedSize);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}