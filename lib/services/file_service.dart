import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'history_service.dart';

abstract final class FileService {
  static Future<Directory> _outputDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/scanfold');
    await directory.create(recursive: true);
    return directory;
  }

  static Future<String?> compressImage({
    required String sourcePath,
    int quality = 82,
    int? width,
  }) async {
    final bytes = width == null
        ? await FlutterImageCompress.compressWithFile(
            sourcePath,
            quality: quality,
            format: CompressFormat.jpeg,
          )
        : await FlutterImageCompress.compressWithFile(
            sourcePath,
            quality: quality,
            minWidth: width,
            format: CompressFormat.jpeg,
          );
    if (bytes == null) return null;
    final directory = await _outputDirectory();
    final output =
        '${directory.path}/scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(output).writeAsBytes(bytes, flush: true);
    await HistoryService.add(
      HistoryItem(
        title: 'Compressed photo',
        type: 'image',
        path: output,
        createdAt: DateTime.now(),
      ),
    );
    return output;
  }

  static Future<String> imagesToPdf(List<String> paths) async {
    final document = pw.Document();
    for (final path in paths) {
      final bytes = await File(path).readAsBytes();
      final image = pw.MemoryImage(bytes);
      document.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(20),
          build: (_) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
        ),
      );
    }
    final directory = await _outputDirectory();
    final output =
        '${directory.path}/scan_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await File(output).writeAsBytes(await document.save(), flush: true);
    await HistoryService.add(
      HistoryItem(
        title: 'Created PDF',
        type: 'pdf',
        path: output,
        createdAt: DateTime.now(),
      ),
    );
    return output;
  }

  static Future<void> share(String path) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(path)]));
  }

  static Future<Uint8List> readBytes(String path) => File(path).readAsBytes();
}
