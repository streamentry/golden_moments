import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';

import '../support/app_harness.dart';
import '../support/board.dart';
import '../support/screens.dart';

final Finder _lookTogether = find.text('Look together');
final Finder _next = find.text('Next');
final Finder _previous = find.text('Previous');
final Finder _prompt = find.text('Show a conversation prompt');
final Finder _hide = find.text('Hide this picture');

/// The included drawings, in order (shared with the website). They carry
/// no "Picture N of M" count: a library to browse, not a set to finish.
final Finder _count = find.textContaining(RegExp(r'^Picture \d+ of \d+'));
final String _first = ActivityPicture.samples[0].label;
final String _second = ActivityPicture.samples[1].label;

/// Journey 4 (also run at 200% text): look at the included pictures with
/// Next/Previous, the optional prompt, hiding one for this visit only, and
/// Done for now. Nothing advances on its own.
Future<void> lookTogetherIncluded(
  WidgetTester tester, {
  double textScale = 1,
}) async {
  final tag = textScale == 1 ? '' : '-text-${(textScale * 100).round()}';
  await launchApp(tester, textScale: textScale);
  await tapOn(tester, _lookTogether);
  await waitFor(tester, find.bySemanticsLabel(_first));
  expect(_count, findsNothing);
  expect(isEnabled(tester, _previous), isFalse);
  expect(isEnabled(tester, _next), isTrue);
  // The included pictures have no captions, so there is nothing to toggle.
  expect(find.text('Show captions'), findsNothing);
  expectHittable(tester, doneForNow);
  expectHittable(tester, _next);
  expectNoPressureCues(tester);
  await checkpoint(tester, 'j4-look-together$tag');

  await tapOn(tester, _next);
  await waitFor(tester, find.bySemanticsLabel(_second));
  expect(_count, findsNothing);
  await tapOn(tester, _previous);
  await waitFor(tester, find.bySemanticsLabel(_first));

  // A conversation prompt only when asked for.
  const question = 'What do you like about this picture?';
  expect(find.text(question), findsNothing);
  await tapOn(tester, _prompt);
  await waitFor(tester, find.text(question));
  await checkpoint(tester, 'j4-prompt$tag');
  await tapOn(tester, _prompt);
  await waitForAbsent(tester, find.text(question));

  // Hiding an included picture lasts for this visit only.
  await tapOn(tester, _hide);
  await waitFor(tester, find.text('Hidden for this visit.'));
  // The view returns to the next picture, with the note above it.
  expect(find.bySemanticsLabel(_first), findsNothing);
  expect(find.bySemanticsLabel(_second), findsOneWidget);
  await reveal(tester, find.bySemanticsLabel(_second));
  await letTimePass(tester, const Duration(seconds: 2));
  expect(
    find.bySemanticsLabel(_second),
    findsOneWidget,
    reason: 'no slideshow',
  );
  expect(_count, findsNothing);
  expectNoPressureCues(tester);
  await checkpoint(tester, 'j4-hidden-for-visit$tag');

  await tapOn(tester, doneForNow);
  await waitFor(tester, startGentleGame);
  await tapOn(tester, _lookTogether);
  await waitFor(tester, find.bySemanticsLabel(_first));
  await tapOn(tester, doneForNow);
  await waitFor(tester, startGentleGame);
}
