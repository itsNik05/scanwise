import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/usecases/get_scanned_files_usecase.dart';
import '../../domain/usecases/delete_file_usecase.dart';
import '../../../../config/di/files_di.dart';
import 'file_sort_type.dart';
import '../../domain/usecases/move_file_usecase.dart';

class FileNotifier extends StateNotifier<AsyncValue<List<FileEntity>>> {
  final GetScannedFilesUseCase getFiles;
  final DeleteFileUseCase deleteFileUseCase;
  bool _isSelectionMode = false;
  final Set<String> _selectedPaths = {};
  final MoveFileUseCase moveFileUseCase;

  final String? _folderPath;

  List<FileEntity> _allFiles = [];
  String _searchQuery = '';
  FileSortType _sortType = FileSortType.newest;
  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedPaths => _selectedPaths;

  FileNotifier({
    required this.getFiles,
    required this.deleteFileUseCase,
    required this.moveFileUseCase,
    String? folderPath,
  })  : _folderPath = folderPath,
        super(const AsyncValue.loading()) {
    loadFiles();
  }

  Future<void> loadFiles() async {
    try {
      state = const AsyncValue.loading();
      _allFiles = await getFiles(_folderPath);
      _applyFilters();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateSearch(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void updateSort(FileSortType sortType) {
    _sortType = sortType;
    _applyFilters();
  }

  Future<void> deleteFile(String path) async {
    await deleteFileUseCase(path);
    await loadFiles();
  }

  Future<void> moveSelected(String destinationFolderPath) async {
    for (final path in _selectedPaths) {
      await moveFileUseCase(path, destinationFolderPath);
    }
    clearSelection();
    await loadFiles();
  }

  void enterSelection(String path) {
    _isSelectionMode = true;
    _selectedPaths.add(path);
    _applyFilters();
  }

  void toggleSelection(String path) {
    if (_selectedPaths.contains(path)) {
      _selectedPaths.remove(path);
    } else {
      _selectedPaths.add(path);
    }

    if (_selectedPaths.isEmpty) {
      _isSelectionMode = false;
    }

    _applyFilters();
  }

  void clearSelection() {
    _selectedPaths.clear();
    _isSelectionMode = false;
    _applyFilters();
  }

  Future<void> deleteSelected() async {
    for (final path in _selectedPaths) {
      await deleteFileUseCase(path);
    }
    clearSelection();
    await loadFiles();
  }

  void _applyFilters() {
    List<FileEntity> filtered = _allFiles;

    // 🔍 SEARCH
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((file) =>
          file.name.toLowerCase().contains(_searchQuery))
          .toList();
    }

    // 📊 SORT
    switch (_sortType) {
      case FileSortType.newest:
        filtered.sort((a, b) =>
            b.createdAt.compareTo(a.createdAt));
        break;
      case FileSortType.oldest:
        filtered.sort((a, b) =>
            a.createdAt.compareTo(b.createdAt));
        break;
      case FileSortType.nameAsc:
        filtered.sort((a, b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case FileSortType.nameDesc:
        filtered.sort((a, b) =>
            b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
    }

    state = AsyncValue.data(filtered);
  }
}

final fileProvider = StateNotifierProvider.family<
    FileNotifier,
    AsyncValue<List<FileEntity>>,
    String?>(
      (ref, folderPath) => FileNotifier(
    getFiles: ref.read(getScannedFilesUseCaseProvider),
    deleteFileUseCase: ref.read(deleteFileUseCaseProvider),
    moveFileUseCase: ref.read(moveFileUseCaseProvider),
    folderPath: folderPath,
  ),
);