import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_home_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_together_page.dart';
import 'package:golden_moments/features/todays_activity/data/todays_activity.dart';
import 'package:golden_moments/features/todays_activity/presentation/todays_activity_card.dart';
import 'package:golden_moments/features/wellbeing/presentation/daily_moment_page.dart';
import 'package:golden_moments/l10n/gen/app_localizations.dart';
import 'package:golden_moments/shared/native/gm_native.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home, {double textScale = 1}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  theme: gmBuildTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: home,
);

/// A day whose default is Daily moment, found rather than hard-coded.
DateTime _dayFor(TodaysActivity wanted) {
  var day = DateTime(2026, 11, 7, 9);
  while (TodaysActivity.forDay(day) != wanted) {
    day = day.add(const Duration(days: 1));
  }
  return day;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows one suggestion, and Begin hands it over', (tester) async {
    final day = _dayFor(TodaysActivity.dailyMoment);
    TodaysActivity? begun;
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: TodaysActivityCard(clock: () => day, onBegin: (a) => begun = a),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's activity"), findsOneWidget);
    expect(find.text('Daily moment'), findsOneWidget);
    expect(find.text('Look together'), findsNothing);
    await tester.tap(find.text('Begin'));
    expect(begun, TodaysActivity.dailyMoment);
  });

  testWidgets('Something else swaps it and is remembered for today', (
    tester,
  ) async {
    final day = _dayFor(TodaysActivity.dailyMoment);
    Widget card() => _app(
      Scaffold(
        body: TodaysActivityCard(clock: () => day, onBegin: (_) {}),
      ),
    );
    await tester.pumpWidget(card());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Something else'));
    await tester.pumpAndSettle();
    expect(find.text('Look together'), findsOneWidget);

    // A fresh Home later the same day keeps that choice.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(card());
    await tester.pumpAndSettle();
    expect(find.text('Look together'), findsOneWidget);
  });

  testWidgets('never shows counts, streaks or missed days', (tester) async {
    await tester.pumpWidget(
      _app(Scaffold(body: TodaysActivityCard(onBegin: (_) {}))),
    );
    await tester.pumpAndSettle();
    final text = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .join(' ')
        .toLowerCase();
    for (final word in ['streak', 'missed', 'score', 'day 1', 'in a row']) {
      expect(text, isNot(contains(word)));
    }
  });

  group('on Home', () {
    const ios = GmNative(supportedOverride: true);

    testWidgets('keeps one filled button and opens the activity', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(const GentleHomePage(native: ios)));
      await tester.pumpAndSettle();

      expect(find.byType(TodaysActivityCard), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);

      final begin = find.text('Begin');
      await tester.ensureVisible(begin);
      await tester.pumpAndSettle();
      await tester.tap(begin);
      await tester.pumpAndSettle();
      final today = TodaysActivity.forDay(DateTime.now());
      expect(
        find.byType(switch (today) {
          TodaysActivity.dailyMoment => DailyMomentPage,
          TodaysActivity.lookTogether => PhotoTogetherPage,
        }),
        findsOneWidget,
      );

      // Back returns to Home with the card still there.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(TodaysActivityCard), findsOneWidget);
    });

    testWidgets('reads at 200% text on a small phone without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(640, 1136);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _app(const GentleHomePage(native: ios), textScale: 2),
      );
      await tester.pumpAndSettle();
      final another = find.text('Something else');
      await tester.ensureVisible(another);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final size = tester.getSize(
        find.ancestor(of: another, matching: find.byType(TextButton)),
      );
      expect(size.height, greaterThanOrEqualTo(gmTargetMin));
    });
  });
}
