import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_home_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_together_page.dart';
import 'package:golden_moments/features/reminders/data/reminder_settings.dart';
import 'package:golden_moments/features/reminders/presentation/reminder_page.dart';
import 'package:golden_moments/features/wellbeing/presentation/daily_moment_page.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/shared/native/gm_native.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/l10n_helpers.dart';

const _channel = MethodChannel('golden_moments/native');
const _ios = GmNative(supportedOverride: true);

/// Stands in for the iOS side of the channel.
class _FakeIos {
  String permission = 'notDetermined';
  String answer = 'granted';
  bool scheduleWorks = true;
  bool tapped = false;
  final calls = <MethodCall>[];

  Future<Object?> handle(MethodCall call) async {
    calls.add(call);
    return switch (call.method) {
      'reminderPermission' => permission,
      'requestReminderPermission' => permission = answer,
      'scheduleDatedReminders' => scheduleWorks,
      'takeReminderTap' => _take(),
      _ => null,
    };
  }

  bool _take() {
    final was = tapped;
    tapped = false;
    return was;
  }

  List<String> get methods => calls.map((c) => c.method).toList();

  /// The reminders in the last scheduling call.
  List<Map<Object?, Object?>> get lastReminders =>
      ((calls.last.arguments as Map<Object?, Object?>)['reminders']!
              as List<Object?>)
          .cast<Map<Object?, Object?>>();
}

/// Saturday 7 November 2026, 9 am: reminders are planned from here.
DateTime _now() => DateTime(2026, 11, 7, 9);

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

