import 'dart:io';

import 'package:flutter/material.dart';

import '../services/file_service.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_help_icon.dart';

class MyFilesScreen extends StatefulWidget {
  const MyFilesScreen({super.key});

  @override
  State<MyFilesScreen> createState() => _MyFilesScreenState();
}

class _MyFilesScreenState extends State<MyFilesScreen> {
  List<HistoryItem>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await HistoryService.load();
    if (mounted) setState(() => _items = items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          ToolHelpIcon(guide: ToolGuides.history),
          if (_items?.isNotEmpty ?? false)
            IconButton(
              tooltip: 'Clear history',
              onPressed: _confirmClear,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: _items == null
          ? const Center(child: CircularProgressIndicator())
          : _items!.isEmpty
          ? _emptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: _items!.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _fileTile(_items![index]),
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.folder_open_outlined,
            color: ScanFoldColors.muted,
            size: 52,
          ),
          const SizedBox(height: 14),
          const Text(
            'No files created yet',
            style: TextStyle(
              color: ScanFoldColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Files you compress or create will appear here.',
            style: TextStyle(color: ScanFoldColors.secondary),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to tools'),
          ),
        ],
      ),
    );
  }

  Widget _fileTile(HistoryItem item) {
    final file = File(item.path);
    final exists = file.existsSync();
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: ScanFoldColors.mint.withValues(alpha: 0.14),
          child: Icon(
            item.type == 'pdf'
                ? Icons.picture_as_pdf_outlined
                : Icons.image_outlined,
            color: ScanFoldColors.mint,
            size: 22,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          exists ? _formatSize(file.lengthSync()) : 'File no longer available',
          style: const TextStyle(color: ScanFoldColors.muted, fontSize: 12),
        ),
        trailing: exists
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  switch (value) {
                    case 'share':
                      await FileService.share(item.path);
                    case 'delete':
                      await _delete(item);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'share', child: Text('Share')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              )
            : IconButton(
                tooltip: 'Remove from history',
                onPressed: () => _delete(item),
                icon: const Icon(
                  Icons.delete_outline,
                  color: ScanFoldColors.error,
                ),
              ),
      ),
    );
  }

  Future<void> _delete(HistoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete file?'),
        content: Text('Delete "${item.title}" from this device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await HistoryService.remove(item.path);
      final file = File(item.path);
      if (file.existsSync()) await file.delete();
      await _load();
    }
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text('Remove all ScanFold files from this device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await HistoryService.clear();
      await _load();
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
