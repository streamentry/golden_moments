import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_home_page.dart';
import 'package:golden_moments/features/reminders/data/reminder_settings.dart';
import 'package:golden_moments/features/reminders/presentation/reminder_page.dart';
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
  final calls = <MethodCall>[];

  Future<Object?> handle(MethodCall call) async {
    calls.add(call);
    return switch (call.method) {
      'reminderPermission' => permission,
      'requestReminderPermission' => permission = answer,
      'scheduleReminders' => scheduleWorks,
      _ => null,
    };
  }

  List<String> get methods => calls.map((c) => c.method).toList();
}

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
      _app(const ReminderPage(native: _ios), textScale: textScale),
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
      'scheduleReminders',
    ]);
    final args = ios.calls.last.arguments as Map<Object?, Object?>;
    expect(args['weekdays'], [1, 2, 3, 4, 5, 6, 7]);
    expect(args['hour'], 10);
    expect(args['title'], englishL10n.reminderNotificationTitle);
    expect(args['body'], englishL10n.reminderNotificationBody);
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
    expect(ios.methods, isNot(contains('scheduleReminders')));
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
    final args = ios.calls.last.arguments as Map<Object?, Object?>;
    expect(args['weekdays'], [3]);
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
    await tester.pumpWidget(_app(const GentleHomePage(native: _ios)));
    await tester.pumpAndSettle();
    expect(find.text('Gentle reminder'), findsOneWidget);
    await tester.pumpWidget(
      _app(
        const GentleHomePage(
          native: GmNative(supportedOverride: false),
          key: ValueKey(2),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Gentle reminder'), findsNothing);
  });
}
