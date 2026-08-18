import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/file_service.dart';
import '../theme/app_theme.dart';

class ImageToolScreen extends StatefulWidget {
  const ImageToolScreen({super.key});

  @override
  State<ImageToolScreen> createState() => _ImageToolScreenState();
}

class _ImageToolScreenState extends State<ImageToolScreen> {
  final _picker = ImagePicker();
  final _widthController = TextEditingController();
  XFile? _source;
  String? _result;
  double _quality = 82;
  bool _working = false;

  @override
  void dispose() {
    _widthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Tools')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (_source == null)
            _pickCard()
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                File(_source!.path),
                height: 260,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quality',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _quality,
                            min: 30,
                            max: 100,
                            divisions: 14,
                            label: '${_quality.round()}%',
                            onChanged: (value) =>
                                setState(() => _quality = value),
                          ),
                        ),
                        Text('${_quality.round()}%'),
                      ],
                    ),
                    const Text(
                      'Higher quality keeps more detail but creates a larger file.',
                      style: TextStyle(
                        color: ScanFoldColors.secondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _widthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Width in pixels (optional)',
                        hintText: 'Example: 1200',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _working ? null : _compress,
              icon: _working
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.compress),
              label: Text(_working ? 'Preparing...' : 'Compress photo'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _source = null;
                _result = null;
              }),
              icon: const Icon(Icons.restart_alt),
              label: const Text('Choose another photo'),
            ),
            if (_result != null) ...[
              const SizedBox(height: 22),
              const Text(
                'Ready to share',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: () => FileService.share(_result!),
                icon: const Icon(Icons.ios_share),
                label: const Text('Share result'),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _pickCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Icon(
              Icons.photo_library_outlined,
              color: ScanFoldColors.amber,
              size: 48,
            ),
            const SizedBox(height: 14),
            const Text(
              'Choose a photo to make it smaller and easier to share.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ScanFoldColors.secondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _pickCamera,
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: const Text('Scan'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pick,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick() async {
    final source = await _picker.pickImage(source: ImageSource.gallery);
    if (source != null && mounted) setState(() => _source = source);
  }

  Future<void> _pickCamera() async {
    final source = await _picker.pickImage(source: ImageSource.camera);
    if (source != null && mounted) setState(() => _source = source);
  }

  Future<void> _compress() async {
    setState(() => _working = true);
    try {
      final result = await FileService.compressImage(
        sourcePath: _source!.path,
        quality: _quality.round(),
        width: int.tryParse(_widthController.text.trim()),
      );
      if (mounted) {
        setState(() => _result = result);
        if (result == null) {
          throw Exception('Could not create the compressed photo.');
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Photo prepared locally')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not prepare this photo.')),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }
}
