import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/file_service.dart';
import '../theme/app_theme.dart';
import '../widgets/password_protect_field.dart';

enum _ZipMode { create, unlock }

class ZipToolScreen extends StatefulWidget {
  const ZipToolScreen({super.key});

  @override
  State<ZipToolScreen> createState() => _ZipToolScreenState();
}

class _ZipToolScreenState extends State<ZipToolScreen> {
  _ZipMode? _mode;
  List<String> _paths = const [];
  final _passwordController = TextEditingController();
  final _unlockController = TextEditingController();
  String? _unlockPath;
  String? _result;
  bool _working = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _unlockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_mode == null ? 'Zip Tools' : _modeTitle),
        leading: _mode != null
            ? IconButton(
                tooltip: 'Back to Zip tools',
                onPressed: _reset,
                icon: const Icon(Icons.arrow_back),
              )
            : null,
      ),
      body: _mode == null
          ? _hub()
          : (_mode == _ZipMode.create ? _createZipUi() : _unlockZipUi()),
    );
  }

  String get _modeTitle =>
      _mode == _ZipMode.create ? 'Create ZIP' : 'Unlock ZIP';

  Widget _hub() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'What do you want to do?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pack files together or remove a password from a ZIP. Everything stays on this device.',
          style: TextStyle(color: ScanFoldColors.secondary, height: 1.4),
        ),
        const SizedBox(height: 22),
        _option(
          icon: Icons.archive_outlined,
          title: 'Create ZIP',
          subtitle: 'Combine photos, PDFs, and documents into one file.',
          color: ScanFoldColors.mint,
          onTap: () => setState(() => _mode = _ZipMode.create),
        ),
        _option(
          icon: Icons.lock_open_outlined,
          title: 'Unlock ZIP',
          subtitle: 'Remove a password from a protected ZIP.',
          color: ScanFoldColors.amber,
          onTap: () => setState(() => _mode = _ZipMode.unlock),
        ),
      ],
    );
  }

  Widget _option({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(height: 1.3)),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _createZipUi() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Combine any files - photos, PDFs, documents - into one ZIP. Everything stays on this device.',
          style: TextStyle(color: ScanFoldColors.secondary, height: 1.4),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PasswordProtectField(controller: _passwordController),
          ),
        ),
        const SizedBox(height: 12),
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
        if (_result != null) _resultCard('ZIP ready', _result!),
      ],
    );
  }

  Widget _unlockZipUi() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Card(
          margin: EdgeInsets.only(bottom: 4),
          color: ScanFoldColors.amber,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Color(0xFF07090D), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'For educational and personal use only — do not misuse this tool to access files you do not own. '
                    'Some ZIPs use strong or unsupported encryption, so not every file can be unlocked.',
                    style: TextStyle(
                      color: Color(0xFF07090D),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _unlockController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter the ZIP password',
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.lock_open_outlined,
                  color: ScanFoldColors.amber,
                  size: 48,
                ),
                const SizedBox(height: 14),
                Text(
                  _unlockPath == null
                      ? 'No ZIP selected'
                      : 'Selected: ${_unlockPath!.split('/').last}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: ScanFoldColors.secondary),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: _working ? null : _pickZip,
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Choose ZIP'),
                ),
              ],
            ),
          ),
        ),
        if (_unlockPath != null) ...[
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _working || _unlockController.text.isEmpty
                ? null
                : _unlockZip,
            icon: _working
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_open_outlined),
            label: Text(_working ? 'Unlocking...' : 'Unlock ZIP'),
          ),
        ],
        if (_result != null) _resultCard('Unlocked ZIP ready', _result!),
      ],
    );
  }

  Widget _resultCard(String title, String path) {
    return Card(
      margin: const EdgeInsets.only(top: 14),
      child: ListTile(
        leading: const Icon(
          Icons.check_circle_outline,
          color: ScanFoldColors.mint,
        ),
        title: Text(title),
        subtitle: const Text('Created locally and ready to share.'),
        trailing: IconButton(
          tooltip: 'Share',
          onPressed: () => FileService.share(path),
          icon: const Icon(Icons.ios_share),
        ),
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

  Future<void> _pickZip() async {
    final result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    final path = result?.path;
    if (path != null && mounted) {
      setState(() {
        _unlockPath = path;
        _result = null;
      });
    }
  }

  Future<void> _createZip() async {
    setState(() => _working = true);
    try {
      final path = await FileService.createZip(
        _paths,
        password: _passwordController.text.trim().isEmpty
            ? null
            : _passwordController.text.trim(),
      );
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

  Future<void> _unlockZip() async {
    setState(() => _working = true);
    try {
      final path = await FileService.repackZip(
        inputPath: _unlockPath!,
        password: _unlockController.text.trim(),
      );
      if (mounted) {
        if (path == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not unlock this ZIP. Check the password or that it uses a supported format.',
              ),
            ),
          );
        } else {
          setState(() => _result = path);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('ZIP unlocked locally')));
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not unlock this ZIP. Check the password or that it uses a supported format.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _reset() {
    setState(() {
      _mode = null;
      _paths = const [];
      _unlockPath = null;
      _result = null;
      _passwordController.clear();
      _unlockController.clear();
    });
  }
}
