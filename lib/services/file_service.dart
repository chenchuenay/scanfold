import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

import 'history_service.dart';

abstract final class FileService {
  static Future<Directory> _outputDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/scanfold');
    await directory.create(recursive: true);
    return directory;
  }

  static Future<CompressionResult?> compressImageToTarget({
    required String sourcePath,
    required int targetBytes,
    int? width,
  }) async {
    Uint8List? best;
    var selectedQuality = 95;
    for (final quality in [95, 90, 85, 80, 75, 70, 65]) {
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
      if (bytes == null) continue;
      best = bytes;
      selectedQuality = quality;
      if (bytes.length <= targetBytes) break;
    }
    if (best == null) return null;
    final directory = await _outputDirectory();
    final output =
        '${directory.path}/scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(output).writeAsBytes(best, flush: true);
    await HistoryService.add(
      HistoryItem(
        title: 'Compressed photo',
        type: 'image',
        path: output,
        createdAt: DateTime.now(),
      ),
    );
    return CompressionResult(
      path: output,
      bytes: best.length,
      quality: selectedQuality,
      reachedTarget: best.length <= targetBytes,
    );
  }

  static Future<String> imagesToPdf(List<String> paths) async {
    final document = pw.Document();
    for (final path in paths) {
      final bytes = await File(path).readAsBytes();
      final image = pw.MemoryImage(bytes);
      document.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(20),
          build: (_) =>
              pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
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

  static Future<PdfCompressionResult?> compressPdf(String inputPath) async {
    final inputBytes = await File(inputPath).readAsBytes();
    final document = sf.PdfDocument(inputBytes: inputBytes);
    final bytes = await document.save();
    document.dispose();
    if (bytes.length >= inputBytes.length) return null;
    final directory = await _outputDirectory();
    final output =
        '${directory.path}/scan_${DateTime.now().millisecondsSinceEpoch}_small.pdf';
    await File(output).writeAsBytes(bytes, flush: true);
    await HistoryService.add(
      HistoryItem(
        title: 'Compressed PDF',
        type: 'pdf',
        path: output,
        createdAt: DateTime.now(),
      ),
    );
    return PdfCompressionResult(
      path: output,
      beforeBytes: inputBytes.length,
      afterBytes: bytes.length,
    );
  }

  static Future<void> share(String path) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(path)]));
  }

  static Future<Uint8List> readBytes(String path) => File(path).readAsBytes();
}

class CompressionResult {
  final String path;
  final int bytes;
  final int quality;
  final bool reachedTarget;

  const CompressionResult({
    required this.path,
    required this.bytes,
    required this.quality,
    required this.reachedTarget,
  });
}

class PdfCompressionResult {
  final String path;
  final int beforeBytes;
  final int afterBytes;

  const PdfCompressionResult({
    required this.path,
    required this.beforeBytes,
    required this.afterBytes,
  });
}
