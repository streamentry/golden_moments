import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/models/gentle_board.dart';

void main() {
  test('four tiles contain exactly two pairs', () {
    final board = GentleBoard(['a', 'b'], random: Random(1));
    expect(board.cards.length, 4);
    expect(board.cards.where((id) => id == 'a').length, 2);
    expect(board.cards.where((id) => id == 'b').length, 2);
  });
  test('invalid or duplicate inputs are rejected', () {
    expect(() => GentleBoard(['a']), throwsArgumentError);
    expect(() => GentleBoard(['a', 'a']), throwsArgumentError);
    expect(
      () => GentleBoard(List.generate(7, (i) => '$i')),
      throwsArgumentError,
    );
  });
  test('same tile cannot match itself and invalid taps do nothing', () {
    final board = GentleBoard(['a', 'b']);
    expect(board.tap(-1), isFalse);
    expect(board.tap(4), isFalse);
    expect(board.tap(0), isTrue);
    expect(board.tap(0), isFalse);
    expect(board.isMatched(0), isFalse);
  });
  test('mismatch stays visible until the next deliberate tap', () {
    final board = GentleBoard(['a', 'b'], random: Random(2));
    final a = board.cards.indexOf('a');
    final b = board.cards.indexOf('b');
    board
      ..tap(a)
      ..tap(b);
    expect(board.waitingForNextTurn, isTrue);
    expect(board.isVisible(a, keepVisible: false), isTrue);
    final otherA = board.cards.lastIndexOf('a');
    board.tap(otherA);
    expect(board.waitingForNextTurn, isFalse);
    expect(board.isVisible(a, keepVisible: false), isFalse);
    expect(board.isSelected(otherA), isTrue);
  });
  test('matching completes without scores or timers', () {
    final board = GentleBoard(['a', 'b']);
    for (final id in ['a', 'b']) {
      board.tap(board.cards.indexOf(id));
      board.tap(board.cards.lastIndexOf(id));
    }
    expect(board.complete, isTrue);
    expect(board.tap(0), isFalse);
    expect(board.isVisible(0, keepVisible: false), isTrue);
  });
  test('always-visible mode reveals every picture', () {
    final board = GentleBoard(['a', 'b']);
    for (var i = 0; i < board.cards.length; i++) {
      expect(board.isVisible(i, keepVisible: true), isTrue);
    }
  });
}
