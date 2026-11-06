import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Words a person reads on screen, shared by several journeys.
final Finder startGentleGame = find.text('Start a gentle game');
final Finder doneForNow = find.text('Done for now');
final Finder resumePrompt = find.text('Pick up where you left off?');
final Finder carryOn = find.text('Carry on');
final Finder startFresh = find.text('Start fresh');

/// A finished board names the moment where the instruction was.
final Finder gentleAllTogether = find.text('All pairs together.');
final Finder playAgain = find.text('Play again');

/// Saved-board key for the included starter pictures (GM-004).
const String starterSessionKey = 'gm.gentle.session.starter';

/// The button of type [T] (FilledButton, OutlinedButton, ...) that shows
/// [label], so tests can check which action is the dominant one.
Finder buttonWithLabel<T extends Widget>(Finder label) => find.ancestor(
  of: label,
  matching: find.byWidgetPredicate((widget) => widget is T),
);

/// Whether the button showing [label] can be pressed right now.
bool isEnabled(WidgetTester tester, Finder label) => tester
    .widget<ButtonStyleButton>(buttonWithLabel<ButtonStyleButton>(label).first)
    .enabled;

/// Opens the Home menu from its title-bar button and chooses the labelled row,
/// as a person does (the menu replaced the old icon buttons on Home).
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
}
