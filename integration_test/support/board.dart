import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_harness.dart';

/// Every picture tile on a board, as a screen reader announces it:
/// "Flower, tile 3" or "Hidden picture, tile 3".
final Finder boardTiles = find.bySemanticsLabel(RegExp(r', tile \d+$'));

/// Hidden tiles, which must announce nothing but their position.
final Finder hiddenTiles = find.bySemanticsLabel(
  RegExp(r'^Hidden picture, tile \d+$'),
);

/// One tile as announced: its spoken name, position and state.
class TileInfo {
  const new(this.name, this.position, this.value);

  /// The picture's name, or "Hidden picture".
  final String name;

  /// 1-based place on the board.
  final int position;

  /// "Selected", "Matched" or empty.
  final String value;

  bool get hidden => name == 'Hidden picture';
  bool get matched => value == 'Matched';
  bool get selected => value == 'Selected';

  /// Finds exactly this tile by what a screen reader would hear.
  Finder get finder => find.bySemanticsLabel('$name, tile $position');

  @override
  String toString() => '$name, tile $position ($value)';
}

final _tileLabel = RegExp(r'^(.*), tile (\d+)$');

/// Reads the board in tile order from the semantics tree.
List<TileInfo> readBoard(WidgetTester tester) {
  final tiles = [
    for (final element in boardTiles.evaluate())
      _info(tester.getSemantics(find.byElementPredicate((e) => e == element))),
  ]..sort((a, b) => a.position.compareTo(b.position));
  return tiles;
}

TileInfo _info(SemanticsNode node) {
  final match = _tileLabel.firstMatch(node.label)!;
  return TileInfo(match[1]!, int.parse(match[2]!), node.value);
}

/// The arrangement a person sees: picture names in tile order.
List<String> arrangement(WidgetTester tester) => [
  for (final tile in readBoard(tester)) tile.name,
];

/// Taps the tile at [position] (1-based) the way a person would.
Future<void> tapTile(WidgetTester tester, int position) async {
  final tile = readBoard(tester).singleWhere((t) => t.position == position);
  await tapOn(tester, tile.finder);
}

/// Matches every pair on a board whose pictures are visible, tapping each
/// pair in turn, and waits until the board says all pairs are together.
Future<void> matchAllVisiblePairs(WidgetTester tester) async {
  final byName = <String, List<int>>{};
  for (final tile in readBoard(tester)) {
    expect(tile.hidden, isFalse, reason: 'expected visible pictures: $tile');
    if (!tile.matched) (byName[tile.name] ??= []).add(tile.position);
  }
  for (final positions in byName.values) {
    expect(positions, hasLength(2));
    await tapTile(tester, positions[0]);
    await tapTile(tester, positions[1]);
    expect(
      readBoard(tester).where((t) => positions.contains(t.position)),
      everyElement(predicate<TileInfo>((t) => t.matched, 'matched')),
    );
  }
}

/// Text that would put pressure on the person: counts of moves or seconds,
/// a score or a clock. The calm sentence "No timers, scores, or rush." is
/// fine because no number goes with it.
final List<RegExp> _pressure = [
  RegExp(
    r'\b\d+\s*(moves?|turns?|tries|attempts?|points?|pts|seconds?|secs?|'
    r'minutes?|mins?|mistakes?|errors?)\b',
    caseSensitive: false,
  ),
  RegExp(
    r'\b(score|moves|time|timer|streak|points|best)\s*[:=]\s*\d',
    caseSensitive: false,
  ),
  RegExp(
    r'\b(your score|high score|best time|streak|countdown|stopwatch)\b',
    caseSensitive: false,
  ),
  RegExp(r'\b\d{1,2}:\d{2}\b'),
];

final Set<IconData> _clockIcons = {
  Icons.timer,
  Icons.timer_outlined,
  Icons.av_timer,
  Icons.alarm,
  Icons.hourglass_bottom,
  Icons.hourglass_top,
  Icons.hourglass_full,
  Icons.timelapse,
  Icons.leaderboard,
  Icons.emoji_events,
};

/// Fails if any text or icon on screen shows a clock, score, move count or
/// streak.
void expectNoPressureCues(WidgetTester tester) {
  final texts = [
    for (final text in tester.widgetList<RichText>(find.byType(RichText)))
      text.text.toPlainText(),
  ];
  for (final text in texts) {
    for (final pattern in _pressure) {
      expect(
        pattern.hasMatch(text),
        isFalse,
        reason: 'pressure cue "$text" matches ${pattern.pattern}',
      );
    }
  }
  final icons = tester.widgetList<Icon>(find.byType(Icon)).map((i) => i.icon);
  expect(icons.where(_clockIcons.contains), isEmpty, reason: 'clock icon');
}
