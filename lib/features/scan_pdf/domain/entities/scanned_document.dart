class ScannedDocument {
  final String id;
  final List<String> pagePaths; // image file paths
  final String? folderId;
  final DateTime createdAt;

  const ScannedDocument({
    required this.id,
    required this.pagePaths,
    this.folderId,
    required this.createdAt,
  });

  ScannedDocument copyWith({
    String? id,
    List<String>? pagePaths,
    String? folderId,
    DateTime? createdAt,
  }) {
    return ScannedDocument(
      id: id ?? this.id,
      pagePaths: pagePaths ?? this.pagePaths,
      folderId: folderId ?? this.folderId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}