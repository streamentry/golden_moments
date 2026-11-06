import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens the Home menu from its title-bar button, then chooses the labelled
/// row [label], as a person does.
Future<void> tapHomeMenuItem(WidgetTester tester, String label) async {
  await tester.tap(find.text('Menu'));
  await tester.pumpAndSettle();
  final row = find.widgetWithText(ListTile, label);
  // Menu rows are built lazily in a list; bring the row on screen first.
  await tester.scrollUntilVisible(
    row,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  // Fully on screen, so the tap lands on the row.
  await tester.ensureVisible(row);
  await tester.tap(row);
  await tester.pumpAndSettle();
  // Comfort settings and the guide load their saved values asynchronously.
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}
