class FileEntity {
  final String name;
  final String path;
  final int size;
  final DateTime createdAt;

  const FileEntity({
    required this.name,
    required this.path,
    required this.size,
    required this.createdAt,
  });
}