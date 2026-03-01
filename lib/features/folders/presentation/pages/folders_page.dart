import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/folder_provider.dart';
import '../../../../config/routes/route_names.dart';
import '../../domain/entities/folder_entity.dart';

class FoldersPage extends ConsumerWidget {
  const FoldersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderState = ref.watch(folderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateFolderDialog(context, ref),
        child: const Icon(Icons.create_new_folder),
      ),
      body: folderState.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Error: $error')),
        data: (folders) {
          if (folders.isEmpty) {
            return const Center(
              child: Text('No folders created yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(folder.name),
                  onTap: () {
                    context.push(
                      RouteNames.files,
                      extra: {
                        'path': folder.path,
                        'name': folder.name,
                      },
                    );
                  },
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'rename') {
                        _showRenameDialog(context, ref, folder);
                      } else if (value == 'delete') {
                        _handleDelete(context, ref, folder);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'rename',
                        child: Text('Rename'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateFolderDialog(
      BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Folder'),
        content: TextField(
          controller: controller,
          decoration:
          const InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await ref
                    .read(folderProvider.notifier)
                    .createNewFolder(name);
              }
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context,
      WidgetRef ref,
      FolderEntity folder,
      ) {
    final controller =
    TextEditingController(text: folder.name);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName =
              controller.text.trim();
              if (newName.isNotEmpty) {
                await ref
                    .read(folderProvider.notifier)
                    .renameFolder(
                    folder.path, newName);
              }
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _handleDelete(
      BuildContext context,
      WidgetRef ref,
      FolderEntity folder,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text(
            'Are you sure you want to delete "${folder.name}"?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref
          .read(folderProvider.notifier)
          .deleteFolder(folder.path);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Folder deleted successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
        ),
      );
    }
  }


}