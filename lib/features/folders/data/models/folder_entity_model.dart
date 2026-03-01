import '../../domain/entities/folder_entity.dart';

class FolderEntityModel extends FolderEntity {
  const FolderEntityModel({
    required super.name,
    required super.path,
    required super.createdAt,
  });
}