import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/folder_entity.dart';
import '../../domain/repositories/folder_repository.dart';
import '../models/folder_entity_model.dart';

class FolderRepositoryImpl implements FolderRepository {

  @override
  Future<List<FolderEntity>> getFolders() async {
    final directory = await getApplicationDocumentsDirectory();
    final root = Directory('${directory.path}/Scanned_Pdfs');

    if (!await root.exists()) {
      await root.create(recursive: true);
    }

    final folders = root
        .listSync()
        .whereType<Directory>()
        .toList();

    return folders.map((folder) {
      final stat = folder.statSync();
      return FolderEntityModel(
        name: folder.path.split(Platform.pathSeparator).last,
        path: folder.path,
        createdAt: stat.changed,
      );
    }).toList();
  }

  @override
  Future<void> createFolder(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final root = Directory('${directory.path}/Scanned_Pdfs');

    final newFolder = Directory('${root.path}/$name');

    if (!await newFolder.exists()) {
      await newFolder.create(recursive: true);
    }
  }

  @override
  Future<void> renameFolder(String oldPath, String newName) async {
    final directory = Directory(oldPath);

    if (!await directory.exists()) return;

    final parentPath =
        directory.parent.path;

    final newPath =
        '$parentPath${Platform.pathSeparator}$newName';

    await directory.rename(newPath);
  }

  @override
  Future<void> deleteFolder(String folderPath) async {
    final directory = Directory(folderPath);

    if (!await directory.exists()) return;

    // SAFETY: Only delete if empty
    final contents = directory.listSync();
    if (contents.isEmpty) {
      await directory.delete();
    } else {
      throw Exception(
          "Folder is not empty. Please move or delete files first.");
    }
  }
}