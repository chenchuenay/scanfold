import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

enum _QrMode { scan, create }

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final _controller = MobileScannerController();
  final _generatorController = TextEditingController();
  final _picker = ImagePicker();
  _QrMode? _mode;
  String? _lastValue;
  String? _lastFormat;
  bool _galleryScanning = false;

  @override
  void dispose() {
    _controller.dispose();
    _generatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_mode == null ? 'QR & Barcode' : _modeTitle),
        leading: _mode != null
            ? IconButton(
                tooltip: 'Back to QR tools',
                onPressed: () => setState(() {
                  _mode = null;
                  _lastValue = null;
                }),
                icon: const Icon(Icons.arrow_back),
              )
            : null,
      ),
      body: _mode == null
          ? _hub()
          : switch (_mode!) {
              _QrMode.scan => _scanner(),
              _QrMode.create => _creator(),
            },
    );
  }

  String get _modeTitle => switch (_mode!) {
    _QrMode.scan => 'Scan QR or Barcode',
    _QrMode.create => 'Create QR Code',
  };

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
          'ScanFold keeps scanning simple and shows you the result before anything opens.',
          style: TextStyle(color: ScanFoldColors.secondary, height: 1.4),
        ),
        const SizedBox(height: 22),
        _option(
          icon: Icons.qr_code_scanner_rounded,
          title: 'Scan a code',
          subtitle: 'Read QR codes and common barcodes with the camera.',
          onTap: () => setState(() => _mode = _QrMode.scan),
          color: ScanFoldColors.mint,
        ),
        _option(
          icon: Icons.qr_code_2,
          title: 'Create a QR code',
          subtitle:
              'Turn text, a link, Wi-Fi details, or contact information into a QR.',
          onTap: () => setState(() => _mode = _QrMode.create),
          color: ScanFoldColors.amber,
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

  Widget _scanner() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Point your camera at a QR code or barcode. ScanFold will pause on the result so you stay in control.',
          style: TextStyle(color: ScanFoldColors.secondary, height: 1.4),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: (capture) {
                    if (capture.barcodes.isEmpty) return;
                    final barcode = capture.barcodes.first;
                    final value = barcode.rawValue;
                    if (value == null || value == _lastValue || !mounted) {
                      return;
                    }
                    setState(() {
                      _lastValue = value;
                      _lastFormat = barcode.format.name;
                    });
                  },
                ),
                IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 220,
                      height: 160,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ScanFoldColors.mint,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _controller.toggleTorch(),
                icon: const Icon(Icons.flash_on_outlined),
                label: const Text('Flash'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _controller.switchCamera(),
                icon: const Icon(Icons.cameraswitch_outlined),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _galleryScanning ? null : _scanFromGallery,
          icon: _galleryScanning
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.photo_library_outlined),
          label: Text(
            _galleryScanning ? 'Scanning...' : 'Scan a code from gallery',
          ),
        ),
        if (_lastValue != null) ...[const SizedBox(height: 16), _resultCard()],
      ],
    );
  }

  Widget _creator() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Create a QR code from information you want to share. Nothing is uploaded.',
          style: TextStyle(color: ScanFoldColors.secondary, height: 1.4),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _generatorController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Content for the QR code',
            hintText:
                'Paste a link, text, Wi-Fi details, or contact information',
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (_generatorController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 22),
          Center(
            child: Container(
              padding: const EdgeInsets.all(18),
              color: Colors.white,
              child: QrImageView(
                data: _generatorController.text.trim(),
                size: 210,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Test the code before sharing it.',
              style: TextStyle(color: ScanFoldColors.secondary, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _scanFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;
    setState(() {
      _galleryScanning = true;
      _lastValue = null;
      _lastFormat = null;
    });
    try {
      final capture = await _controller.analyzeImage(image.path);
      if (!mounted) return;
      final barcode = capture?.barcodes.firstOrNull;
      final value = barcode?.rawValue;
      setState(() {
        _lastValue = value;
        _lastFormat = barcode?.format.name;
      });
      if (value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No QR or barcode found in this image.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not scan this image.')),
        );
      }
    } finally {
      if (mounted) setState(() => _galleryScanning = false);
    }
  }

  Widget _resultCard() {
    final value = _lastValue!;
    final uri = Uri.tryParse(value);
    final isWebLink =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _lastFormat ?? 'Code',
              style: const TextStyle(color: ScanFoldColors.mint, fontSize: 12),
            ),
            const SizedBox(height: 8),
            SelectableText(
              value,
              style: const TextStyle(color: ScanFoldColors.text, height: 1.35),
            ),
            if (isWebLink) ...[
              const SizedBox(height: 8),
              const Text(
                'You will leave ScanFold and open this address in your browser.',
                style: TextStyle(
                  color: ScanFoldColors.amber,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: value));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy'),
                ),
                if (isWebLink)
                  FilledButton.icon(
                    onPressed: () => _openLink(uri),
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Open link'),
                  ),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _lastValue = null;
                    _lastFormat = null;
                  }),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Scan again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLink(Uri uri) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave ScanFold?'),
        content: Text('Open this address in your default browser?\n\n$uri'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open browser'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
