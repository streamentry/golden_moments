import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/models/puzzle_board.dart';

void main() {
  test('starts with every piece in the tray and every slot empty', () {
    final board = PuzzleBoard(2, random: Random(1));
    expect(board.tray.toSet(), {0, 1, 2, 3});
    expect(board.slots, everyElement(isNull));
    expect(board.complete, isFalse);
    expect(board.placed, 0);
  });

  test('sizes outside 2 to 4 are rejected', () {
    expect(() => PuzzleBoard(1), throwsArgumentError);
    expect(() => PuzzleBoard(5), throwsArgumentError);
  });

  test('choose a piece, place it; pieces and slots stay consistent', () {
    final board = PuzzleBoard(2, random: Random(2));
    final piece = board.tray.first;
    expect(board.select(piece), isTrue);
    expect(board.selected, piece);
    expect(board.tapSlot(3), isTrue);
    expect(board.slots[3], piece);
    expect(board.tray, isNot(contains(piece)));
    expect(board.selected, isNull);
    expect(board.placed, 1);
  });

  test('a wrong placement is allowed and is not reported as a mistake', () {
    final board = PuzzleBoard(2, random: Random(3));
    final wrongPiece = board.tray.firstWhere((p) => p != 0);
    board
      ..select(wrongPiece)
      ..tapSlot(0);
    expect(board.slots[0], wrongPiece);
    expect(board.isCorrect(0), isFalse);
    expect(board.complete, isFalse);
  });

  test('tapping a placed piece with nothing chosen returns it', () {
    final board = PuzzleBoard(2, random: Random(4));
    final piece = board.tray.first;
    board
      ..select(piece)
      ..tapSlot(1);
    expect(board.tapSlot(1), isTrue);
    expect(board.isEmpty(1), isTrue);
    expect(board.tray, contains(piece));
    expect(board.tapSlot(1), isFalse); // empty slot, nothing chosen
  });

  test('placing on an occupied slot swaps the old piece back to the tray', () {
    final board = PuzzleBoard(2, random: Random(5));
    final a = board.tray[0];
    final b = board.tray[1];
    board
      ..select(a)
      ..tapSlot(0)
      ..select(b)
      ..tapSlot(0);
    expect(board.slots[0], b);
    expect(board.tray, contains(a));
    expect(board.tray.length + board.placed, 4);
  });

  test('choosing again puts a piece down; unknown pieces are ignored', () {
    final board = PuzzleBoard(2, random: Random(6));
    final piece = board.tray.first;
    board
      ..select(piece)
      ..select(piece);
    expect(board.selected, isNull);
    expect(board.select(99), isFalse);
    expect(board.tapSlot(-1), isFalse);
    expect(board.tapSlot(4), isFalse);
  });

  test('completes only when every piece is in its own slot', () {
    final board = PuzzleBoard(3, random: Random(7));
    for (var slot = 0; slot < 9; slot++) {
      expect(board.complete, isFalse);
      board
        ..select(slot)
        ..tapSlot(slot);
    }
    expect(board.complete, isTrue);
    expect(board.placed, 9);
    expect(board.tray, isEmpty);
  });
}
