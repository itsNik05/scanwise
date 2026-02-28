import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/file_provider.dart';
import '../widgets/file_tile.dart';

import '../../../../config/routes/route_names.dart';
import 'package:go_router/go_router.dart';
import '../providers/file_sort_type.dart';
import 'package:share_plus/share_plus.dart';

class FilesPage extends ConsumerWidget {
  const FilesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileState = ref.watch(fileProvider);
    final notifier = ref.read(fileProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: notifier.isSelectionMode
            ? Text('${notifier.selectedPaths.length} selected')
            : const Text('Scanned Files'),
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
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Delete Selected Files"),
                  content: const Text(
                      "Are you sure you want to delete selected files?"),
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
                        style:
                        TextStyle(color: Colors.red),
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
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
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
                    ref.read(fileProvider.notifier).updateSearch(value);
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      ref.read(fileProvider.notifier).updateSort(value);
                    }
                  },
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(fileProvider.notifier).loadFiles(),
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

                            // ✅ TAP LOGIC
                            onTap: () {
                              if (notifier.isSelectionMode) {
                                notifier.toggleSelection(file.path);
                              } else {
                                context.push(
                                  RouteNames.pdfPreview,
                                  extra: file.path,
                                );
                              }
                            },

                            // ✅ DELETE LOGIC (ONLY IF NOT IN SELECTION MODE)
                            onDelete: notifier.isSelectionMode
                                ? () {
                              notifier.toggleSelection(file.path);
                            }
                                : () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Delete File"),
                                  content: Text(
                                      "Are you sure you want to delete ${file.name}?"),
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
                                        style:
                                        TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await notifier.deleteFile(file.path);
                              }
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
}