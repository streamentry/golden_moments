import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_home_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/help_privacy_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_together_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_puzzle_page.dart';
import 'package:golden_moments/features/legal/presentation/legal_info_page.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Reads `colors:` from the DESIGN.md front matter (the normative tokens).
Map<String, Color> _designColors() {
  final text = File('DESIGN.md').readAsStringSync();
  final front = text.split(RegExp(r'^---\s*$', multiLine: true))[1];
  final block = RegExp(
    r'^colors:\n((?:  .+\n)+)',
    multiLine: true,
  ).firstMatch(front)!.group(1)!;
  return {
    for (final m in RegExp(
      '^  ([a-z-]+): "#([0-9A-Fa-f]{6})"',
      multiLine: true,
    ).allMatches(block))
      m.group(1)!: Color(int.parse('FF${m.group(2)}', radix: 16)),
  };
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
  // No saved board or comfort choice may leak into a layout check.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final theme = gmBuildTheme();
  final scheme = theme.colorScheme;

  group('DESIGN.md tokens', () {
    test('match the Flutter implementation', () {
      final tokens = _designColors();
      final expected = <String, Color>{
        'primary': gmGold800,
        'primary-deep': gmGold700,
        'on-primary': Colors.white,
        'primary-container': gmGold300,
        'on-primary-container': gmCharcoal900,
        'accent': gmGold600,
        'accent-pale': gmGold200,
        'accent-deep': gmGold400,
        'secondary': gmSapphire500,
        'on-secondary': Colors.white,
        'on-success': Colors.white,
        'on-warning': Colors.white,
        'on-error': Colors.white,
        'secondary-container': gmSapphire50,
        'secondary-outline': gmSapphire100,
        'background': gmSurf50,
        'surface': gmSurf100,
        'surface-raised': gmSurfRaised,
        'surface-sunken': gmSurf200,
        'on-surface': gmCharcoal900,
        'on-surface-variant': gmWalnut600,
        'outline': gmDriftwood500,
        'on-ink': gmOnInk,
        'on-ink-variant': gmOnInkVariant,
        'on-ink-link': gmOnInkLink,
        'shadow-ink': gmUmber900,
        'success': gmGreen600,
        'warning': gmOrange600,
        'error': gmBrick500,
      };
      for (final entry in expected.entries) {
        expect(
          tokens[entry.key]?.toARGB32(),
          entry.value.toARGB32(),
          reason: 'colors.${entry.key} drifted from lib/design_system.dart',
        );
      }
      // Every token in DESIGN.md has a Dart constant, and the other way round.
      expect(tokens.keys.toSet(), expected.keys.toSet());
      expect(scheme.primary, gmGold800);
      expect(scheme.outline, gmDriftwood500);
      expect(theme.scaffoldBackgroundColor, gmSurf50);
    });

    test('headlines are Fraunces and reading text is Roboto', () {
      final styles = theme.textTheme;
      for (final style in [
        styles.displayLarge,
        styles.headlineLarge,
        styles.headlineMedium,
        styles.headlineSmall,
        styles.titleLarge,
      ]) {
        expect(style?.fontFamily, gmDisplayFontFamily);
        expect(style?.fontFamilyFallback, contains(gmFontFamily));
        // Fraunces is never smaller than 24 (DESIGN.md › Typography).
        expect(style?.fontSize, greaterThanOrEqualTo(24));
        expect(style?.letterSpacing, 0);
      }
      for (final style in [
        styles.titleMedium,
        styles.titleSmall,
        styles.bodyLarge,
        styles.bodyMedium,
        styles.bodySmall,
        styles.labelLarge,
        styles.labelMedium,
        styles.labelSmall,
      ]) {
        expect(style?.fontFamily, gmFontFamily);
      }
      expect(theme.appBarTheme.titleTextStyle?.fontFamily, gmDisplayFontFamily);
      expect(theme.dialogTheme.titleTextStyle?.fontFamily, gmDisplayFontFamily);
      // Buttons and chips are read, so they stay in Roboto.
      expect(
        theme.filledButtonTheme.style?.textStyle?.resolve({})?.fontFamily,
        gmFontFamily,
      );
      expect(theme.chipTheme.labelStyle?.fontFamily, gmFontFamily);
    });

    test('both bundled families are declared with their licenses', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('family: $gmFontFamily'));
      expect(pubspec, contains('family: $gmDisplayFontFamily'));
      expect(pubspec, contains('assets/fonts/Fraunces_LICENSE.txt'));
      expect(File('assets/fonts/Fraunces-Bold.ttf').existsSync(), isTrue);
      expect(File('assets/fonts/Fraunces_LICENSE.txt').existsSync(), isTrue);
    });

    test('shadows are warm umber, never grey', () {
      expect(theme.dialogTheme.shadowColor, gmUmber900);
      expect(theme.bottomSheetTheme.shadowColor, gmUmber900);
      expect(theme.cardTheme.shadowColor, gmUmber900);
    });
  });

  group('contrast (WCAG 2.2)', () {
    final text = <String, (Color, Color)>{
      'button label on primary': (scheme.onPrimary, scheme.primary),
      'primary text on background': (scheme.primary, gmSurf50),
      'primary text on surface': (scheme.primary, scheme.surface),
      'ink on background': (scheme.onSurface, gmSurf50),
      'secondary text on surface': (scheme.onSurfaceVariant, scheme.surface),
      'selected chip text': (
        scheme.onPrimaryContainer,
        scheme.primaryContainer,
      ),
      'error text on background': (scheme.error, gmSurf50),
      'white on success': (Colors.white, gmGreen600),
      'white on warning': (Colors.white, gmOrange600),
      'white on error': (scheme.onError, scheme.error),
      'snackbar': (scheme.onInverseSurface, scheme.inverseSurface),
      'white on pressed primary': (Colors.white, gmGold700),
      'ink on print white': (scheme.onSurface, gmSurfRaised),
      'primary on print white': (scheme.primary, gmSurfRaised),
      'secondary text on print white': (scheme.onSurfaceVariant, gmSurfRaised),
      'secondary on notice fill': (gmSapphire500, gmSapphire50),
      'ink on notice fill': (scheme.onSurface, gmSapphire50),
      'parchment on ink': (gmOnInk, gmCharcoal900),
      'fine print on ink': (gmOnInkVariant, gmCharcoal900),
      'links on ink': (gmOnInkLink, gmCharcoal900),
    };
    for (final entry in text.entries) {
      test('${entry.key} is at least 4.5:1', () {
        final (fg, bg) = entry.value;
        expect(_contrast(fg, bg), greaterThanOrEqualTo(4.5));
      });
    }

    test('body text reaches AAA 7:1', () {
      expect(_contrast(scheme.onSurface, scheme.surface), greaterThan(7));
    });

    test('tile and selection outlines are at least 3:1', () {
      expect(_contrast(scheme.outline, scheme.surface), greaterThan(3));
      expect(_contrast(scheme.outline, gmSurf50), greaterThan(3));
      expect(_contrast(scheme.primary, scheme.surface), greaterThan(3));
    });

    test('bright gold stays decorative', () {
      // The reason accent may never carry text or be the only outline.
      expect(_contrast(gmGold600, gmSurf50), lessThan(3));
      expect(_contrast(gmGold200, gmSurf50), lessThan(3));
      expect(_contrast(gmGold400, gmSurf50), lessThan(3));
      expect(scheme.primary, isNot(gmGold600));
    });

    test('the print mat keeps its hairline and picture readable', () {
      // The mat is the one step up from the page: its hairline must still
      // read against it, and a resting tile border against the mat.
      expect(_contrast(scheme.outline, gmSurfRaised), greaterThan(3));
      expect(_contrast(gmSurfRaised, gmSurf100), lessThan(1.2));
    });
  });

  test('no text role is smaller than 16', () {
    final styles = theme.textTheme;
    for (final style in [
      styles.displayLarge,
      styles.displayMedium,
      styles.displaySmall,
      styles.headlineLarge,
      styles.headlineMedium,
      styles.headlineSmall,
      styles.titleLarge,
      styles.titleMedium,
      styles.titleSmall,
      styles.bodyLarge,
      styles.bodyMedium,
      styles.bodySmall,
      styles.labelLarge,
      styles.labelMedium,
      styles.labelSmall,
    ]) {
      expect(style?.fontSize, greaterThanOrEqualTo(16));
    }
    expect(styles.bodyLarge?.fontSize, 20);
    expect(styles.labelLarge?.fontSize, 20);
  });

  test('buttons are at least 56 tall', () {
    final states = <WidgetState>{};
    for (final style in [
      theme.filledButtonTheme.style,
      theme.outlinedButtonTheme.style,
      theme.textButtonTheme.style,
    ]) {
      expect(
        style?.minimumSize?.resolve(states)?.height,
        greaterThanOrEqualTo(gmTargetPrimary),
      );
    }
  });

  group('screens meet accessibility guidelines', () {
    final screens = <String, Widget>{
      'home': const GentleHomePage(),
      'gentle game': const GentleGamePage(pictures: ActivityPicture.samples),
      'look together': const PhotoTogetherPage(
        pictures: ActivityPicture.samples,
      ),
      'help and privacy': const HelpPrivacyPage(),
      'privacy and information': const LegalInfoPage(),
      'picture puzzle': const PicturePuzzlePage(
        pictures: ActivityPicture.samples,
      ),
    };

    // Where choices are made: the comfort sheet and a confirmation.
    Future<void> expectGuidelines(WidgetTester tester) async {
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }

    // Long pages, tall enough that the copyable address and links at the end
    // are on screen and checked too.
    for (final (name, page) in [
      ('help and privacy', const HelpPrivacyPage()),
      ('privacy and information', const LegalInfoPage()),
    ]) {
      testWidgets('$name, whole page: every target is big enough', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        // The guideline skips anything outside the view's physical size, so
        // size the view itself (a test surface size would not count).
        tester.view
          ..devicePixelRatio = 3
          ..physicalSize = const Size(1024, 3000) * 3;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_app(page));
        await tester.pumpAndSettle();
        expect(find.byType(SelectableText).hitTestable(), findsWidgets);
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        handle.dispose();
        // On iOS copyable text answers a long press, so it is a target too.
      }, variant: TargetPlatformVariant.mobile());
    }

    testWidgets('comfort sheet: tap targets, labels and contrast', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(const GentleHomePage()));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Comfort settings'));
      await tester.pumpAndSettle();
      await expectGuidelines(tester);
      handle.dispose();
    });

    testWidgets('Start again confirmation: tap targets, labels and contrast', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(const GentleGamePage(pictures: ActivityPicture.samples)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel(RegExp(r', tile 1$')).first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Start again'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await expectGuidelines(tester);
      handle.dispose();
    });
    for (final entry in screens.entries) {
      testWidgets('${entry.key}: tap targets, labels and contrast', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_app(entry.value));
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });

      for (final size in const [Size(320, 568), Size(844, 390)]) {
        testWidgets('${entry.key}: 200% text at $size', (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await tester.pumpWidget(_app(entry.value, textScale: 2));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('light only (no dark mode)', () {
    test('the only theme is light', () {
      expect(theme.brightness, Brightness.light);
      expect(scheme.brightness, Brightness.light);
    });

    testWidgets('a device in dark mode still gets the light app', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      late Brightness seen;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: gmBuildTheme(),
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (context) {
              seen = Theme.of(context).brightness;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(seen, Brightness.light);
    });

    test('native shells cannot switch to dark', () {
      final res = Directory('android/app/src/main/res');
      expect(
        res
            .listSync()
            .map((entry) => entry.path)
            .where((path) => path.contains('-night')),
        isEmpty,
        reason: 'night resources let Android (and MIUI) draw dark windows',
      );
      for (final styles in [
        'android/app/src/main/res/values/styles.xml',
        'android/app/src/main/res/values-v31/styles.xml',
      ]) {
        expect(
          RegExp('forceDarkAllowed">false')
              .allMatches(File(styles).readAsStringSync())
              .length,
          2,
          reason: '$styles must block forced dark on both themes',
        );
      }
      expect(
        File('ios/Runner/Info.plist').readAsStringSync(),
        matches(RegExp(r'UIUserInterfaceStyle</key>\s*<string>Light')),
      );
      expect(
        File('web/index.html').readAsStringSync(),
        contains('content="only light"'),
      );
    });
  });

  group('gmBoardColumns', () {
    test('uses the largest tiles that fit the whole board', () {
      // 12 tiles on a phone board: 3 columns of ~111px fit without scrolling.
      expect(
        gmBoardColumns(
          tileCount: 12,
          maxColumns: 3,
          size: const Size(358, 680),
        ),
        3,
      );
      // 16 tiles need 4 columns to fit, still above the 64px floor.
      expect(
        gmBoardColumns(
          tileCount: 16,
          maxColumns: 4,
          size: const Size(358, 680),
        ),
        4,
      );
      // A tablet fits a 4-tile board in 2 large columns.
      expect(
        gmBoardColumns(tileCount: 4, maxColumns: 3, size: const Size(700, 900)),
        2,
      );
    });

    test('full rows win when their tiles are at least as large', () {
      // A small phone at 200% text: 3 columns of 83-point tiles fit, but
      // 2 x 2 gives 94-point tiles there, and 3 + 1 would leave a tile
      // alone on a row.
      expect(
        gmBoardColumns(tileCount: 4, maxColumns: 4, size: const Size(272, 200)),
        2,
      );
      // Too short for either: both give the same tiles, so 2 x 2.
      expect(
        gmBoardColumns(tileCount: 4, maxColumns: 4, size: const Size(272, 168)),
        2,
      );
      // Full rows with smaller tiles do not win: 16 tiles stay in 4 columns.
      expect(
        gmBoardColumns(
          tileCount: 16,
          maxColumns: 4,
          size: const Size(358, 680),
        ),
        4,
      );
    });

    test('never shrinks tiles below the minimum; scrolls instead', () {
      final columns = gmBoardColumns(
        tileCount: 40,
        maxColumns: 5,
        size: const Size(358, 680),
      );
      final tile = (358 - (columns - 1) * gmTileGap) / columns;
      expect(tile, greaterThanOrEqualTo(gmTileMin));
    });
  });

  testWidgets('a matched tile shows a check badge, not color alone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _app(const GentleGamePage(pictures: ActivityPicture.samples)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(GmMatchBadge), findsNothing);

    // Tap every pair of tiles until two match; visible mode shows labels.
    final tiles = find.bySemanticsLabel(RegExp(r', tile \d+$'));
    final labels = <String, int>{};
    for (var i = 0; i < tester.widgetList(tiles).length; i++) {
      final label = tester
          .getSemantics(tiles.at(i))
          .label
          .split(', tile')
          .first;
      final first = labels[label];
      if (first != null) {
        for (final index in [first, i]) {
          await tester.ensureVisible(tiles.at(index));
          await tester.tap(tiles.at(index));
          await tester.pump();
        }
        break;
      }
      labels[label] = i;
    }
    await tester.pumpAndSettle();
    expect(find.byType(GmMatchBadge), findsNWidgets(2));
  });
}
