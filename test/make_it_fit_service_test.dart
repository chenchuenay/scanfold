import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:scanfold/services/make_it_fit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    tempDir = Directory.systemTemp.createTempSync('scanfold_test');
  });

  test('makeItFit shapes a landscape image to a square target and shrinks it',
      () async {
    final src = img.Image(width: 2000, height: 1000);
    img.fill(src, color: img.ColorRgb8(30, 40, 50));
    final path = '${tempDir.path}/src_landscape.jpg';
    File(path).writeAsBytesSync(img.encodeJpg(src, quality: 100));

    const target = FitTarget(
      name: 'Test Square',
      reference: 'square',
      ratioX: 1,
      ratioY: 1,
      maxBytes: 200 * 1024,
      maxWidth: 500,
      maxHeight: 500,
    );

    final after = await MakeItFitService.makeItFit(
      sourcePath: path,
      target: target,
      output: tempDir,
    );

    expect(after, isNotNull);
    expect(after!.width, lessThanOrEqualTo(500));
    expect(after.height, lessThanOrEqualTo(500));
    expect(after.afterBytes, lessThanOrEqualTo(200 * 1024 + 4096));
    expect(File(after.path).existsSync(), isTrue);
    expect(after.beforeBytes, greaterThan(0));
  });
}
