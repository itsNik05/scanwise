import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/folder_entity.dart';
import '../../domain/usecases/get_folders_usecase.dart';
import '../../domain/usecases/create_folder_usecase.dart';
import '../../../../config/di/folders_di.dart';
import '../../domain/usecases/rename_folder_usecase.dart';
import '../../domain/usecases/delete_folder_usecase.dart';

class FolderNotifier extends StateNotifier<AsyncValue<List<FolderEntity>>> {
  final GetFoldersUseCase getFolders;
  final CreateFolderUseCase createFolder;
  final RenameFolderUseCase renameFolderUseCase;
  final DeleteFolderUseCase deleteFolderUseCase;

  FolderNotifier({
    required this.getFolders,
    required this.createFolder,
    required this.renameFolderUseCase,
    required this.deleteFolderUseCase,
  }) : super(const AsyncValue.loading()) {
    loadFolders();
  }

  Future<void> loadFolders() async {
    try {
      state = const AsyncValue.loading();
      final folders = await getFolders();
      state = AsyncValue.data(folders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createNewFolder(String name) async {
    await createFolder(name);
    await loadFolders();
  }

  Future<void> renameFolder(
      String oldPath, String newName) async {
    await renameFolderUseCase(oldPath, newName);
    await loadFolders();
  }

  Future<void> deleteFolder(String folderPath) async {
    await deleteFolderUseCase(folderPath);
    await loadFolders();
  }

}

final folderProvider =
StateNotifierProvider<FolderNotifier,
    AsyncValue<List<FolderEntity>>>(
      (ref) => FolderNotifier(
    getFolders: ref.read(getFoldersUseCaseProvider),
    createFolder: ref.read(createFolderUseCaseProvider),
    renameFolderUseCase:
    ref.read(renameFolderUseCaseProvider),
    deleteFolderUseCase:
    ref.read(deleteFolderUseCaseProvider),
  ),
);