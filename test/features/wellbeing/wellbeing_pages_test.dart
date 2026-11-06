import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/wellbeing/data/moment_history.dart';
import 'package:golden_moments/features/wellbeing/data/routines.dart';
import 'package:golden_moments/features/wellbeing/presentation/activity_planner_page.dart';
import 'package:golden_moments/features/wellbeing/presentation/daily_moment_page.dart';
import 'package:golden_moments/features/wellbeing/presentation/progress_page.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/pump_app.dart';

const _key = 'wellbeing.momentDays.v1';
final _today = DateTime(2026, 11, 6, 9);

/// Words that would turn the wellbeing pages into a test, a clock or a score.
final _forbidden = RegExp(
  r'streak|in a row|you missed|\bscore|\bpoints?\b|\btimer\b|countdown|'
  r'\bmoves?\b|\bseconds?\b|\d+ of \d+',
  caseSensitive: false,
);

/// Every text on screen, so a forbidden word anywhere fails the test.
List<String> _visibleText(WidgetTester tester) => [
  for (final text in tester.widgetList<Text>(find.byType(Text)))
    if (text.data != null) text.data!,
];

void _expectNoForbiddenWords(WidgetTester tester) {
  for (final text in _visibleText(tester)) {
    expect(_forbidden.hasMatch(text), isFalse, reason: 'found "$text"');
  }
}

AppLocalizations _l10n(WidgetTester tester, Type page) =>
    AppLocalizations.of(tester.element(find.byType(page)));

