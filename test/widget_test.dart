import 'package:flutter/material.dart';
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

  testWidgets('Photo tools hub lists all photo modes', (tester) async {
    await tester.pumpWidget(const ScanFoldApp());
    await tester.tap(find.text('Photo Tools'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Batch compress'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('Compress to a size'), findsOneWidget);
    expect(find.text('Resize dimensions'), findsOneWidget);
    expect(find.text('Scan a document'), findsOneWidget);
    expect(find.text('ID and passport photo'), findsOneWidget);
    expect(find.text('Batch compress'), findsOneWidget);
  });

  testWidgets('QR hub lists scan, create, and gallery options',
      (tester) async {
    await tester.pumpWidget(const ScanFoldApp());
    await tester.tap(find.text('QR & Barcode'));
    await tester.pumpAndSettle();

    expect(find.text('Scan a code'), findsOneWidget);
    expect(find.text('Create a QR code'), findsOneWidget);
    expect(find.text('Scan from gallery'), findsOneWidget);
  });

  testWidgets('PDF hub lists create, compress, and merge options',
      (tester) async {
    await tester.pumpWidget(const ScanFoldApp());
    await tester.scrollUntilVisible(
      find.text('PDF Maker'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('PDF Maker'));
    await tester.pumpAndSettle();

    expect(find.text('Create PDF from photos'), findsOneWidget);
    expect(find.text('Compress a PDF'), findsOneWidget);
    expect(find.text('Merge PDFs'), findsOneWidget);
  });
}
