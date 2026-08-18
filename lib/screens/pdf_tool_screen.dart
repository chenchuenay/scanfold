import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/file_service.dart';
import '../theme/app_theme.dart';

class PdfToolScreen extends StatefulWidget {
  const PdfToolScreen({super.key});

  @override
  State<PdfToolScreen> createState() => _PdfToolScreenState();
}

class _PdfToolScreenState extends State<PdfToolScreen> {
  final _picker = ImagePicker();
  List<XFile> _images = const [];
  String? _result;
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Maker')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, color: ScanFoldColors.mint, size: 48),
                  const SizedBox(height: 14),
                  Text(
                    _images.isEmpty
                        ? 'Turn photos into a clean PDF on your device.'
                        : '${_images.length} photo${_images.length == 1 ? '' : 's'} selected',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: ScanFoldColors.secondary, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _working ? null : _pick,
                    icon: const Icon(Icons.collections_outlined),
                    label: const Text('Choose photos'),
                  ),
                ],
              ),
            ),
          ),
          if (_images.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_images[index].path), width: 110, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _working ? null : _create,
              icon: _working
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome_motion_outlined),
              label: Text(_working ? 'Creating...' : 'Create PDF'),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 18),
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline, color: ScanFoldColors.mint),
                title: const Text('PDF ready'),
                subtitle: const Text('Created locally and ready to share.'),
                trailing: IconButton(
                  tooltip: 'Share',
                  onPressed: () => FileService.share(_result!),
                  icon: const Icon(Icons.ios_share),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pick() async {
    final images = await _picker.pickMultiImage(imageQuality: 100);
    if (mounted && images.isNotEmpty) setState(() => _images = images);
  }

  Future<void> _create() async {
    setState(() => _working = true);
    try {
      final path = await FileService.imagesToPdf(_images.map((image) => image.path).toList());
      if (mounted) {
        setState(() => _result = path);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF created locally')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not create the PDF.')));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }
}