void main() {
  group('routines', () {
    test('every time and audience gives three steps, and only three kinds of '
        'step open a page', () {
      for (final time in PlanTime.values) {
        for (final who in PlanFor.values) {
          final steps = routineFor(time, who);
          expect(steps, hasLength(3), reason: '$time $who');
          expect(steps.toSet(), hasLength(3), reason: 'no repeated step');
        }
      }
      expect(RoutineItem.values.where((item) => item.opens).toSet(), {
        RoutineItem.dailyMoment,
        RoutineItem.matchingGame,
        RoutineItem.lookTogether,
      });
    });
  });

  group('Daily moment', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    testWidgets('three steps, then Done for now saves today on this phone', (
      tester,
    ) async {
      final store = const MomentHistoryStore();
      await tester.pumpApp(
        DailyMomentPage(
          pictures: ActivityPicture.samples,
          store: store,
          clock: () => _today,
        ),
      );
      final l10n = _l10n(tester, DailyMomentPage);

      expect(find.text(l10n.wellbeingDailyMomentIntro), findsOneWidget);
      expect(
        find.textContaining('5 to 10 minutes'),
        findsOneWidget,
        reason: 'the length is a suggestion in words, not a timer',
      );
      expect(find.textContaining('stop at any time'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, l10n.commonContinue));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, l10n.commonContinue));
      await tester.pump();
      await tester.tap(
        find.widgetWithText(FilledButton, l10n.commonDoneForNow),
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.wellbeingDailyMomentSaved), findsOneWidget);
      expect((await store.load()).days, {'2026-11-06'});
      _expectNoForbiddenWords(tester);
    });

    testWidgets('Back goes to the previous picture and nothing is saved', (
      tester,
    ) async {
      final store = const MomentHistoryStore();
      await tester.pumpApp(
        DailyMomentPage(
          pictures: ActivityPicture.samples,
          store: store,
          clock: () => _today,
        ),
      );
      final l10n = _l10n(tester, DailyMomentPage);

      await tester.tap(find.widgetWithText(FilledButton, l10n.commonContinue));
      await tester.pump();
      await tester.tap(find.widgetWithText(TextButton, l10n.commonBack));
      await tester.pump();

      expect(
        find.widgetWithText(FilledButton, l10n.commonContinue),
        findsOneWidget,
      );
      expect((await store.load()).days, isEmpty);
    });

    testWidgets(
      'an unreadable history is not overwritten; the person is told',
      (tester) async {
        SharedPreferences.setMockInitialValues({_key: 'broken'});
        final store = const MomentHistoryStore();
        await tester.pumpApp(
          DailyMomentPage(
            pictures: ActivityPicture.samples,
            store: store,
            clock: () => _today,
          ),
        );
        final l10n = _l10n(tester, DailyMomentPage);

        for (var i = 0; i < DailyMomentPage.steps - 1; i++) {
          await tester.tap(
            find.widgetWithText(FilledButton, l10n.commonContinue),
          );
          await tester.pump();
        }
        await tester.tap(
          find.widgetWithText(FilledButton, l10n.commonDoneForNow),
        );
        await tester.pumpAndSettle();

        expect(find.text(l10n.wellbeingDailyMomentSaveFailed), findsOneWidget);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(_key), 'broken');
      },
    );
  });

  group('Activity planner', () {
    testWidgets('the suggestions change with the time and the person', (
      tester,
    ) async {
      await tester.pumpApp(const ActivityPlannerPage());
      final l10n = _l10n(tester, ActivityPlannerPage);

      expect(find.text(l10n.wellbeingItemDrinkWater), findsOneWidget);

      await tester.tap(find.text(l10n.wellbeingPlannerEvening));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.wellbeingPlannerForCared));
      await tester.pumpAndSettle();

      expect(find.text(l10n.wellbeingItemKeepQuiet), findsOneWidget);
      expect(find.text(l10n.wellbeingItemDrinkWater), findsNothing);
      _expectNoForbiddenWords(tester);
    });

    testWidgets('a step that opens a page does, and a suggestion does not', (
      tester,
    ) async {
      await tester.pumpApp(const ActivityPlannerPage());
      final l10n = _l10n(tester, ActivityPlannerPage);

      // Morning, for me: the drink of water is a suggestion, not a button.
      expect(
        find.widgetWithText(OutlinedButton, l10n.wellbeingItemDrinkWater),
        findsNothing,
      );
      await tester.tap(
        find.widgetWithText(OutlinedButton, l10n.wellbeingItemDailyMoment),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DailyMomentPage), findsOneWidget);
    });
  });

  group('My progress', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    testWidgets('shows a plain message when no day is saved', (tester) async {
      await tester.pumpApp(const ProgressPage(clock: _fixedClock));
      await tester.pumpAndSettle();
      final l10n = _l10n(tester, ProgressPage);

      expect(find.text(l10n.wellbeingProgressEmpty), findsOneWidget);
      expect(
        find.widgetWithText(TextButton, l10n.wellbeingProgressClear),
        findsNothing,
      );
      _expectNoForbiddenWords(tester);
    });

    testWidgets(
      'lists the saved days as dates only, newest first, and clears on '
      'confirmation',
      (tester) async {
        const store = MomentHistoryStore();
        await store.markDone(DateTime(2026, 11, 2));
        await store.markDone(DateTime(2026, 11, 6));
        await tester.pumpApp(const ProgressPage());
        await tester.pumpAndSettle();
        final l10n = _l10n(tester, ProgressPage);
        final materials = MaterialLocalizations.of(
          tester.element(find.byType(ProgressPage)),
        );

        final newest = materials.formatFullDate(DateTime(2026, 11, 6));
        final older = materials.formatFullDate(DateTime(2026, 11, 2));
        expect(find.text(newest), findsOneWidget);
        expect(find.text(older), findsOneWidget);
        expect(
          tester.getTopLeft(find.text(newest)).dy,
          lessThan(tester.getTopLeft(find.text(older)).dy),
          reason: 'newest first',
        );
        _expectNoForbiddenWords(tester);

        await tester.tap(
          find.widgetWithText(TextButton, l10n.wellbeingProgressClear),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, l10n.commonCancel));
        await tester.pumpAndSettle();
        expect(
          find.text(newest),
          findsOneWidget,
          reason: 'cancel keeps the days',
        );

        await tester.tap(
          find.widgetWithText(TextButton, l10n.wellbeingProgressClear),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(TextButton, l10n.wellbeingProgressClear).last,
        );
        await tester.pumpAndSettle();

        expect(find.text(l10n.wellbeingProgressCleared), findsOneWidget);
        expect(find.text(newest), findsNothing);
        expect((await store.load()).days, isEmpty);
      },
    );

    testWidgets(
      'an unreadable record is explained and can be cleared on purpose',
      (tester) async {
        SharedPreferences.setMockInitialValues({_key: 'broken'});
        await tester.pumpApp(const ProgressPage());
        await tester.pumpAndSettle();
        final l10n = _l10n(tester, ProgressPage);

        expect(find.text(l10n.wellbeingProgressUnreadable), findsOneWidget);
        expect(
          find.widgetWithText(TextButton, l10n.wellbeingProgressClear),
          findsOneWidget,
        );
      },
    );
  });
}

DateTime _fixedClock() => _today;
