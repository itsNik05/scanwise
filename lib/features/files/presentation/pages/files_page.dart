import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/file_provider.dart';
import '../providers/file_sort_type.dart';
import '../widgets/file_tile.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../config/di/folders_di.dart';
import '../../domain/entities/file_entity.dart';

class FilesPage extends ConsumerWidget {
  final String? folderPath;
  final String? folderName;

  const FilesPage({
    super.key,
    this.folderPath,
    this.folderName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileState = ref.watch(fileProvider(folderPath));
    final notifier = ref.read(fileProvider(folderPath).notifier);

    return Scaffold(
      appBar: AppBar(
        title: notifier.isSelectionMode
            ? Text('${notifier.selectedPaths.length} selected')
            : folderPath == null
            ? const Text('Scanned Files')
            : Row(
          children: [
            GestureDetector(
              onTap: () {
                context.go(RouteNames.files);
              },
              child: const Text(
                'Root',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Text(' > '),
            Expanded(
              child: Text(
                folderName ?? '',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        leading: notifier.isSelectionMode
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: notifier.clearSelection,
        )
            : null,
        actions: notifier.isSelectionMode
            ? [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final paths = notifier.selectedPaths.toList();
              await Share.shareXFiles(
                paths.map((p) => XFile(p)).toList(),
              );
              notifier.clearSelection();
            },
          ),
          IconButton(
            icon: const Icon(Icons.drive_file_move),
            onPressed: () {
              _showMoveDialog(context, ref, notifier);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Delete Selected Files"),
                  content: const Text(
                    "Are you sure you want to delete selected files?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, true),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await notifier.deleteSelected();
              }
            },
          ),
        ]
            : [],
      ),
      body: fileState.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Error: $error')),
        data: (files) {
          if (files.isEmpty) {
            return const Center(
              child: Text(
                'No scanned files yet.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search files...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    notifier.updateSearch(value);
                  },
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<FileSortType>(
                  value: FileSortType.newest,
                  decoration: const InputDecoration(
                    labelText: 'Sort By',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: FileSortType.newest,
                      child: Text('Newest First'),
                    ),
                    DropdownMenuItem(
                      value: FileSortType.oldest,
                      child: Text('Oldest First'),
                    ),
                    DropdownMenuItem(
                      value: FileSortType.nameAsc,
                      child: Text('Name A-Z'),
                    ),
                    DropdownMenuItem(
                      value: FileSortType.nameDesc,
                      child: Text('Name Z-A'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      notifier.updateSort(value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => notifier.loadFiles(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      final isSelected =
                      notifier.selectedPaths.contains(file.path);

                      return GestureDetector(
                        onLongPress: () {
                          notifier.enterSelection(file.path);
                        },
                        child: Container(
                          color: isSelected
                              ? Colors.blue.withOpacity(0.2)
                              : null,
                          child: FileTile(
                            file: file,
                            onTap: () {
                              if (notifier.isSelectionMode) {
                                notifier.toggleSelection(file.path);
                              } else {
                                context.push(
                                  RouteNames.pdfPreview,
                                  extra: {
                                    'path': file.path,
                                    'name': file.name,
                                  },
                                );
                              }
                            },
                            onDelete: () async {
                              final confirm =
                              await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title:
                                  const Text("Delete File"),
                                  content: Text(
                                      "Delete ${file.name}?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(
                                              context, false),
                                      child:
                                      const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(
                                              context, true),
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(
                                            color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await notifier
                                    .deleteFile(file.path);
                              }
                            },
                            onRename: () {
                              _showRenameDialog(
                                  context, notifier, file);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMoveDialog(
      BuildContext context,
      WidgetRef ref,
      FileNotifier notifier,
      ) async {
    final folders =
    await ref.read(getFoldersUseCaseProvider).call();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Move To Folder"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: folders.length,
            itemBuilder: (_, index) {
              final folder = folders[index];
              return ListTile(
                leading: const Icon(Icons.folder),
                title: Text(folder.name),
                onTap: () async {
                  Navigator.pop(context);
                  await notifier.moveSelected(folder.path);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context,
      FileNotifier notifier,
      FileEntity file,
      ) {
    final controller = TextEditingController(
      text: file.name.replaceAll('.pdf', ''),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename File'),
        content: TextField(
          controller: controller,
          decoration:
          const InputDecoration(labelText: 'File name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await notifier.renameFile(
                    file.path, newName);
              }
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}