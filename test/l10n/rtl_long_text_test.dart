import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_home_page.dart';
import 'package:golden_moments/features/reminders/presentation/reminder_page.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/shared/native/gm_native.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Layout checks for right-to-left and long translations (GM-036).
///
/// The Arabic runs use the real (machine-made, unreviewed) Arabic text laid
/// out right to left; the test font draws every glyph as a box, so glyph
/// widths are approximate. The German runs use [_LongTextL10n], a test-only
/// stand-in that makes every English word about 40% longer, the usual
/// allowance for German, so a stretched worst case is checked as well as
/// the real German.

const _ios = GmNative(supportedOverride: true);
const _channel = MethodChannel('golden_moments/native');

/// English texts from the ARB, with each word stretched, so a long German
/// compound word is approximated by a long unbreakable word.
class _LongTextL10n implements AppLocalizations {
  new(this._english);

  final Map<String, dynamic> _english;

  static String _stretch(String text) =>
      text.replaceAllMapped(RegExp('[A-Za-z]{4,}'), (m) {
        final word = m.group(0)!;
        return word + word.substring(0, (word.length * 0.4).ceil());
      });

  /// Fills simple ICU placeholders and keeps the `other` branch of a plural.
  String _format(String key, List<Object?> args) {
    var message = _english[key] as String;
    final meta = _english['@$key'] as Map<String, dynamic>;
    final names = (meta['placeholders'] as Map<String, dynamic>? ?? const {})
        .keys
        .toList();
    final plural = RegExp(r'^\{(\w+), plural,.*other\{(.*)\}\}$');
    final match = plural.firstMatch(message);
    if (match != null) message = match.group(2)!;
    for (var i = 0; i < names.length && i < args.length; i++) {
      message = message.replaceAll('{${names[i]}}', '${args[i]}');
    }
    return _stretch(message);
  }

  @override
  String get localeName => 'de';

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Test VM symbols read as Symbol("name").
    final key = RegExp(r'"(\w+)"')
        .firstMatch(invocation.memberName.toString())!
        .group(1)!;
    return _format(key, invocation.positionalArguments);
  }
}

class _LongTextDelegate extends LocalizationsDelegate<AppLocalizations> {
  const new(this.english);

  final Map<String, dynamic> english;

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'de';

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(_LongTextL10n(english));

  @override
  bool shouldReload(_LongTextDelegate old) => false;
}

Widget _app(
  Widget home, {
  required Locale locale,
  required double textScale,
  bool longText = false,
}) => MaterialApp(
  theme: gmBuildTheme(),
  locale: locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: longText
      ? [
          _LongTextDelegate(
            jsonDecode(File('lib/l10n/arb/app_en.arb').readAsStringSync())
                as Map<String, dynamic>,
          ),
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ]
      : AppLocalizations.localizationsDelegates,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: home,
);

final _screens = <String, Widget Function()>{
  'Home': () => const GentleHomePage(native: _ios),
  'gentle game board': () =>
      const GentleGamePage(pictures: ActivityPicture.samples),
  'reminder page': () => const ReminderPage(native: _ios),
};

/// A stretched word each screen shows, proving the long texts are in use.
const _stretched = {
  'Home': 'GoldenGol',
  'gentle game board': 'DoneDo',
  'reminder page': 'GentleGen',
};

final _runs = <String, (Locale, double, bool)>{
  'Arabic at 100% text': (const Locale('ar'), 1, false),
  'Arabic at 200% text': (const Locale('ar'), 2, false),
  'long German at 200% text': (const Locale('de'), 2, true),
};

const _sizes = {'small phone': Size(320, 568), 'phone': Size(390, 844)};

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      // The reminder page shows its longest state: on, with a day list.
      'reminder_enabled': true,
      'reminder_weekdays': ['1', '3', '5', '6'],
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (_) async => null);
  });

  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null),
  );

  for (final screen in _screens.entries) {
    for (final run in _runs.entries) {
      for (final size in _sizes.entries) {
        testWidgets('${screen.key}: ${run.key} on a ${size.key} fits', (
          tester,
        ) async {
          final (locale, textScale, longText) = run.value;
          await tester.binding.setSurfaceSize(size.value);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await tester.pumpWidget(
            _app(
              screen.value(),
              locale: locale,
              textScale: textScale,
              longText: longText,
            ),
          );
          await tester.pumpAndSettle();

          // Any RenderFlex overflow or layout error fails here.
          expect(tester.takeException(), isNull);
          final direction = Directionality.of(
            tester.element(find.byType(Scaffold).first),
          );
          expect(
            direction,
            locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          );
          expect(find.byType(RichText), findsWidgets);
          if (longText) {
            expect(find.textContaining(_stretched[screen.key]!), findsWidgets);
          }
          // Every visible line of text is inside the screen horizontally.
          for (final text in find.byType(RichText).evaluate()) {
            final box = text.renderObject! as RenderBox;
            if (!box.hasSize || !box.attached) continue;
            final rect = box.localToGlobal(Offset.zero) & box.size;
            if (rect.bottom < 0 || rect.top > size.value.height) continue;
            expect(rect.left, greaterThanOrEqualTo(-0.5), reason: '$text');
            expect(
              rect.right,
              lessThanOrEqualTo(size.value.width + 0.5),
              reason: '$text',
            );
          }
        });
      }
    }
  }

  testWidgets('in Arabic, start-aligned controls sit on the right', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _app(
        const ReminderPage(native: _ios),
        locale: const Locale('ar'),
        textScale: 1,
      ),
    );
    await tester.pumpAndSettle();
    final time = tester.getRect(find.byIcon(Icons.schedule));
    expect(time.center.dx, greaterThan(390 / 2));
    // Monday, the first day, starts the first row at the right edge;
    // Tuesday follows to its left, or starts the next row at the same edge.
    final arabic = lookupAppLocalizations(const Locale('ar'));
    Rect chip(String label) => tester.getRect(
      find.ancestor(of: find.text(label), matching: find.byType(FilterChip)),
    );
    final monday = chip(arabic.reminderDayMondayShort);
    final tuesday = chip(arabic.reminderDayTuesdayShort);
    expect(monday.center.dx, greaterThan(390 / 2));
    expect(monday.right, greaterThanOrEqualTo(tuesday.right - 0.5));
    if (tuesday.top < monday.bottom) {
      expect(tuesday.right, lessThan(monday.left + 0.5));
    }
  });

  testWidgets('long German text really is longer', (tester) async {
    await tester.pumpWidget(
      _app(
        Builder(builder: (context) => Text(context.l10n.homeStartGentleGame)),
        locale: const Locale('de'),
        textScale: 1,
        longText: true,
      ),
    );
    final shown = tester.widget<Text>(find.byType(Text)).data!;
    expect(shown.length, greaterThan('Start a gentle game'.length));
    expect(shown, startsWith('StartSt a gentlegen'));
  });
}
