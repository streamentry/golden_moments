import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_game_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/gentle_home_page.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_puzzle_page.dart';
import 'package:golden_moments/shared/widgets/gm_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home, {double textScale = 1}) => MaterialApp(
  theme: gmBuildTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: home,
);

Future<void> _size(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// True when [label] is laid out on a single line.
bool _oneLine(WidgetTester tester, Finder label) {
  final paragraph = tester.renderObject<RenderParagraph>(
    find.descendant(of: label, matching: find.byType(RichText)).first,
  );
  final lines = paragraph.getBoxesForSelection(
    TextSelection(
      baseOffset: 0,
      extentOffset: paragraph.text.toPlainText().length,
    ),
  );
  final tops = {for (final box in lines) box.top.round()};
  return tops.length == 1;
}

/// Finds every pair. With [settleLast] false the last tap only renders the
/// next frames without letting time pass, so animations have not run.
Future<void> _finishBoard(WidgetTester tester, {bool settleLast = true}) async {
  final tiles = find.bySemanticsLabel(RegExp(r', tile \d+$'));
  final byPicture = <String, List<int>>{};
  for (var i = 0; i < tiles.evaluate().length; i++) {
    final label = tester.getSemantics(tiles.at(i)).label.split(', tile').first;
    byPicture.putIfAbsent(label, () => []).add(i + 1);
  }
  final positions = [for (final pair in byPicture.values) ...pair];
  for (final position in positions) {
    final tile = find.bySemanticsLabel(RegExp(', tile $position\$'));
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    if (settleLast || position != positions.last) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump();
    }
  }
}

Future<void> _openComfort(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Comfort settings'));
  await tester.pumpAndSettle();
}

List<Rect> _chipRects(WidgetTester tester) => [
  for (final label in ['4 tiles', '6 tiles', '8 tiles', '12 tiles'])
    tester.getRect(find.widgetWithText(ChoiceChip, label)),
];

/// The shipped Roboto, so label widths are real rather than the test font's.
Future<void> _loadRoboto() async {
  final loader = FontLoader(gmFontFamily);
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    loader.addFont(rootBundle.load('assets/fonts/Roboto-$weight.ttf'));
  }
  await loader.load();
}