void main() {
  late _FakeIos ios;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ios = _FakeIos();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, ios.handle);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  Future<void> show(WidgetTester tester, {double textScale = 1}) async {
    await tester.binding.setSurfaceSize(const Size(480, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _app(
        const ReminderPage(native: _ios, clock: _now),
        textScale: textScale,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('is off until turned on, and asks permission only then', (
    tester,
  ) async {
    await show(tester);
    expect(find.text('Turn on reminder'), findsOneWidget);
    expect(ios.methods, isEmpty);
    await tester.tap(find.text('Turn on reminder'));
    await tester.pumpAndSettle();
    expect(ios.methods, [
      'reminderPermission',
      'requestReminderPermission',
      'scheduleDatedReminders',
    ]);
    // Dated reminders from tomorrow, at the chosen time, each with its words.
    final reminders = ios.lastReminders;
    expect(reminders.first, containsPair('day', 8));
    expect(reminders.first, containsPair('month', 11));
    expect(reminders.every((r) => r['hour'] == 10 && r['minute'] == 0), isTrue);
    expect(reminders.first['title'], startsWith('This morning: '));
    expect(reminders.map((r) => r['body']).toSet().length, greaterThan(1));
    expect(find.text(englishL10n.reminderHowItWorks), findsOneWidget);
    expect(find.textContaining('Reminder is on: Every day'), findsOneWidget);
    expect((await const ReminderSettingsStore().load()).enabled, isTrue);
  });

  testWidgets('a refused permission changes nothing and says where to go', (
    tester,
  ) async {
    ios.answer = 'denied';
    await show(tester);
    await tester.tap(find.text('Turn on reminder'));
    await tester.pumpAndSettle();
    expect(ios.methods, isNot(contains('scheduleDatedReminders')));
    expect(find.textContaining('Settings app'), findsOneWidget);
    expect((await const ReminderSettingsStore().load()).enabled, isFalse);
  });

  testWidgets('a reminder that cannot be set is not saved as on', (
    tester,
  ) async {
    ios
      ..permission = 'granted'
      ..scheduleWorks = false;
    await show(tester);
    await tester.tap(find.text('Turn on reminder'));
    await tester.pumpAndSettle();
    expect(find.textContaining('could not be set'), findsOneWidget);
    expect(find.text('Turn on reminder'), findsOneWidget);
    expect((await const ReminderSettingsStore().load()).enabled, isFalse);
  });

  testWidgets('changing days reschedules; the last day stays chosen', (
    tester,
  ) async {
    ios.permission = 'granted';
    await const ReminderSettingsStore().save(
      const ReminderSettings(enabled: true, weekdays: {1, 3}),
    );
    await show(tester);
    await tester.tap(find.bySemanticsLabel('Monday'));
    await tester.pumpAndSettle();
    // Only Wednesdays now (11 November 2026 is the first).
    expect(ios.lastReminders.first, containsPair('day', 11));
    for (final r in ios.lastReminders) {
      final at = DateTime(
        r['year']! as int,
        r['month']! as int,
        r['day']! as int,
      );
      expect(at.weekday, DateTime.wednesday);
    }
    ios.calls.clear();
    await tester.tap(find.bySemanticsLabel('Wednesday'));
    await tester.pumpAndSettle();
    expect(ios.calls, isEmpty);
    expect((await const ReminderSettingsStore().load()).weekdays, {3});
  });

  testWidgets('turning off cancels and remembers it', (tester) async {
    await const ReminderSettingsStore().save(
      const ReminderSettings(enabled: true),
    );
    await show(tester);
    await tester.tap(find.text('Turn off reminder'));
    await tester.pumpAndSettle();
    expect(ios.methods, contains('cancelReminders'));
    expect(find.text('Turn on reminder'), findsOneWidget);
    expect((await const ReminderSettingsStore().load()).enabled, isFalse);
  });

  testWidgets('never mentions streaks, missed days or counts', (tester) async {
    await show(tester);
    expect(
      find.textContaining(
        RegExp('streak|in a row|you missed|days played', caseSensitive: false),
      ),
      findsNothing,
    );
    expect(englishL10n.reminderNotificationTitle, isNot(contains('!')));
    expect(englishL10n.reminderNotificationBody, isNot(contains('!')));
  });

  testWidgets('reads at 200% text on a small phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _app(const ReminderPage(native: _ios), textScale: 2),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Turn on reminder'), 200);
    expect(find.text('Turn on reminder'), findsOneWidget);
  });

  testWidgets('damaged stored values fall back to safe defaults', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'reminder_hour': 99,
      'reminder_minute': -4,
      'reminder_weekdays': ['0', 'x', '9'],
    });
    final loaded = await const ReminderSettingsStore().load();
    expect(loaded, const ReminderSettings());
  });

  testWidgets('Home offers the reminder on iOS only', (tester) async {
    await tester.binding.setSurfaceSize(const Size(480, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    // The reminder is offered from the Home menu, and only where supported.
    await tester.pumpWidget(_app(const GentleHomePage(native: _ios)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Gentle reminder'), findsOneWidget);
    // A fresh tree, so the menu opened above does not carry over.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _app(
        const GentleHomePage(
          native: GmNative(supportedOverride: false),
          key: ValueKey(2),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Gentle reminder'), findsNothing);
  });

  group('when the app opens', () {
    Future<void> home(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(const GentleHomePage(native: _ios)));
      await tester.pumpAndSettle();
    }

    testWidgets('plans reminders afresh, none for today', (tester) async {
      ios.permission = 'granted';
      await const ReminderSettingsStore().save(
        const ReminderSettings(enabled: true),
      );
      await home(tester);
      expect(ios.methods, contains('scheduleDatedReminders'));
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      for (final r in ios.lastReminders) {
        final day = DateTime(
          r['year']! as int,
          r['month']! as int,
          r['day']! as int,
        );
        expect(day.isAfter(today), isTrue, reason: '$day');
      }
    });

    testWidgets('never asks for permission or schedules while off', (
      tester,
    ) async {
      await home(tester);
      expect(ios.methods, isNot(contains('requestReminderPermission')));
      expect(ios.methods, isNot(contains('scheduleDatedReminders')));
    });

    testWidgets("a reminder that opened the app opens today's activity", (
      tester,
    ) async {
      ios.tapped = true;
      await home(tester);
      expect(
        find.byWidgetPredicate(
          (w) => w is DailyMomentPage || w is PhotoTogetherPage,
        ),
        findsOneWidget,
      );
      // Back to Home, and the tap is not replayed.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(GentleHomePage), findsOneWidget);
      expect(find.byType(DailyMomentPage), findsNothing);
    });

    testWidgets('a reminder tapped while the app runs opens it once, and '
        'never on top of something else', (tester) async {
      await home(tester);
      Future<void> tapEvent() async {
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              _channel.name,
              _channel.codec.encodeMethodCall(
                const MethodCall('reminderTapped'),
              ),
              (_) {},
            );
        await tester.pumpAndSettle();
      }

      ios.tapped = true;
      await tapEvent();
      final activity = find.byWidgetPredicate(
        (w) => w is DailyMomentPage || w is PhotoTogetherPage,
      );
      expect(activity, findsOneWidget);
      // Already in an activity: a second tap opens nothing more.
      ios.tapped = true;
      await tapEvent();
      expect(activity, findsOneWidget);
    });
  });
}
