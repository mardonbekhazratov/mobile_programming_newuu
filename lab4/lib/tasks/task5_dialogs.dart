import 'package:flutter/material.dart';

/// Task 5: Dialogs & Modals (AlertDialog & showModalBottomSheet)
///
/// Exercise 5.1: an AlertDialog asks for confirmation before deleting an
/// item, with "Cancel" and "Delete" actions.
/// Exercise 5.2: a bottom action sheet opened with showModalBottomSheet
/// lists share options as ListTiles.
class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  final List<String> _files = [
    'Vacation photos',
    'Project report.pdf',
    'Meeting notes',
    'Lecture slides',
    'Grocery list',
  ];

  static const _shareOptions = [
    (icon: Icons.link, label: 'Copy link'),
    (icon: Icons.email_outlined, label: 'Email'),
    (icon: Icons.sms_outlined, label: 'Message'),
    (icon: Icons.more_horiz, label: 'More options'),
  ];

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _confirmDelete(String file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('Delete item?'),
        content: Text('"$file" will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // Tapping outside the dialog returns null, which counts as "Cancel".
    if (confirmed != true || !mounted) return;
    setState(() => _files.remove(file));
    _showMessage('Deleted "$file"');
  }

  Future<void> _showShareSheet(String file) async {
    final option = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share "$file"',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            for (final option in _shareOptions)
              ListTile(
                leading: Icon(option.icon),
                title: Text(option.label),
                onTap: () => Navigator.of(context).pop(option.label),
              ),
          ],
        ),
      ),
    );

    // Dragging the sheet down or tapping the scrim returns null.
    if (option == null || !mounted) return;
    _showMessage('Shared "$file" via $option');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Files')),
      body: _files.isEmpty
          ? const Center(child: Text('No files left'))
          : ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];
                return ListTile(
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  title: Text(file),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Share',
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () => _showShareSheet(file),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(file),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
