import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanfold/main.dart';

void main() {
  testWidgets('ScanFold home screen renders core tools', (tester) async {
    await tester.pumpWidget(const ScanFoldApp());

    expect(find.text('ScanFold'), findsOneWidget);
    expect(find.text('QR & Barcode'), findsOneWidget);
    expect(find.text('Photo Tools'), findsOneWidget);
    expect(find.text('PDF Tools'), findsOneWidget);
    expect(find.text('My Files'), findsOneWidget);
  });

  testWidgets('Make it Fit is available from Photo Tools', (tester) async {
    await tester.pumpWidget(const ScanFoldApp());
    await tester.tap(find.text('Photo Tools'));
    await tester.pumpAndSettle();

    expect(find.text('Make it Fit'), findsOneWidget);
    await tester.tap(find.text('Make it Fit'));
    await tester.pumpAndSettle();

    expect(find.text('WhatsApp Profile'), findsOneWidget);
    expect(find.text('Instagram Post'), findsOneWidget);
    expect(find.text('YouTube Thumbnail'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Passport photo'), findsOneWidget);
  });

  testWidgets('Photo tools hub lists photo modes', (tester) async {
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
    expect(find.text('ID and passport photo'), findsOneWidget);
    expect(find.text('Batch compress'), findsOneWidget);
  });

  testWidgets('QR hub lists scan and create options', (tester) async {
    await tester.pumpWidget(const ScanFoldApp());
    await tester.tap(find.text('QR & Barcode'));
    await tester.pumpAndSettle();

    expect(find.text('Scan a code'), findsOneWidget);
    expect(find.text('Create a QR code'), findsOneWidget);
  });

  testWidgets('PDF hub lists create, scan, compress, merge, and split', (
    tester,
  ) async {
    await tester.pumpWidget(const ScanFoldApp());
    await tester.scrollUntilVisible(
      find.text('PDF Tools'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('PDF Tools'));
    await tester.pumpAndSettle();

    expect(find.text('Create PDF from photos'), findsOneWidget);
    expect(find.text('Scan a document'), findsOneWidget);
    expect(find.text('Compress a PDF'), findsOneWidget);
    expect(find.text('Merge PDFs'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Split a PDF'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('Split a PDF'), findsOneWidget);
  });

  testWidgets('Resize shows aspect presets with references before uploading', (
    tester,
  ) async {
    await tester.pumpWidget(const ScanFoldApp());
    await tester.tap(find.text('Photo Tools'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Resize dimensions'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resize dimensions'));
    await tester.pumpAndSettle();

    expect(find.text('Square · 1:1'), findsOneWidget);
    expect(find.text('WhatsApp & Instagram profile, avatars'), findsOneWidget);
    expect(find.text('Story · 9:16'), findsOneWidget);
  });

  testWidgets('ID photo shows size presets with references before uploading', (
    tester,
  ) async {
    await tester.pumpWidget(const ScanFoldApp());
    await tester.tap(find.text('Photo Tools'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('ID and passport photo'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('ID and passport photo'));
    await tester.pumpAndSettle();

    expect(find.text('35×45 mm'), findsOneWidget);
    expect(find.text('Passport (EU, India)'), findsOneWidget);
    expect(find.text('2×2 inch'), findsOneWidget);
  });

  testWidgets('Home screen shows Zip Files tile', (tester) async {
    await tester.pumpWidget(const ScanFoldApp());
    await tester.scrollUntilVisible(
      find.text('Zip Files'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('Zip Files'), findsOneWidget);
  });

  testWidgets('Photo compress shows size preferences before uploading', (
    tester,
  ) async {
    await tester.pumpWidget(const ScanFoldApp());
    await tester.tap(find.text('Photo Tools'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compress to a size'));
    await tester.pumpAndSettle();

    expect(find.text('Maximum file size'), findsOneWidget);
    expect(find.text('500 KB'), findsOneWidget);
    expect(find.text('1 MB'), findsOneWidget);
  });

  testWidgets('Document scanner shows password before capturing', (
    tester,
  ) async {
    await tester.pumpWidget(const ScanFoldApp());
    await tester.scrollUntilVisible(
      find.text('PDF Tools'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('PDF Tools'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Scan a document'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan a document'));
    await tester.pumpAndSettle();

    expect(find.text('Password (optional)'), findsOneWidget);
  });
}
