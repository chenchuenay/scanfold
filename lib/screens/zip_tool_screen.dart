import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/file_service.dart';
import '../theme/app_theme.dart';

class ZipToolScreen extends StatefulWidget {
  const ZipToolScreen({super.key});

  @override
  State<ZipToolScreen> createState() => _ZipToolScreenState();
}

class _ZipToolScreenState extends State<ZipToolScreen> {
  List<String> _paths = const [];
  String? _result;
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zip Files')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Combine any files - photos, PDFs, documents - into one ZIP. Everything stays on this device.',
            style: TextStyle(color: ScanFoldColors.secondary, height: 1.4),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.archive_outlined,
                    color: ScanFoldColors.amber,
                    size: 48,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'What you get: a single .zip file ready to share.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ScanFoldColors.secondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _working ? null : _pickFiles,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('Choose files'),
                  ),
                ],
              ),
            ),
          ),
          if (_paths.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Selected files',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ..._paths.asMap().entries.map(
              (entry) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.insert_drive_file_outlined,
                    color: ScanFoldColors.mint,
                    size: 20,
                  ),
                  title: Text(
                    entry.value.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: IconButton(
                    tooltip: 'Remove',
                    onPressed: () => setState(() {
                      _paths = List.of(_paths)..removeAt(entry.key);
                      _result = null;
                    }),
                    icon: const Icon(
                      Icons.close,
                      color: ScanFoldColors.secondary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _working || _paths.isEmpty ? null : _createZip,
              icon: _working
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.archive_outlined),
              label: Text(_working ? 'Packing...' : 'Create ZIP'),
            ),
          ],
          if (_result != null)
            Card(
              margin: const EdgeInsets.only(top: 14),
              child: ListTile(
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: ScanFoldColors.mint,
                ),
                title: const Text('ZIP ready'),
                subtitle: const Text('Created locally and ready to share.'),
                trailing: IconButton(
                  tooltip: 'Share',
                  onPressed: () => FileService.share(_result!),
                  icon: const Icon(Icons.ios_share),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles();
    if (mounted && result.isNotEmpty) {
      setState(() {
        _paths = result
            .map((file) => file.path ?? '')
            .where((path) => path.isNotEmpty)
            .toList();
        _result = null;
      });
    }
  }

  Future<void> _createZip() async {
    setState(() => _working = true);
    try {
      final path = await FileService.createZip(_paths);
      if (mounted) {
        setState(() => _result = path);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ZIP created locally')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create the ZIP.')),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }
}
