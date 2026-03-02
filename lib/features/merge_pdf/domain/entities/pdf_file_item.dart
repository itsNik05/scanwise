class PdfFileItem {
  final String id;
  final String path;
  final String name;
  final int size;
  final int? pageCount;

  const PdfFileItem({
    required this.id,
    required this.path,
    required this.name,
    required this.size,
    this.pageCount,
  });

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  PdfFileItem copyWith({int? pageCount}) {
    return PdfFileItem(
      id: id,
      path: path,
      name: name,
      size: size,
      pageCount: pageCount ?? this.pageCount,
    );
  }
}