void main() {
  setUpAll(_loadRoboto);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('comfort tile choices', () {
    for (final (name, size, scale) in [
      ('small phone', const Size(320, 640), 1.0),
      ('phone', const Size(390, 844), 1.0),
      ('phone at 200%', const Size(390, 844), 2.0),
      ('small phone at 200%', const Size(320, 640), 2.0),
      ('tablet', const Size(1024, 1366), 1.0),
    ]) {
      testWidgets('$name: equal widths, full rows, labels on one line', (
        tester,
      ) async {
        await _size(tester, size);
        await tester.pumpWidget(_app(const GentleHomePage(), textScale: scale));
        await tester.pumpAndSettle();
        await _openComfort(tester);
        final rects = _chipRects(tester);
        final rows = <int, List<Rect>>{};
        for (final rect in rects) {
          rows.putIfAbsent(rect.top.round(), () => []).add(rect);
        }
        // Every row holds the same number of choices: none is left alone.
        expect(rows.values.map((row) => row.length).toSet(), hasLength(1));
        for (final rect in rects) {
          expect(rect.width, closeTo(rects.first.width, 0.5));
          expect(rect.height, greaterThanOrEqualTo(gmTargetMin));
        }
        for (final label in ['4 tiles', '6 tiles', '8 tiles', '12 tiles']) {
          expect(_oneLine(tester, find.text(label)), isTrue, reason: label);
        }
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('a phone shows two rows of two, a tablet one row', (
      tester,
    ) async {
      await _size(tester, const Size(390, 844));
      await tester.pumpWidget(_app(const GentleHomePage()));
      await tester.pumpAndSettle();
      await _openComfort(tester);
      var tops = {for (final r in _chipRects(tester)) r.top.round()};
      expect(tops, hasLength(2));

      await tester.binding.setSurfaceSize(const Size(1024, 1366));
      await tester.pumpAndSettle();
      tops = {for (final r in _chipRects(tester)) r.top.round()};
      expect(tops, hasLength(1));
    });
  });

  testWidgets('Home still lays out when a keyboard above it leaves almost no '
      'room', (tester) async {
    // Home stays laid out under the photo pages; a keyboard there can leave
    // its body shorter than its own padding.
    await _size(tester, const Size(390, 844));
    for (final keyboard in [700.0, 760.0, 800.0]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: gmBuildTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(viewInsets: EdgeInsets.only(bottom: keyboard)),
            child: child!,
          ),
          home: const GentleHomePage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'keyboard $keyboard');
    }
  });

  testWidgets('the help sheet closes with a full-width button like the '
      'other sheets', (tester) async {
    await _size(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(const GentleGamePage(pictures: ActivityPicture.samples)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('How this works'));
    await tester.pumpAndSettle();
    final button = tester.getRect(
      find.widgetWithText(FilledButton, 'Back to the pictures'),
    );
    expect(button.width, closeTo(390 - 2 * gmSpaceLg, 1));
  });

  group('confirmations make the safe choice the primary action', () {
    testWidgets('Start again keeps the board unless chosen', (tester) async {
      await _size(tester, const Size(390, 844));
      await tester.pumpWidget(
        _app(const GentleGamePage(pictures: ActivityPicture.samples)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel(RegExp(r', tile 1$')).first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Start again'));
      await tester.pumpAndSettle();
      final dialog = find.byType(AlertDialog);
      expect(
        find.descendant(
          of: dialog,
          matching: find.widgetWithText(FilledButton, 'Keep this board'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: dialog,
          matching: find.widgetWithText(TextButton, 'Start again'),
        ),
        findsOneWidget,
      );
      // Side by side, the primary is on the right.
      final keep = tester.getRect(find.text('Keep this board'));
      final again = tester.getRect(
        find.descendant(of: dialog, matching: find.text('Start again')),
      );
      if ((keep.top - again.top).abs() < 1) {
        expect(keep.left, greaterThan(again.left));
      } else {
        expect(keep.top, lessThan(again.top));
      }
    });

    testWidgets('at 200% the dialog actions stack full width, safe first', (
      tester,
    ) async {
      await _size(tester, const Size(390, 844));
      await tester.pumpWidget(
        _app(
          const GentleGamePage(pictures: ActivityPicture.samples),
          textScale: 2,
        ),
      );
      await tester.pumpAndSettle();
      final tile = find.bySemanticsLabel(RegExp(r', tile 1$')).first;
      await tester.tap(tile);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Start again'));
      await tester.pumpAndSettle();
      final dialog = find.byType(AlertDialog);
      final keep = tester.getRect(
        find.descendant(
          of: dialog,
          matching: find.widgetWithText(FilledButton, 'Keep this board'),
        ),
      );
      final again = tester.getRect(
        find.descendant(
          of: dialog,
          matching: find.widgetWithText(TextButton, 'Start again'),
        ),
      );
      expect(keep.top, lessThan(again.top));
      expect(keep.width, closeTo(again.width, 0.5));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a landscape phone with side insets keeps dialog labels '
        'whole', (tester) async {
      // iPhone landscape: the notch and home-indicator insets narrow the
      // dialog, which showDialog keeps inside the safe area.
      tester.view
        ..physicalSize = const Size(852, 393) * 3
        ..devicePixelRatio = 3
        ..padding = const FakeViewPadding(left: 59 * 3, right: 59 * 3);
      addTearDown(tester.view.reset);
      for (final scale in [1.6, 2.0]) {
        await tester.pumpWidget(
          _app(
            const GentleGamePage(pictures: ActivityPicture.samples),
            textScale: scale,
          ),
        );
        await tester.pumpAndSettle();
        final tile = find.bySemanticsLabel(RegExp(r', tile 1$')).first;
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        await tester.tap(tile);
        await tester.pumpAndSettle();
        final again = find.widgetWithText(OutlinedButton, 'Start again');
        await tester.ensureVisible(again);
        await tester.pumpAndSettle();
        await tester.tap(again);
        await tester.pumpAndSettle();
        final dialog = find.byType(AlertDialog);
        for (final label in ['Keep this board', 'Start again']) {
          expect(
            _oneLine(
              tester,
              find.descendant(of: dialog, matching: find.text(label)),
            ),
            isTrue,
            reason: '$label at ${scale}x',
          );
        }
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Keep this board'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Reset comfort settings asks with Keep my settings first', (
      tester,
    ) async {
      await _size(tester, const Size(390, 844));
      await tester.pumpWidget(_app(const GentleHomePage()));
      await tester.pumpAndSettle();
      await _openComfort(tester);
      final reset = find.text('Reset comfort settings');
      await tester.ensureVisible(reset);
      await tester.tap(reset);
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(FilledButton, 'Keep my settings'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextButton, 'Reset'), findsOneWidget);
    });
  });

  testWidgets('at 200% a finished board scrolls its closing words into view '
      'above the buttons', (tester) async {
    await _size(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(
        const GentleGamePage(pictures: ActivityPicture.samples),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();
    await _finishBoard(tester);
    final words = tester.getRect(find.text('Play again or take a break.'));
    final bar = tester.getRect(find.byType(GmBottomBar));
    expect(words.bottom, lessThanOrEqualTo(bar.top + 0.5));
    expect(find.text('All pairs together.').hitTestable(), findsOneWidget);
    // At the very end, so nothing is left under the bar and no line shows.
    final line = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(GmBottomBar),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final border = (line.decoration as BoxDecoration).border! as Border;
    expect(border.top.color, Colors.transparent);
  });

  testWidgets('at 200% the closing words fit above a bar that also holds a '
      'share suggestion', (tester) async {
    // The third finished game brings a quiet suggestion into the bar.
    SharedPreferences.setMockInitialValues({'share_completed_games': 2});
    await _size(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(
        const GentleGamePage(pictures: ActivityPicture.samples),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();
    await _finishBoard(tester);
    expect(
      find.text('Enjoying these pictures together?', findRichText: true),
      findsNothing,
    );
    expect(
      find.textContaining('Another family might enjoy them too'),
      findsOneWidget,
    );
    final words = tester.getRect(find.text('Play again or take a break.'));
    expect(
      words.bottom,
      lessThanOrEqualTo(tester.getRect(find.byType(GmBottomBar)).top + 0.5),
    );
  });

  testWidgets('with Reduce Motion the finish is shown without an animated '
      'scroll', (tester) async {
    await _size(tester, const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        theme: gmBuildTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(2),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: const GentleGamePage(pictures: ActivityPicture.samples),
      ),
    );
    await tester.pumpAndSettle();
    await _finishBoard(tester, settleLast: false);
    final words = tester.getRect(find.text('Play again or take a break.'));
    expect(
      words.bottom,
      lessThanOrEqualTo(tester.getRect(find.byType(GmBottomBar)).top + 0.5),
    );
  });

  group('picture puzzle', () {
    const one = [
      ActivityPicture(id: 'flower', label: 'Flower', icon: Icons.local_florist),
    ];
    Widget puzzle({double textScale = 1}) => _app(
      PicturePuzzlePage(pictures: one, random: Random(7)),
      textScale: textScale,
    );

    testWidgets('exit labels are never broken mid-phrase', (tester) async {
      for (final width in [320.0, 390.0]) {
        await _size(tester, Size(width, 844));
        await tester.pumpWidget(puzzle());
        await tester.pumpAndSettle();
        for (final label in ['Done for now', 'Start again']) {
          expect(_oneLine(tester, find.text(label)), isTrue, reason: label);
        }
      }
    });

    testWidgets('on a tablet the board grows with the screen', (tester) async {
      await _size(tester, const Size(1024, 1366));
      await tester.pumpWidget(puzzle());
      await tester.pumpAndSettle();
      final spot = tester.getSize(find.bySemanticsLabel(RegExp('^Spot 1, 1,')));
      expect(spot.width, greaterThan(200));
      // The loose pieces still share one row.
      final pieces = find.bySemanticsLabel(RegExp(r'^Piece \d of 4$'));
      final tops = {
        for (final e in pieces.evaluate())
          tester.getRect(find.byElementPredicate((x) => x == e)).top.round(),
      };
      expect(tops, hasLength(1));
    });

    testWidgets('the reference picture keeps its name beside it at 200%', (
      tester,
    ) async {
      await _size(tester, const Size(390, 844));
      await tester.pumpWidget(puzzle(textScale: 2));
      await tester.pumpAndSettle();
      final name = tester.getRect(find.text('The whole picture'));
      final instruction = tester.getRect(
        find.textContaining('Tap a piece, then tap where it goes.'),
      );
      // Read in order: instruction, then the picture with its name.
      expect(name.top, greaterThan(instruction.bottom));
    });
  });

  testWidgets('the app bar takes the linen tone while content scrolls under '
      'it', (tester) async {
    await _size(tester, const Size(390, 500));
    await tester.pumpWidget(
      _app(
        Scaffold(
          appBar: AppBar(title: const Text('Title')),
          body: ListView(
            children: [for (var i = 0; i < 40; i++) Text('Row $i')],
          ),
        ),
      ),
    );
    Color tone() => tester
        .widget<Material>(
          find
              .descendant(
                of: find.byType(AppBar),
                matching: find.byType(Material),
              )
              .first,
        )
        .color!;
    expect(tone(), gmSurf50);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tone(), gmSurf100);
  });
}
