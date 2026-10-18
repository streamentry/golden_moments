import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_home_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/help_privacy_page.dart';
import 'package:golden_moments/shared/utils/support_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Recorder {
  final calls = <(String, String)>[];
  ShareOutcome result = ShareOutcome.shared;
  Future<ShareOutcome> call(String text, String subject) async {
    calls.add((text, subject));
    return result;
  }
}

Widget _app(Widget home, {double textScale = 1}) => MaterialApp(
  theme: gmBuildTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: home,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('help is reachable from Home and works offline', (tester) async {
    await tester.binding.setSurfaceSize(const Size(480, 4000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(const GentleHomePage()));
    await tester.tap(find.byTooltip('Guide and privacy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('More help and privacy'));
    await tester.pumpAndSettle();
    expect(find.text('Help and privacy'), findsOneWidget);
    expect(find.text('This page works without internet.'), findsOneWidget);
    expect(find.textContaining('originals are never changed'), findsOneWidget);
    expect(find.text('Version $appVersion'), findsOneWidget);
    // A copyable support page, never opened by the app.
    expect(find.text(supportUrl), findsOneWidget);
    expect(find.text(privacyPolicyUrl), findsOneWidget);
    expect(find.text(termsUrl), findsOneWidget);
    expect(find.text(supportEmail), findsOneWidget);
    await tester.tap(find.text('Done for now'));
    await tester.pumpAndSettle();
    expect(find.text('Start a gentle game'), findsOneWidget);
  });

  testWidgets('a problem report shares exactly what was previewed', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(480, 4000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final recorder = _Recorder();
    await tester.pumpWidget(_app(HelpPrivacyPage(sharer: recorder.call)));
    await tester.tap(find.text('Report a problem'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Photos would not add'));
    await tester.pumpAndSettle();
    final preview = diagnosticSummary(ProblemKind.photosNotAdded);
    expect(find.text(preview), findsOneWidget);
    expect(recorder.calls, isEmpty); // nothing is sent before choosing
    await tester.tap(find.text('Choose where to send'));
    await tester.pumpAndSettle();
    expect(recorder.calls.single.$1, preview);
    expect(find.text('Thank you. Nothing else was sent.'), findsOneWidget);
  });

  testWidgets('cancelling sends nothing and changes nothing', (tester) async {
    await tester.binding.setSurfaceSize(const Size(480, 4000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final recorder = _Recorder();
    await tester.pumpWidget(_app(HelpPrivacyPage(sharer: recorder.call)));
    await tester.tap(find.text('Report a problem'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Write a note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(recorder.calls, isEmpty);
    expect(find.textContaining('Thank you'), findsNothing);
  });

  testWidgets('a note is previewed live and needs text before sending', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(480, 4000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final recorder = _Recorder();
    await tester.pumpWidget(_app(HelpPrivacyPage(sharer: recorder.call)));
    await tester.tap(find.text('Write a note'));
    await tester.pumpAndSettle();
    final send = find.widgetWithText(FilledButton, 'Choose where to send');
    expect(tester.widget<FilledButton>(send).onPressed, isNull);
    await tester.enterText(find.byType(TextField), '  Easy to use.  ');
    await tester.pump();
    expect(find.text(feedbackMessage('  Easy to use.  ')), findsOneWidget);
    await tester.tap(send);
    await tester.pumpAndSettle();
    expect(recorder.calls.single.$1, feedbackMessage('  Easy to use.  '));
  });

  testWidgets('a failed share says nothing was sent and offers a retry', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(480, 4000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final recorder = _Recorder()..result = ShareOutcome.dismissed;
    await tester.pumpWidget(_app(HelpPrivacyPage(sharer: recorder.call)));
    await tester.tap(find.text('Report a problem'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose where to send'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nothing was sent'), findsOneWidget);
    expect(find.textContaining('copy the text'), findsNothing);
    // The buttons are still there to try again.
    expect(find.text('Report a problem'), findsOneWidget);
  });

  testWidgets('an unknown share result never claims nothing was sent', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(480, 4000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final recorder = _Recorder()..result = ShareOutcome.unknown;
    await tester.pumpWidget(_app(HelpPrivacyPage(sharer: recorder.call)));
    await tester.tap(find.text('Report a problem'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose where to send'));
    await tester.pumpAndSettle();
    expect(find.textContaining('If you sent it, thank you'), findsOneWidget);
    expect(find.textContaining('Nothing was sent'), findsNothing);
  });

  testWidgets('no review or rating is requested anywhere on this page', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(480, 4000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(const HelpPrivacyPage()));
    expect(
      find.textContaining(
        RegExp(r'\brate\b|review us|rating|stars', caseSensitive: false),
      ),
      findsNothing,
    );
  });

  testWidgets('reads and scrolls at 200% text on a small phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final recorder = _Recorder();
    await tester.pumpWidget(
      _app(HelpPrivacyPage(sharer: recorder.call), textScale: 2),
    );
    expect(tester.takeException(), isNull);
    final report = find.text('Report a problem');
    for (var i = 0; i < 80 && report.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();
    }
    await tester.ensureVisible(report);
    await tester.pump();
    await tester.tap(report);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Choose where to send'), findsOneWidget);
  });
}
