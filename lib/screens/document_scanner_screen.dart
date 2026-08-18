import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../services/file_service.dart';
import '../theme/app_theme.dart';

class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen> {
  final _picker = ImagePicker();
  final List<String> _pages = [];
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Document')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Capture each page, then crop it. ScanFold combines all pages into one PDF on this device.',
            style: TextStyle(color: ScanFoldColors.secondary, height: 1.4),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.document_scanner_outlined,
                    color: ScanFoldColors.mint,
                    size: 48,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _pages.isEmpty
                        ? 'No pages captured yet'
                        : '${_pages.length} page${_pages.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: ScanFoldColors.secondary),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _working ? null : _capturePage,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Capture'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _working ? null : _pickPage,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Gallery'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_pages.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Pages (tap to recrop)',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ..._pages.asMap().entries.map(
              (entry) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(entry.value),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    'Page ${entry.key + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Recrop',
                        onPressed: _working ? null : () => _cropPage(entry.key),
                        icon: const Icon(
                          Icons.crop,
                          color: ScanFoldColors.mint,
                          size: 20,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove',
                        onPressed: () => setState(() {
                          _pages.removeAt(entry.key);
                        }),
                        icon: const Icon(
                          Icons.close,
                          color: ScanFoldColors.secondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _working || _pages.isEmpty ? null : _createPdf,
              icon: _working
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
              label: Text(_working ? 'Creating PDF...' : 'Create PDF'),
            ),
            if (_result != null)
              Card(
                margin: const EdgeInsets.only(top: 14),
                child: ListTile(
                  leading: const Icon(
                    Icons.check_circle_outline,
                    color: ScanFoldColors.mint,
                  ),
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

  String? _result;

  Future<void> _capturePage() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null || !mounted) return;
    await _cropNewPage(image.path);
  }

  Future<void> _pickPage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;
    await _cropNewPage(image.path);
  }

  Future<void> _cropNewPage(String path) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: path,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          toolbarTitle: 'Crop page',
          backgroundColor: ScanFoldColors.background,
          activeControlsWidgetColor: ScanFoldColors.mint,
        ),
        IOSUiSettings(title: 'Crop page'),
      ],
    );
    if (cropped == null || !mounted) return;
    setState(() => _pages.add(cropped.path));
  }

  Future<void> _cropPage(int index) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: _pages[index],
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          toolbarTitle: 'Crop page',
          backgroundColor: ScanFoldColors.background,
          activeControlsWidgetColor: ScanFoldColors.mint,
        ),
        IOSUiSettings(title: 'Crop page'),
      ],
    );
    if (cropped == null || !mounted) return;
    setState(() => _pages[index] = cropped.path);
  }

  Future<void> _createPdf() async {
    setState(() => _working = true);
    try {
      final path = await FileService.imagesToPdf(List.of(_pages));
      if (mounted) {
        setState(() => _result = path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document PDF created locally')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create the PDF.')),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }
}
