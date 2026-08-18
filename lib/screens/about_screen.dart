import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About ScanFold')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: ScanFoldColors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: ScanFoldColors.border),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: ScanFoldColors.mint,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'ScanFold',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Scan, prepare, and share files privately.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ScanFoldColors.secondary),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About this app',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'ScanFold is a private, offline-first toolkit for scanning QR codes, '
                    'compressing and resizing photos, scanning documents, creating, compressing '
                    'and merging PDFs, and packing files into ZIP archives. Your files stay on '
                    'your device unless you choose to share them.',
                    style: TextStyle(
                      color: ScanFoldColors.secondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No account is required for core tools. No files are uploaded automatically.',
                    style: TextStyle(
                      color: ScanFoldColors.secondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Version',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1.0.0',
                    style: TextStyle(color: ScanFoldColors.secondary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Legal',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Copyright © 2026 Enay Kumar. All rights reserved.\n\n'
                    'ScanFold and the ScanFold logo are trademarks of Enay Kumar. '
                    'This app and its code may not be copied, modified, or distributed '
                    'without written permission.',
                    style: TextStyle(
                      color: ScanFoldColors.secondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Built with care by Enay Kumar',
              style: TextStyle(color: ScanFoldColors.muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
