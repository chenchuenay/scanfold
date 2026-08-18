import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/tool_card.dart';
import 'about_screen.dart';
import 'image_tool_screen.dart';
import 'make_it_fit_screen.dart';
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
            tooltip: 'Privacy',
            onPressed: () => _showPrivacy(context),
            icon: const Icon(Icons.verified_user_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          children: [
            const Text(
              'Scan. Prepare. Share.',
              style: TextStyle(
                color: ScanFoldColors.text,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Private file tools that work on your device.',
              style: TextStyle(color: ScanFoldColors.secondary, fontSize: 15),
            ),
            const SizedBox(height: 20),
            Card(
              color: ScanFoldColors.mint.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: ScanFoldColors.mint),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MakeItFitScreen()),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: ScanFoldColors.mint,
                        size: 34,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Make it Fit',
                              style: TextStyle(
                                color: ScanFoldColors.text,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'One photo, right size & shape for WhatsApp, Instagram, email, passport and more.',
                              style: TextStyle(
                                color: ScanFoldColors.secondary,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: ScanFoldColors.mint),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
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
                    MaterialPageRoute(builder: (_) => const ImageToolScreen()),
                  ),
                ),
                ToolCard(
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'PDF Tools',
                  subtitle: 'Scan documents, create, compress, and merge PDFs.',
                  color: ScanFoldColors.mint,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PdfToolScreen()),
                  ),
                ),
                ToolCard(
                  icon: Icons.folder_open_outlined,
                  title: 'My Files',
                  subtitle: 'Your recent results stay on this device.',
                  color: ScanFoldColors.amber,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyFilesScreen()),
                  ),
                ),
                ToolCard(
                  icon: Icons.archive_outlined,
                  title: 'Zip Files',
                  subtitle: 'Pack photos, PDFs, and documents into one file.',
                  color: ScanFoldColors.mint,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ZipToolScreen()),
                  ),
                ),
              ],
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

  void _showPrivacy(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ScanFold',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Core file processing happens on this device.',
    );
  }
}
