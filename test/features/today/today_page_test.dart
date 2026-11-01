import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/today/data/today_notes.dart';
import 'package:golden_moments/features/today/presentation/today_page.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Shared {
  String? text;
  String? subject;

  Future<void> call(String text, String subject) async {
    this.text = text;
    this.subject = subject;
  }
}

Widget _app(Widget home, {double textScale = 1}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: gmBuildTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: home,
);

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Tall enough that the lazily built list shows the notes too.
void _tallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('choosing a moment shows three tries, help and an activity', (
    tester,
  ) async {
    _tallScreen(tester);
    await tester.pumpWidget(_app(const TodayPage()));
    await tester.pumpAndSettle();
    expect(find.text('Try one of these'), findsNothing);

    await _tap(tester, find.text('They keep asking to go home'));
    expect(find.text('Try one of these'), findsOneWidget);
    expect(find.textContaining('Answer the feeling'), findsOneWidget);
    expect(
      find.textContaining('call their doctor', findRichText: true),
      findsNothing,
    );
    expect(
      find.textContaining('Call their doctor', findRichText: true),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Look together'), findsOneWidget);
  });

  testWidgets('the caregiver moment has a crisis line and no activity', (
    tester,
  ) async {
    _tallScreen(tester);
    await tester.pumpWidget(_app(const TodayPage()));
    await tester.pumpAndSettle();
    await _tap(tester, find.text('I’m worn out'));
    expect(find.textContaining('988', findRichText: true), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('one tap saves a note on the device, and it can be shared', (
    tester,
  ) async {
    _tallScreen(tester);
    final shared = _Shared();
    await tester.pumpWidget(
      _app(
        TodayPage(share: shared.call, clock: () => DateTime(2026, 11, 1, 16)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Nothing yet'), findsOneWidget);

    await _tap(tester, find.text('Late afternoons are restless'));
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Lights on early');
    await _tap(tester, find.widgetWithText(OutlinedButton, 'That helped'));

    expect(find.text('Saved in your notes below.'), findsOneWidget);
    expect(
      find.text('Late afternoons are restless: That helped. Lights on early'),
      findsOneWidget,
    );
    final saved = await const TodayNotesStore().load();
    expect(saved.single.situation, Situation.lateDay);
    expect(saved.single.outcome, Outcome.helped);
    expect(saved.single.day, '2026-11-01');

    await _tap(tester, find.text('Share notes for an appointment'));
    expect(shared.subject, 'Notes to bring to an appointment');
    expect(shared.text, contains('not a medical record'));
    expect(
      shared.text,
      contains('- Late afternoons are restless: That helped'),
    );

    await _tap(tester, find.widgetWithText(TextButton, 'Remove'));
    expect(await const TodayNotesStore().load(), isEmpty);
    expect(find.textContaining('Nothing yet'), findsOneWidget);
  });

  testWidgets('saved notes come back after reopening', (tester) async {
    _tallScreen(tester);
    await const TodayNotesStore().save([
      const TodayNote(
        id: 'x',
        day: '2026-10-30',
        situation: Situation.visit,
        outcome: Outcome.notTried,
      ),
    ]);
    await tester.pumpWidget(_app(const TodayPage()));
    await tester.pumpAndSettle();
    expect(
      find.text('A visit or call is coming up: Didn’t try it'),
      findsOneWidget,
    );
  });

  testWidgets('works at 200% text without overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const TodayPage(), textScale: 2));
    await tester.pumpAndSettle();
    // The intro alone can fill a phone screen at this size.
    final first = find.text('They keep asking to go home');
    await tester.scrollUntilVisible(
      first,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Done for now'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('every control is at least 48 by 48', (tester) async {
    _tallScreen(tester);
    await tester.pumpWidget(_app(const TodayPage()));
    await tester.pumpAndSettle();
    await _tap(tester, find.text('Talking together is hard'));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });
}
