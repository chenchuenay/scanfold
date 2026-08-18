import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/file_service.dart';
import '../services/make_it_fit_service.dart';
import '../theme/app_theme.dart';
import '../widgets/watermark_overlay.dart';

class MakeItFitScreen extends StatefulWidget {
  const MakeItFitScreen({super.key});

  @override
  State<MakeItFitScreen> createState() => _MakeItFitScreenState();
}

class _MakeItFitScreenState extends State<MakeItFitScreen> {
  final _picker = ImagePicker();
  XFile? _source;
  FitTarget _selected = fitTargets.first;
  MakeItFitResult? _result;
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make it Fit'),
        leading: _source != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _source = null;
                  _result = null;
                }),
              )
            : null,
      ),
      body: _source == null ? _pickCard() : _workflow(),
    );
  }

  Widget _pickCard() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Pick one photo and ScanFold makes it the right size and shape for where you want to share it.',
          style: TextStyle(color: ScanFoldColors.secondary, height: 1.4),
        ),
        const SizedBox(height: 18),
        const Text(
          'Choose where it will go',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ...fitTargets.map(
          (target) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              margin: EdgeInsets.zero,
              color: target == _selected
                  ? ScanFoldColors.mint.withValues(alpha: 0.08)
                  : ScanFoldColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: target == _selected
                      ? ScanFoldColors.mint
                      : ScanFoldColors.border,
                ),
              ),
              child: ListTile(
                onTap: () => setState(() => _selected = target),
                title: Text(
                  target.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  target.reference,
                  style: const TextStyle(color: ScanFoldColors.secondary),
                ),
                trailing: target == _selected
                    ? const Icon(Icons.check_circle, color: ScanFoldColors.mint)
                    : const Icon(
                        Icons.circle_outlined,
                        color: ScanFoldColors.muted,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Choose photo'),
        ),
      ],
    );
  }

  Widget _workflow() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Fitting for "${_selected.name}" (${_selected.reference})',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your photo stays on this device.',
          style: TextStyle(color: ScanFoldColors.secondary, fontSize: 12),
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(File(_source!.path), height: 220, fit: BoxFit.cover),
              const WatermarkOverlay(),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _working ? null : _fit,
          icon: _working
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(_working ? 'Fitting...' : 'Make it fit'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _source = null;
            _result = null;
          }),
          icon: const Icon(Icons.restart_alt),
          label: const Text('Choose another'),
        ),
        if (_result != null) _resultCard(),
      ],
    );
  }

  Widget _resultCard() {
    final result = _result!;
    return Card(
      margin: const EdgeInsets.only(top: 18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ready',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: ScanFoldColors.mint,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_formatBytes(result.beforeBytes)} → ${_formatBytes(result.afterBytes)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              result.savedBytes == 0
                  ? 'Already fits at quality ${result.quality}%  ·  ${result.width}×${result.height}'
                  : 'Saved ${_formatBytes(result.savedBytes)} (${result.savedPercent.round()}%) at quality ${result.quality}%  ·  ${result.width}×${result.height}',
              style: const TextStyle(
                color: ScanFoldColors.secondary,
                fontSize: 13,
              ),
            ),
            if (_selected.hasAspect) ...[
              const SizedBox(height: 8),
              const Text(
                'Shaped with a soft blurred background so nothing was cropped.',
                style: TextStyle(
                  color: ScanFoldColors.muted,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => FileService.share(result.path),
              icon: const Icon(Icons.ios_share),
              label: const Text('Share'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) setState(() => _source = image);
  }

  Future<void> _fit() async {
    setState(() => _working = true);
    try {
      final result = await MakeItFitService.makeItFit(
        sourcePath: _source!.path,
        target: _selected,
      );
      if (!mounted) return;
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not prepare this photo.')),
        );
      } else {
        setState(() => _result = result);
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

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
