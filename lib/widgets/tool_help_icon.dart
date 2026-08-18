import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A per-tool help guide: what the tool does, how to use it, and privacy notes.
class ToolGuide {
  final String title;
  final String summary;
  final List<String> steps;
  final List<String> notes;

  const ToolGuide({
    required this.title,
    required this.summary,
    required this.steps,
    this.notes = const [],
  });
}

/// Shows a "How to use" bottom sheet for a specific tool.
///
/// Returns a widget you place in an AppBar actions list.
class ToolHelpIcon extends StatelessWidget {
  final ToolGuide guide;

  const ToolHelpIcon({super.key, required this.guide});

  void _show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: ScanFoldColors.surface,
      isScrollControlled: true,
      builder: (_) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: ScanFoldColors.amber,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    guide.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              guide.summary,
              style: const TextStyle(
                color: ScanFoldColors.secondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'How to use',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ScanFoldColors.mint,
              ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < guide.steps.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: ScanFoldColors.mint.withValues(
                      alpha: 0.16,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ScanFoldColors.mint,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        guide.steps[i],
                        style: const TextStyle(
                          color: ScanFoldColors.text,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (guide.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Good to know',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              for (final note in guide.notes) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: ScanFoldColors.muted,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          note,
                          style: const TextStyle(
                            color: ScanFoldColors.secondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'How to use',
      onPressed: () => _show(context),
      icon: const Icon(Icons.help_outline, color: ScanFoldColors.secondary),
    );
  }
}

/// Shared guide definitions, one per tool.
class ToolGuides {
  static const qr = ToolGuide(
    title: 'QR & Barcode',
    summary:
        'Read QR codes and barcodes with the camera, or create your own QR codes.',
    steps: [
      'Tap "Scan a code" to use the camera — point at a QR or barcode.',
      'Review what was scanned before opening any link.',
      'Tap "Open link" only when you trust the destination.',
      'Use "Scan a code from gallery" to read a code from an existing image.',
      'Tap "Create a QR code" to turn text, a link, or contact details into a QR.',
      'Users can copy the result or share it as a file.',
    ],
    notes: [
      'QR links are never opened automatically — you always confirm first.',
      'Core scanning works offline; nothing is uploaded.',
    ],
  );

  static const makeItFit = ToolGuide(
    title: 'Make it Fit',
    summary:
        'Prepare one photo for a specific platform: right size and shape in a single step.',
    steps: [
      'Choose where the photo will be used (WhatsApp, Instagram, email, passport, etc.).',
      'Choose the photo when you are ready.',
      'ScanFold shapes it with a soft blurred background so nothing is cropped.',
      'Review the new size and the space you saved.',
      'Share it from the result screen when happy.',
    ],
    notes: [
      'Extra space is filled with a blurred background, so the subject stays fully visible.',
      'Files are processed on your device.',
    ],
  );

  static const photo = ToolGuide(
    title: 'Photo Tools',
    summary:
        'Compress, resize, and prepare photos for forms, profiles, and uploads.',
    steps: [
      'Pick a purpose: Make it Fit, Compress, Resize, ID photo, or Batch.',
      'Choose your size preference before picking the photo.',
      'Capture with the camera or choose from the gallery.',
      'Review the output size and share when ready.',
    ],
    notes: [
      'Your photos stay on this device by default.',
      'The safe quality floor prevents visibly poor results.',
    ],
  );

  static const pdf = ToolGuide(
    title: 'PDF Tools',
    summary:
        'Scan documents, create PDFs from photos, and compress, merge, split, or unlock PDFs.',
    steps: [
      'Choose a task: Create, Scan document, Compress, Merge, Split, or Unlock.',
      'Add your photos or pick an existing PDF.',
      'Set an optional "Protect with password" before creating.',
      'Review the output and share when ready.',
    ],
    notes: [
      'PDFs are created locally and stay on your device.',
      'Unlocking only works on files you own or have permission to use.',
    ],
  );

  static const zip = ToolGuide(
    title: 'Zip Tools',
    summary:
        'Pack many files into one ZIP, or unlock an existing protected ZIP.',
    steps: [
      'Choose "Create ZIP" to combine files, optionally with a password.',
      'Choose "Unlock ZIP" to remove a password from your own file.',
      'Select the files or the ZIP, then create or unlock.',
    ],
    notes: [
      'Everything is packed and unpacked on your device.',
      'For educational and personal use only — only unlock files you own.',
    ],
  );

  static const history = ToolGuide(
    title: 'History',
    summary:
        'See everything you created, reshare it, or clear your local files.',
    steps: [
      'Browse your recent files with their sizes.',
      'Share again with one tap.',
      'Delete a file or clear all history from the menu.',
    ],
    notes: [
      'Files are stored only on this device.',
      'Deleting a file removes it from your device.',
    ],
  );
}
