import 'package:flutter/material.dart';

import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_card.dart';
import 'image_tool_screen.dart';
import 'pdf_tool_screen.dart';
import 'qr_screen.dart';

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
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
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
                  subtitle: 'Compress and resize to the right size.',
                  color: ScanFoldColors.amber,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ImageToolScreen()),
                  ),
                ),
                ToolCard(
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'PDF Maker',
                  subtitle: 'Turn photos into clean shareable PDFs.',
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
                  onTap: () => _showHistory(context),
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
            const Center(
              child: Text(
                'Built by Enay Works',
                style: TextStyle(color: ScanFoldColors.muted, fontSize: 12),
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

  void _showHistory(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: ScanFoldColors.surface,
      builder: (_) => const _HistorySheet(),
    );
  }
}

class _HistorySheet extends StatelessWidget {
  const _HistorySheet();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: HistoryLoader.load(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <HistoryItem>[];
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (items.isEmpty) {
          return const SizedBox(
            height: 220,
            child: Center(
              child: Text(
                'No files created yet',
                style: TextStyle(color: ScanFoldColors.secondary),
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: Icon(
                item.type == 'pdf'
                    ? Icons.picture_as_pdf_outlined
                    : Icons.image_outlined,
                color: ScanFoldColors.mint,
              ),
              title: Text(item.title),
              subtitle: Text(
                item.path,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        );
      },
    );
  }
}

class HistoryLoader {
  static Future<List<HistoryItem>> load() => HistoryService.load();
}
