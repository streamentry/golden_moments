import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/board.dart';
import '../support/screens.dart';

/// Journey 8: help, privacy and support open from Home with no network, each
/// page has a plain way back, and a note is shown exactly and sent nowhere
/// until the person chooses where. Links that would leave the app are not
/// followed here.
Future<void> helpAndPrivacy(WidgetTester tester) async {
  await launchApp(tester);
  await waitFor(tester, startGentleGame);

  // The guide on Home says what the app is, and what it is not.
  await tapOn(tester, find.byTooltip('Guide and privacy'));
  await waitFor(tester, find.text('Enjoy it together'));
  expect(find.textContaining('It does not diagnose'), findsOneWidget);
  expectNoPressureCues(tester);
  await snap(tester, 'j8-guide');

  await tapOn(tester, find.text('More help and privacy'));
  await waitFor(tester, find.text('This page works without internet.'));
  for (final heading in [
    'Enjoying it together',
    'Your photos and privacy',
    'If something goes wrong',
    'Reach us',
  ]) {
    await reveal(tester, find.text(heading));
    expect(find.text(heading), findsOneWidget, reason: heading);
  }

  // Writing a note: the preview shows exactly what would be shared, and
  // nothing goes anywhere until "Choose where to send".
  await tapOn(tester, find.text('Write a note'));
  final send = find.text('Choose where to send');
  await waitFor(tester, send);
  expect(buttonWithLabel<FilledButton>(send), findsOneWidget);
  expect(isEnabled(tester, send), isFalse, reason: 'nothing to send yet');
  const note = 'The large tiles are easy to see.';
  await tester.enterText(find.byType(TextField), note);
  await settle(tester);
  expect(isEnabled(tester, send), isTrue);
  expect(
    find.descendant(
      of: find.byType(SelectableText),
      matching: find.textContaining(note),
    ),
    findsOneWidget,
    reason: 'the preview shows the note',
  );
  await snap(tester, 'j8-note');
  await tapOn(tester, find.text('Cancel'));
  await waitForAbsent(tester, send);

  await tapOn(tester, doneForNow);
  await waitFor(tester, startGentleGame);

  // Privacy, terms and support: every link is named and explained.
  await tapOn(tester, find.byTooltip('Guide and privacy'));
  await tapOn(tester, find.text('Privacy, terms and support'));
  await waitFor(tester, find.text('Your pictures, your choice'));
  for (final link in [
    'Mobile app privacy policy',
    'Privacy choices and deletion',
    'Terms and app license',
    'Safety and intended use',
    'Contact support',
  ]) {
    await reveal(tester, find.text(link));
    expect(find.text(link), findsOneWidget, reason: link);
  }
  expectNoPressureCues(tester);
  await snap(tester, 'j8-privacy');
  await tapOn(tester, doneForNow);
  await waitFor(tester, startGentleGame);
}
