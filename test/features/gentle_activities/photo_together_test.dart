import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/presentation/photo_together_page.dart';

const _pictures = [
  ActivityPicture(
    id: 'a',
    label: 'Garden',
    icon: Icons.local_florist,
    caption: 'Summer roses',
    description: 'Red roses beside a fence.',
  ),
  ActivityPicture(id: 'b', label: 'Boat', icon: Icons.sailing),
  ActivityPicture(id: 'c', label: 'Tea', icon: Icons.emoji_food_beverage),
];

Widget _app(
  List<ActivityPicture> pictures, {
  Future<bool> Function(ActivityPicture)? onHide,
}) => MaterialApp(
  theme: gmBuildTheme(),
  home: Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  PhotoTogetherPage(pictures: pictures, onHide: onHide),
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  ),
);

Future<void> _open(
  WidgetTester tester,
  List<ActivityPicture> pictures, {
  Future<bool> Function(ActivityPicture)? onHide,
}) async {
  // Tall enough that every optional control is built; real phone sizes
  // are covered by the layout cases at the end.
  await tester.binding.setSurfaceSize(const Size(600, 1800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_app(pictures, onHide: onHide));
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _toggle(WidgetTester tester, String title) async {
  final tile = find.widgetWithText(SwitchListTile, title);
  await tester.ensureVisible(tile);
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('labelled Previous and Next move one picture; no autoplay', (
    tester,
  ) async {
    await _open(tester, _pictures);
    expect(find.text('Picture 1 of 3'), findsOneWidget);
    final previous = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Previous'),
        matching: find.bySubtype<ButtonStyleButton>(),
      ),
    );
    expect(previous.onPressed, isNull);

    await _tap(tester, 'Next');
    expect(find.text('Picture 2 of 3'), findsOneWidget);
    await _tap(tester, 'Previous');
    expect(find.text('Picture 1 of 3'), findsOneWidget);

    // Nothing advances on its own, however long the picture is shown.
    await tester.pump(const Duration(minutes: 10));
    expect(find.text('Picture 1 of 3'), findsOneWidget);
  });

  testWidgets('captions and prompts are off by default and independent', (
    tester,
  ) async {
    await _open(tester, _pictures);
    expect(find.text('Summer roses'), findsNothing);
    expect(find.text('What do you like about this picture?'), findsNothing);
    expect(
      find.bySemanticsLabel('Garden. Red roses beside a fence.'),
      findsOneWidget,
    );

    await _toggle(tester, 'Show captions');
    expect(find.text('Summer roses'), findsOneWidget);
    expect(find.text('What do you like about this picture?'), findsNothing);

    await _toggle(tester, 'Show a conversation prompt');
    expect(find.text('What do you like about this picture?'), findsOneWidget);
    // Prompts stay on for the visit and change only when the person moves.
    await _tap(tester, 'Next');
    expect(find.text('What catches your eye?'), findsOneWidget);
    await _toggle(tester, 'Show a conversation prompt');
    expect(find.text('What catches your eye?'), findsNothing);
  });

  testWidgets('no viewing copy asks the person to remember or answer', (
    tester,
  ) async {
    await _open(tester, _pictures);
    await _toggle(tester, 'Show a conversation prompt');
    for (var i = 0; i < _pictures.length; i++) {
      final texts = [
        for (final e in find.byType(Text).evaluate())
          ((e.widget as Text).data ?? '').toLowerCase(),
      ];
      expect(
        texts.where((t) => t.contains('do you remember') || t.contains('who')),
        isEmpty,
      );
      if (i < _pictures.length - 1) await _tap(tester, 'Next');
    }
  });

  testWidgets('hiding for this visit needs no reason and is not timed', (
    tester,
  ) async {
    await _open(tester, _pictures);
    await _tap(tester, 'Next');
    await _tap(tester, 'Hide this picture');
    expect(find.text('Picture 2 of 2'), findsOneWidget);
    expect(find.text('This picture is hidden for now.'), findsOneWidget);
    await tester.pump(const Duration(minutes: 5));
    expect(find.text('This picture is hidden for now.'), findsOneWidget);
    expect(find.bySemanticsLabel('Boat'), findsNothing);
  });

  testWidgets('a saved hide is reported; a failed one changes nothing', (
    tester,
  ) async {
    final hidden = <String>[];
    var fail = false;
    await _open(
      tester,
      _pictures,
      onHide: (picture) async {
        if (fail) return false;
        hidden.add(picture.id);
        return true;
      },
    );
    await _tap(tester, 'Hide this picture');
    expect(hidden, ['a']);
    expect(find.text('Picture 1 of 2'), findsOneWidget);
    expect(find.textContaining('You can show it again'), findsOneWidget);

    fail = true;
    await _tap(tester, 'Hide this picture');
    expect(hidden, ['a']);
    expect(find.text('Picture 1 of 2'), findsOneWidget);
    expect(find.textContaining('Could not hide this picture'), findsOneWidget);
  });

  testWidgets('an empty set offers the included pictures and an exit', (
    tester,
  ) async {
    await _open(tester, const []);
    expect(
      find.text('There are no pictures to look at here right now.'),
      findsOneWidget,
    );
    expect(find.text('Done for now'), findsOneWidget);
    await _tap(tester, 'Look at the included pictures');
    expect(
      find.text('Picture 1 of ${ActivityPicture.samples.length}'),
      findsOneWidget,
    );
  });

  testWidgets('hiding the last picture never unhides others', (tester) async {
    await _open(tester, [_pictures.first], onHide: (_) async => true);
    await _tap(tester, 'Hide this picture');
    expect(
      find.text('There are no pictures to look at here right now.'),
      findsOneWidget,
    );
    expect(find.textContaining('You can show it again'), findsOneWidget);
  });

  testWidgets('rotating keeps the picture and the chosen options', (
    tester,
  ) async {
    await _open(tester, _pictures);
    await _tap(tester, 'Next');
    await _toggle(tester, 'Show a conversation prompt');
    expect(find.text('What catches your eye?'), findsOneWidget);
    await tester.binding.setSurfaceSize(const Size(1800, 600));
    await tester.pumpAndSettle();
    expect(find.text('Picture 2 of 3'), findsOneWidget);
    expect(find.text('Done for now').hitTestable(), findsOneWidget);
    await tester.binding.setSurfaceSize(const Size(600, 1800));
    await tester.pumpAndSettle();
    expect(find.text('Picture 2 of 3'), findsOneWidget);
    expect(find.text('What catches your eye?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('after Next or Hide the new picture is back in view', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: gmBuildTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const PhotoTogetherPage(pictures: _pictures),
      ),
    );
    await tester.pumpAndSettle();
    final list = find.byType(Scrollable);
    bool inView(String label) {
      final found = find.bySemanticsLabel(RegExp('^$label'));
      // A picture scrolled far away is not even built: not in view.
      if (found.evaluate().isEmpty) return false;
      final rect = tester.getRect(found);
      final view = tester.getRect(list);
      return rect.top >= view.top - 1 && rect.top < view.bottom;
    }

    // Scroll down to the options, as a person at large text must.
    await tester.scrollUntilVisible(find.text('Hide this picture'), 200);
    expect(inView('Garden'), isFalse);
    // On a cramped screen Next sits under the picture: scroll back to it.
    await tester.scrollUntilVisible(find.text('Next'), -100);
    await tester.ensureVisible(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(inView('Boat'), isTrue);

    await tester.scrollUntilVisible(find.text('Hide this picture'), 200);
    await tester.ensureVisible(find.text('Hide this picture'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hide this picture'));
    await tester.pumpAndSettle();
    expect(inView('Tea'), isTrue);
    // The confirmation is where the eye lands too.
    expect(
      find.text('This picture is hidden for now.').hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('Done for now leaves at once', (tester) async {
    await _open(tester, _pictures);
    await _tap(tester, 'Done for now');
    expect(find.text('Open'), findsOneWidget);
  });

  for (final scenario in {
    'small phone at 200% text': (const Size(320, 568), 2.0),
    'phone at 200% text': (const Size(390, 844), 2.0),
    'landscape phone': (const Size(844, 390), 1.0),
    'iPad portrait': (const Size(1024, 1366), 1.0),
  }.entries) {
    testWidgets('controls stay in view on ${scenario.key}', (tester) async {
      final (size, textScale) = scenario.value;
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: gmBuildTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const PhotoTogetherPage(pictures: _pictures),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // The exit never needs scrolling to find, and the picture is always
      // in sight: it is the activity, so the controls must not crowd it out.
      expect(find.text('Done for now').hitTestable(), findsOneWidget);
      expect(
        tester.getRect(find.text('Done for now')).bottom,
        lessThanOrEqualTo(size.height),
      );
      final picture = tester.getRect(find.bySemanticsLabel(RegExp('^Garden')));
      final top = tester.getRect(find.byType(Scrollable)).top;
      expect(picture.top, greaterThanOrEqualTo(top - 1));
      expect(picture.height, greaterThanOrEqualTo(gmTileMin));
      // The way forward is either fixed in view or right under the picture.
      for (final label in ['Next', 'Previous']) {
        await tester.ensureVisible(find.text(label));
        await tester.pumpAndSettle();
        expect(find.text(label).hitTestable(), findsOneWidget, reason: label);
      }
      for (final label in ['Done for now', 'Next']) {
        final button = find.ancestor(
          of: find.text(label),
          matching: find.bySubtype<ButtonStyleButton>(),
        );
        expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
      }
    });
  }
}
