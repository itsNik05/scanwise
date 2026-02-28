import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/folders/data/repositories/folder_repository_impl.dart';
import '../../features/folders/domain/repositories/folder_repository.dart';
import '../../features/folders/domain/usecases/get_folders_usecase.dart';
import '../../features/folders/domain/usecases/create_folder_usecase.dart';

final folderRepositoryProvider = Provider<FolderRepository>(
      (ref) => FolderRepositoryImpl(),
);

final getFoldersUseCaseProvider = Provider<GetFoldersUseCase>(
      (ref) => GetFoldersUseCase(
    ref.read(folderRepositoryProvider),
  ),
);

final createFolderUseCaseProvider = Provider<CreateFolderUseCase>(
      (ref) => CreateFolderUseCase(
    ref.read(folderRepositoryProvider),
  ),
);