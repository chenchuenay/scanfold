import 'package:flutter_test/flutter_test.dart';
import 'package:scanfold/main.dart';

void main() {
  testWidgets('ScanFold home screen renders core tools', (tester) async {
    await tester.pumpWidget(const ScanFoldApp());

    expect(find.text('ScanFold'), findsOneWidget);
    expect(find.text('QR & Barcode'), findsOneWidget);
    expect(find.text('Photo Tools'), findsOneWidget);
    expect(find.text('PDF Maker'), findsOneWidget);
    expect(find.text('My Files'), findsOneWidget);
  });
}
