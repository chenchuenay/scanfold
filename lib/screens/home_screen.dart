import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/tool_card.dart';
import 'about_screen.dart';
import 'image_tool_screen.dart';
import 'my_files_screen.dart';
import 'pdf_tool_screen.dart';
import 'qr_screen.dart';
import 'zip_tool_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ScanFold',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            tooltip: 'About',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          children: [
            const Text(
              'ScanFold',
              style: TextStyle(
                color: ScanFoldColors.text,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Scan. Prepare. Share.',
              style: TextStyle(
                color: ScanFoldColors.secondary,
                fontSize: 16,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width >= 720
                    ? 4
                    : width >= 480
                    ? 3
                    : 2;
                final extent = width >= 720 ? 210.0 : 190.0;
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: extent,
                  ),
                  children: [
                    ToolCard(
                      icon: Icons.qr_code_scanner_rounded,
                      title: 'QR & Barcode',
                      subtitle: 'Scan safely without auto-opening links.',
                      color: ScanFoldColors.mint,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QrScreen()),
                      ),
                    ),
                    ToolCard(
                      icon: Icons.photo_size_select_large_outlined,
                      title: 'Photo Tools',
                      subtitle: 'Compress, resize, and prepare photos.',
                      color: ScanFoldColors.amber,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ImageToolScreen(),
                        ),
                      ),
                    ),
                    ToolCard(
                      icon: Icons.picture_as_pdf_outlined,
                      title: 'PDF Tools',
                      subtitle:
                          'Scan documents, create, compress, and merge PDFs.',
                      color: ScanFoldColors.mint,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PdfToolScreen(),
                        ),
                      ),
                    ),
                    ToolCard(
                      icon: Icons.archive_outlined,
                      title: 'Zip Tools',
                      subtitle:
                          'Pack photos, PDFs, and documents into one file.',
                      color: ScanFoldColors.amber,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ZipToolScreen(),
                        ),
                      ),
                    ),
                    ToolCard(
                      icon: Icons.history,
                      title: 'History',
                      subtitle: 'Your recent results stay on this device.',
                      color: ScanFoldColors.mint,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyFilesScreen(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: ScanFoldColors.mint),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Your files stay private by default. ScanFold does not need an account for core tools.',
                        style: TextStyle(
                          color: ScanFoldColors.secondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                ),
                icon: const Icon(Icons.info_outline, size: 16),
                label: const Text('About ScanFold'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
