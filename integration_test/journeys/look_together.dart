import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/board.dart';
import '../support/screens.dart';

final Finder _lookTogether = find.text('Look together');
final Finder _next = find.text('Next');
final Finder _previous = find.text('Previous');
final Finder _prompt = find.text('Show a conversation prompt');
final Finder _hide = find.text('Hide this picture');

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
  await waitFor(tester, find.text('Picture 1 of 6'));
  expect(find.bySemanticsLabel('Flower'), findsOneWidget);
  expect(isEnabled(tester, _previous), isFalse);
  expect(isEnabled(tester, _next), isTrue);
  // The included pictures have no captions, so there is nothing to toggle.
  expect(find.text('Show captions'), findsNothing);
  expectHittable(tester, doneForNow);
  expectHittable(tester, _next);
  expectNoPressureCues(tester);
  await snap(tester, 'j4-look-together$tag');

  await tapOn(tester, _next);
  await waitFor(tester, find.text('Picture 2 of 6'));
  expect(find.bySemanticsLabel('Cup'), findsOneWidget);
  await tapOn(tester, _previous);
  await waitFor(tester, find.text('Picture 1 of 6'));
  expect(find.bySemanticsLabel('Flower'), findsOneWidget);

  // A conversation prompt only when asked for.
  const question = 'What do you like about this picture?';
  expect(find.text(question), findsNothing);
  await tapOn(tester, _prompt);
  await waitFor(tester, find.text(question));
  await snap(tester, 'j4-prompt$tag');
  await tapOn(tester, _prompt);
  await waitForAbsent(tester, find.text(question));

  // Hiding an included picture lasts for this visit only.
  await tapOn(tester, _hide);
  await waitFor(tester, find.text('This picture is hidden for now.'));
  expect(find.text('Picture 1 of 5'), findsOneWidget);
  expect(find.bySemanticsLabel('Flower'), findsNothing);
  expect(find.bySemanticsLabel('Cup'), findsOneWidget);
  await letTimePass(tester, const Duration(seconds: 2));
  expect(find.text('Picture 1 of 5'), findsOneWidget, reason: 'no slideshow');
  expectNoPressureCues(tester);
  await snap(tester, 'j4-hidden-for-visit$tag');

  await tapOn(tester, doneForNow);
  await waitFor(tester, startGentleGame);
  await tapOn(tester, _lookTogether);
  await waitFor(tester, find.text('Picture 1 of 6'));
  expect(find.bySemanticsLabel('Flower'), findsOneWidget);
  await tapOn(tester, doneForNow);
  await waitFor(tester, startGentleGame);
}
