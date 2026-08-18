import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../theme/app_theme.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final _controller = MobileScannerController();
  final _generatorController = TextEditingController();
  bool _generatorVisible = false;
  String? _lastValue;
  String? _lastFormat;

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
        title: const Text('QR & Barcode'),
        actions: [
          IconButton(
            tooltip: 'Flash',
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on_outlined),
          ),
          IconButton(
            tooltip: 'Camera',
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
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
          const SizedBox(height: 14),
          if (_lastValue != null) _resultCard(context),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () =>
                setState(() => _generatorVisible = !_generatorVisible),
            icon: const Icon(Icons.qr_code_2),
            label: Text(
              _generatorVisible ? 'Hide QR generator' : 'Create a QR code',
            ),
          ),
          if (_generatorVisible) ...[
            const SizedBox(height: 14),
            TextField(
              controller: _generatorController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Text, link, Wi-Fi name, or contact',
                hintText: 'Enter something to turn into a QR code',
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (_generatorController.text.trim().isNotEmpty) ...[
              const SizedBox(height: 18),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  color: Colors.white,
                  child: QrImageView(
                    data: _generatorController.text.trim(),
                    size: 190,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _resultCard(BuildContext context) {
    final value = _lastValue!;
    final isLink = Uri.tryParse(value)?.hasScheme == true;
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
            Text(
              value,
              style: const TextStyle(color: ScanFoldColors.text, height: 1.35),
            ),
            if (isLink) ...[
              const SizedBox(height: 8),
              const Text(
                'Review this address before opening it.',
                style: TextStyle(color: ScanFoldColors.amber, fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: value));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy'),
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
}
