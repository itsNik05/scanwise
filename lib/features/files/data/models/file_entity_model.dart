import '../../domain/entities/file_entity.dart';

class FileEntityModel extends FileEntity {
  const FileEntityModel({
    required super.name,
    required super.path,
    required super.size,
    required super.createdAt,
  });

  factory FileEntityModel.fromFile(
      String name,
      String path,
      int size,
      DateTime createdAt,
      ) {
    return FileEntityModel(
      name: name,
      path: path,
      size: size,
      createdAt: createdAt,
    );
  }
}