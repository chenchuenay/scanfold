import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/file_service.dart';
import '../theme/app_theme.dart';
import '../widgets/watermark_overlay.dart';

enum _PhotoMode { compress, resize, passport, batch }

class ImageToolScreen extends StatefulWidget {
  const ImageToolScreen({super.key});

  @override
  State<ImageToolScreen> createState() => _ImageToolScreenState();
}

class _ImageToolScreenState extends State<ImageToolScreen> {
  final _picker = ImagePicker();
  final _widthController = TextEditingController();
  _PhotoMode? _mode;
  XFile? _source;
  List<XFile> _batchSources = const [];
  List<CompressionResult>? _batchResults;
  CompressionResult? _result;
  int _targetBytes = 500 * 1024;
  bool _working = false;

  @override
  void dispose() {
    _widthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_mode == null ? 'Photo Tools' : _modeTitle),
        leading: _mode != null
            ? IconButton(
                tooltip: 'Back to photo tools',
                onPressed: _reset,
                icon: const Icon(Icons.arrow_back),
              )
            : null,
      ),
      body: _mode == null ? _featureHub() : _workflow(),
    );
  }

  String get _modeTitle => switch (_mode!) {
    _PhotoMode.compress => 'Compress Photo',
    _PhotoMode.resize => 'Resize Photo',
    _PhotoMode.passport => 'ID Photo',
    _PhotoMode.batch => 'Batch Compress',
  };

  Widget _featureHub() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'What do you want to do?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose a purpose first. ScanFold will then ask only for the file or camera access that action needs.',
          style: TextStyle(color: ScanFoldColors.secondary, height: 1.4),
        ),
        const SizedBox(height: 22),
        _featureTile(
          icon: Icons.compress,
          title: 'Compress to a size',
          subtitle: 'Make a photo fit 100 KB, 500 KB, 1 MB, or another limit.',
          color: ScanFoldColors.amber,
          mode: _PhotoMode.compress,
        ),
        _featureTile(
          icon: Icons.photo_size_select_large_outlined,
          title: 'Resize dimensions',
          subtitle: 'Set the exact pixel width for a form, profile, or upload.',
          color: ScanFoldColors.mint,
          mode: _PhotoMode.resize,
        ),
        _featureTile(
          icon: Icons.badge_outlined,
          title: 'ID and passport photo',
          subtitle:
              'Prepare a smaller portrait with a practical 600 px preset.',
          color: ScanFoldColors.amber,
          mode: _PhotoMode.passport,
        ),
        _featureTile(
          icon: Icons.photo_library_outlined,
          title: 'Batch compress',
          subtitle: 'Shrink several photos to the same size limit in one go.',
          color: ScanFoldColors.mint,
          mode: _PhotoMode.batch,
        ),
      ],
    );
  }

  Widget _featureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required _PhotoMode mode,
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
        onTap: () => setState(() => _mode = mode),
      ),
    );
  }

  Widget _workflow() {
    if (_mode == _PhotoMode.batch) return _batchWorkflow();
    final hasSource = _source != null;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          _modeDescription,
          style: const TextStyle(color: ScanFoldColors.secondary, height: 1.4),
        ),
        const SizedBox(height: 18),
        if (_mode == _PhotoMode.compress || _mode == _PhotoMode.passport)
          _sizeControls()
        else if (_mode == _PhotoMode.resize)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _widthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Width in pixels',
                  hintText: 'Example: 1200',
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        if (!hasSource)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Icon(_modeIcon, color: _modeColor, size: 48),
                  const SizedBox(height: 14),
                  Text(
                    _pickExplanation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: ScanFoldColors.secondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _pickCamera,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Camera'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickGallery,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Gallery'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        else ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(_source!.path), height: 240, fit: BoxFit.cover),
                const WatermarkOverlay(),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _working ? null : _prepare,
            icon: _working
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(_working ? 'Preparing locally...' : 'Prepare file'),
          ),
          if (_result != null) _resultCard(),
        ],
      ],
    );
  }

  Widget _batchWorkflow() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Select several photos, then choose one size limit. Each output keeps the safe quality floor.',
          style: TextStyle(color: ScanFoldColors.secondary, height: 1.4),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  color: ScanFoldColors.mint,
                  size: 48,
                ),
                const SizedBox(height: 14),
                Text(
                  _batchSources.isEmpty
                      ? 'No photos selected'
                      : '${_batchSources.length} photo${_batchSources.length == 1 ? '' : 's'} selected',
                  style: const TextStyle(color: ScanFoldColors.secondary),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: _working ? null : _pickBatch,
                  icon: const Icon(Icons.collections_outlined),
                  label: const Text('Choose photos'),
                ),
              ],
            ),
          ),
        ),
        if (_batchSources.isNotEmpty) ...[
          const SizedBox(height: 14),
          _sizeControls(),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _working ? null : _prepareBatch,
            icon: _working
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.compress),
            label: Text(
              _working ? 'Preparing locally...' : 'Compress all photos',
            ),
          ),
        ],
        if (_batchResults != null && _batchResults!.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Text(
            'Batch complete',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_batchResults!.length} file${_batchResults!.length == 1 ? '' : 's'} prepared',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Each output is saved to My Files and ready to share.',
                    style: TextStyle(
                      color: ScanFoldColors.secondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final result in _batchResults!)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.check_circle_outline,
                        color: ScanFoldColors.mint,
                        size: 20,
                      ),
                      title: Text(
                        _formatBytes(result.bytes),
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: IconButton(
                        tooltip: 'Share',
                        onPressed: () => FileService.share(result.path),
                        icon: const Icon(Icons.ios_share, size: 20),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickBatch() async {
    final images = await _picker.pickMultiImage();
    if (mounted && images.isNotEmpty) {
      setState(() {
        _batchSources = images;
        _batchResults = null;
      });
    }
  }

  Future<void> _prepareBatch() async {
    setState(() => _working = true);
    try {
      final results = await FileService.compressImagesBatch(
        sourcePaths: _batchSources.map((image) => image.path).toList(),
        targetBytes: _targetBytes,
      );
      if (mounted) {
        setState(() => _batchResults = results);
        if (results.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not prepare these photos.')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not prepare these photos.')),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Widget _sizeControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Maximum file size',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'ScanFold lowers quality only as far as needed and never goes below its safe quality floor.',
              style: TextStyle(
                color: ScanFoldColors.secondary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in const [100, 500, 1024, 2048])
                  ChoiceChip(
                    label: Text(
                      option >= 1024 ? '${option ~/ 1024} MB' : '$option KB',
                    ),
                    selected: _targetBytes == option * 1024,
                    onSelected: (_) =>
                        setState(() => _targetBytes = option * 1024),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultCard() {
    final result = _result!;
    return Card(
      margin: const EdgeInsets.only(top: 18),
      child: ListTile(
        leading: const Icon(
          Icons.check_circle_outline,
          color: ScanFoldColors.mint,
        ),
        title: Text('${_formatBytes(result.bytes)} output'),
        subtitle: Text(
          result.reachedTarget
              ? 'Target reached at quality ${result.quality}%.'
              : 'Safe quality floor reached; target size could not be reached without more loss.',
        ),
        trailing: IconButton(
          tooltip: 'Share',
          onPressed: () => FileService.share(result.path),
          icon: const Icon(Icons.ios_share),
        ),
      ),
    );
  }

  String get _modeDescription => switch (_mode!) {
    _PhotoMode.compress =>
      'Choose a photo, then select the largest file size it should produce.',
    _PhotoMode.resize =>
      'Choose a photo, then enter the pixel width required by the destination.',
    _PhotoMode.passport =>
      'Choose a portrait and prepare a practical 600 px copy for forms.',
    _PhotoMode.batch =>
      'Choose several photos, then select one size limit for all of them.',
  };

  String get _pickExplanation => switch (_mode!) {
    _PhotoMode.compress =>
      'Select a photo you need to send or upload under a size limit.',
    _PhotoMode.resize => 'Select a photo that needs exact dimensions.',
    _PhotoMode.passport =>
      'Choose a clear portrait. ScanFold will create a compact copy.',
    _PhotoMode.batch => 'Select the photos you want to shrink together.',
  };

  IconData get _modeIcon => switch (_mode!) {
    _PhotoMode.compress => Icons.compress,
    _PhotoMode.resize => Icons.photo_size_select_large_outlined,
    _PhotoMode.passport => Icons.badge_outlined,
    _PhotoMode.batch => Icons.photo_library_outlined,
  };

  Color get _modeColor => switch (_mode!) {
    _PhotoMode.compress => ScanFoldColors.amber,
    _PhotoMode.resize => ScanFoldColors.mint,
    _PhotoMode.passport => ScanFoldColors.amber,
    _PhotoMode.batch => ScanFoldColors.mint,
  };

  Future<void> _pickGallery() async {
    final source = await _picker.pickImage(source: ImageSource.gallery);
    if (source != null && mounted) setState(() => _source = source);
  }

  Future<void> _pickCamera() async {
    final source = await _picker.pickImage(source: ImageSource.camera);
    if (source != null && mounted) setState(() => _source = source);
  }

  Future<void> _prepare() async {
    setState(() => _working = true);
    try {
      final result = switch (_mode!) {
        _PhotoMode.compress => await FileService.compressImageToTarget(
          sourcePath: _source!.path,
          targetBytes: _targetBytes,
        ),
        _PhotoMode.passport => await FileService.compressImageToTarget(
          sourcePath: _source!.path,
          targetBytes: 300 * 1024,
          width: 600,
        ),
        _PhotoMode.resize => await FileService.compressImageToTarget(
          sourcePath: _source!.path,
          targetBytes: 10 * 1024 * 1024,
          width: int.tryParse(_widthController.text.trim()),
        ),
        _PhotoMode.batch => null,
      };
      if (!mounted) return;
      setState(() => _result = result);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File prepared locally')));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not prepare this file.')),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _reset() {
    setState(() {
      _mode = null;
      _source = null;
      _result = null;
      _batchSources = const [];
      _batchResults = null;
      _widthController.clear();
    });
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
