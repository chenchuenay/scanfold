import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'history_service.dart';

/// A "Make it Fit" target: the shape and size an image should be optimized for,
/// plus the real-world situation a user is preparing for.
class FitTarget {
  final String name;
  final String reference;
  final int ratioX;
  final int ratioY;
  final int maxBytes;
  final int maxWidth;
  final int maxHeight;

  const FitTarget({
    required this.name,
    required this.reference,
    required this.ratioX,
    required this.ratioY,
    required this.maxBytes,
    required this.maxWidth,
    required this.maxHeight,
  });

  bool get hasAspect => ratioX > 0 && ratioY > 0;
}

const fitTargets = [
  FitTarget(
    name: 'WhatsApp Profile',
    reference: 'Chat photo · square',
    ratioX: 1,
    ratioY: 1,
    maxBytes: 500 * 1024,
    maxWidth: 500,
    maxHeight: 500,
  ),
  FitTarget(
    name: 'Instagram Post',
    reference: 'Feed · square',
    ratioX: 1,
    ratioY: 1,
    maxBytes: 1024 * 1024,
    maxWidth: 1080,
    maxHeight: 1080,
  ),
  FitTarget(
    name: 'Instagram Story',
    reference: 'Status · portrait',
    ratioX: 9,
    ratioY: 16,
    maxBytes: 1024 * 1024,
    maxWidth: 1080,
    maxHeight: 1920,
  ),
  FitTarget(
    name: 'YouTube Thumbnail',
    reference: 'Wide · 16:9',
    ratioX: 16,
    ratioY: 9,
    maxBytes: 1024 * 1024,
    maxWidth: 1280,
    maxHeight: 720,
  ),
  FitTarget(
    name: 'Email',
    reference: 'Attach under 1 MB',
    ratioX: 0,
    ratioY: 0,
    maxBytes: 1024 * 1024,
    maxWidth: 1600,
    maxHeight: 1600,
  ),
  FitTarget(
    name: 'Passport photo',
    reference: 'ID · portrait',
    ratioX: 35,
    ratioY: 45,
    maxBytes: 300 * 1024,
    maxWidth: 600,
    maxHeight: 771,
  ),
];

/// The outcome of a Make-it-Fit operation, including before/after sizes.
class MakeItFitResult {
  final String path;
  final int beforeBytes;
  final int afterBytes;
  final int width;
  final int height;
  final int quality;

  const MakeItFitResult({
    required this.path,
    required this.beforeBytes,
    required this.afterBytes,
    required this.width,
    required this.height,
    required this.quality,
  });

  int get savedBytes => beforeBytes > afterBytes ? beforeBytes - afterBytes : 0;
  double get savedPercent => savedBytes == 0 || beforeBytes == 0
      ? 0
      : (savedBytes / beforeBytes) * 100;
}

abstract final class MakeItFitService {
  static Future<Directory> _outputDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/scanfold');
    await directory.create(recursive: true);
    return directory;
  }

  static Future<MakeItFitResult?> makeItFit({
    required String sourcePath,
    required FitTarget target,
    Directory? output,
  }) async {
    final originalBytes = await File(sourcePath).readAsBytes();
    final decoded = img.decodeImage(originalBytes);
    if (decoded == null) return null;
    final beforeBytes = originalBytes.length;

    // 1) Shape it (blurred fill) only when a target aspect differs from source.
    img.Image working = await _shapeIfNeeded(decoded, target);
    working = await _fitWithinBounds(working, target);

    // 2) Compress under the byte budget while keeping quality high.
    final result = await _compressToBudget(
      image: working,
      target: target,
      beforeBytes: beforeBytes,
      output: output ?? await _outputDirectory(),
    );
    return result;
  }

  static Future<img.Image> _shapeIfNeeded(
    img.Image src,
    FitTarget target,
  ) async {
    if (!target.hasAspect) return src;
    final srcRatio = src.width / src.height;
    final desired = target.ratioX / target.ratioY;
    if ((srcRatio - desired).abs() <= 0.02) return src;

    final outW = target.maxWidth;
    final outH = (outW / desired).round();
    final canvas = img.Image(width: outW, height: outH);

    // Blurred cover background.
    final bg = img.copyResizeCropSquare(src, size: outW > outH ? outH : outW);
    final bgResized = img.copyResize(
      bg,
      width: outW,
      height: outH,
      interpolation: img.Interpolation.cubic,
    );
    img.compositeImage(canvas, bgResized);
    img.gaussianBlur(canvas, radius: 8);

    // Sharp foreground fully visible, centered.
    final scale = (outW / src.width) < (outH / src.height)
        ? (outW / src.width)
        : (outH / src.height);
    final fw = (src.width * scale).round();
    final fh = (src.height * scale).round();
    final fg = img.copyResize(
      src,
      width: fw,
      height: fh,
      interpolation: img.Interpolation.cubic,
    );
    img.compositeImage(
      canvas,
      fg,
      dstX: ((outW - fw) / 2).round(),
      dstY: ((outH - fh) / 2).round(),
    );
    return canvas;
  }

  static Future<img.Image> _fitWithinBounds(
    img.Image src,
    FitTarget target,
  ) async {
    final scale =
        (src.width / target.maxWidth) < (src.height / target.maxHeight)
        ? (src.width / target.maxWidth)
        : (src.height / target.maxHeight);
    if (scale <= 1) return src;
    final w = (src.width / scale).round();
    final h = (src.height / scale).round();
    return img.copyResize(
      src,
      width: w,
      height: h,
      interpolation: img.Interpolation.cubic,
    );
  }

  static Future<MakeItFitResult?> _compressToBudget({
    required img.Image image,
    required FitTarget target,
    required int beforeBytes,
    required Directory output,
  }) async {
    final directory = output;
    final outputPath =
        '${directory.path}/scan_${DateTime.now().millisecondsSinceEpoch}.jpg';

    Uint8List? best;
    var bestQuality = 90;
    for (final quality in [92, 88, 84, 80, 75, 70, 65]) {
      final bytes = img.encodeJpg(image, quality: quality);
      best = Uint8List.fromList(bytes);
      bestQuality = quality;
      if (bytes.length <= target.maxBytes) break;
    }
    if (best == null) return null;

    await File(outputPath).writeAsBytes(best, flush: true);
    await HistoryService.add(
      HistoryItem(
        title: 'Fitted: ${target.name}',
        type: 'image',
        path: outputPath,
        createdAt: DateTime.now(),
      ),
    );
    final decodedSaved = img.decodeImage(best);
    return MakeItFitResult(
      path: outputPath,
      beforeBytes: beforeBytes,
      afterBytes: best.length,
      width: decodedSaved?.width ?? image.width,
      height: decodedSaved?.height ?? image.height,
      quality: bestQuality,
    );
  }
}
