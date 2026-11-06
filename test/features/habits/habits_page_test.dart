import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/habits/presentation/habits_page.dart';
import 'package:golden_moments/features/wellbeing/presentation/activity_planner_page.dart';
import 'package:golden_moments/l10n/l10n.dart';

import '../../helpers/pump_app.dart';

/// Claims, brain language and pressure the habits page must never use.
final _forbidden = RegExp(
  r'\bwill (prevent|protect|lower|reduce|stop)|\bprotects (you|your)\b|'
  r'\b(reduces|lowers|cuts) (your |the )?(risk|chance)|boosts?|'
  r'improves? (your )?memory|brain|train|\bscore|streak|guarantee|\bcure|'
  r'reverse|\btimer\b|countdown|points?\b',
  caseSensitive: false,
);

/// A tall surface, so the whole page is built; the list is lazy.
void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 5000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

List<String> _text(WidgetTester tester) => [
  for (final t in tester.widgetList<Text>(find.byType(Text)))
    if (t.data != null) t.data!,
  for (final t in tester.widgetList<SelectableText>(
    find.byType(SelectableText),
  ))
    if (t.data != null) t.data!,
];

void main() {
  testWidgets('shows six habits, each worded as linked with, never as a cure', (
    tester,
  ) async {
    _tall(tester);
    await tester.pumpApp(const HabitsPage());
    final l10n = AppLocalizations.of(tester.element(find.byType(HabitsPage)));

    for (final title in [
      l10n.habitsHearingVisionTitle,
      l10n.habitsHeartTitle,
      l10n.habitsMoveTitle,
      l10n.habitsConnectTitle,
      l10n.habitsSmokeTitle,
      l10n.habitsHeadTitle,
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    for (final body in [
      l10n.habitsHearingVisionBody,
      l10n.habitsHeartBody,
      l10n.habitsMoveBody,
      l10n.habitsConnectBody,
      l10n.habitsSmokeBody,
      l10n.habitsHeadBody,
    ]) {
      expect(body, contains('linked with'));
      expect(find.text(body), findsOneWidget);
    }
  });

  testWidgets('says plainly that nothing is proven to prevent dementia', (
    tester,
  ) async {
    _tall(tester);
    await tester.pumpApp(const HabitsPage());
    final l10n = AppLocalizations.of(tester.element(find.byType(HabitsPage)));

    expect(find.text(l10n.habitsIntro), findsOneWidget);
    expect(
      l10n.habitsIntro,
      contains('no habit, game or diet has been proven to prevent dementia'),
    );
    expect(l10n.habitsIntro, contains('not a promise for any one person'));
    expect(find.text(l10n.habitsDoctorNote), findsOneWidget);
    // The source is named as copyable text, not opened by the app.
    expect(find.byType(SelectableText), findsOneWidget);
    expect(l10n.habitsSources, contains('whole populations'));
  });

  testWidgets('uses no claim, brain, score, streak or timer wording', (
    tester,
  ) async {
    _tall(tester);
    await tester.pumpApp(const HabitsPage());
    // The source address is kept exactly as published, so it is not checked.
    final address = RegExp(r'dementiaactivities\.games\S*');
    for (final text in _text(tester)) {
      final words = text.replaceAll(address, '');
      expect(_forbidden.hasMatch(words), isFalse, reason: 'found "$text"');
    }
  });

  testWidgets('leads to the day planner, and has a Back control', (
    tester,
  ) async {
    _tall(tester);
    await tester.pumpApp(const HabitsPage());
    final l10n = AppLocalizations.of(tester.element(find.byType(HabitsPage)));

    expect(find.widgetWithText(TextButton, l10n.commonBack), findsOneWidget);
    final plan = find.widgetWithText(OutlinedButton, l10n.wellbeingHomePlanner);
    await tester.ensureVisible(plan);
    await tester.pumpAndSettle();
    await tester.tap(plan);
    await tester.pumpAndSettle();
    expect(find.byType(ActivityPlannerPage), findsOneWidget);
  });

  testWidgets('lays out at 200% text without overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const HabitsPage(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
