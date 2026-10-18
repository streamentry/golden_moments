import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/gentle_activities/data/gentle_session.dart';
import 'package:golden_moments/features/gentle_activities/models/gentle_board.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _cards = ['a', 'b', 'a', 'b'];

void main() {
  const store = GentleSessionStore();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('GentleBoard.tryRestore', () {
    test('rebuilds a reachable unfinished board', () {
      final board = GentleBoard.tryRestore(
        cards: _cards,
        matched: [0, 2],
        selected: [1],
      )!;
      expect(board.cards, _cards);
      expect(board.isMatched(0), isTrue);
      expect(board.isMatched(2), isTrue);
      expect(board.isSelected(1), isTrue);
      expect(board.complete, isFalse);
      expect(board.hasProgress, isTrue);
    });

    test('a restored board plays on like any other', () {
      final board =
          GentleBoard.tryRestore(cards: _cards, matched: [0, 2], selected: [])!
            ..tap(1)
            ..tap(3);
      expect(board.complete, isTrue);
    });

    test('rejects arrangements the activity could not have reached', () {
      const bad = <List<Object>>[
        // wrong card counts / not whole pairs
        [
          <String>['a', 'b'],
          <int>[],
          <int>[],
        ],
        [
          <String>['a', 'a', 'a', 'b'],
          <int>[],
          <int>[],
        ],
        [
          <String>['a', 'a'],
          <int>[],
          <int>[],
        ],
        // indices out of range, duplicated, or half a pair matched
        [
          _cards,
          <int>[9],
          <int>[],
        ],
        [
          _cards,
          <int>[-1],
          <int>[],
        ],
        [
          _cards,
          <int>[0, 0],
          <int>[],
        ],
        [
          _cards,
          <int>[0],
          <int>[],
        ],
        // selection problems
        [
          _cards,
          <int>[],
          <int>[0, 1, 3],
        ],
        [
          _cards,
          <int>[],
          <int>[1, 1],
        ],
        [
          _cards,
          <int>[0, 2],
          <int>[0],
        ],
        [
          _cards,
          <int>[],
          <int>[0, 2],
        ], // would already have matched
        // a finished board is not resumable
        [
          _cards,
          <int>[0, 1, 2, 3],
          <int>[],
        ],
      ];
      for (final b in bad) {
        expect(
          GentleBoard.tryRestore(
            cards: b[0] as List<String>,
            matched: b[1] as List<int>,
            selected: b[2] as List<int>,
          ),
          isNull,
          reason: '$b',
        );
      }
    });
  });

  group('GentleSession', () {
    test('keeps picture ids and positions only, no score or time', () {
      final board = GentleBoard.tryRestore(
        cards: _cards,
        matched: [],
        selected: [1],
      )!;
      final json = GentleSession.fromBoard(board).toJson();
      expect(json.keys.toSet(), {'v', 'cards', 'matched', 'selected'});
    });

    test('malformed and other-version records are ignored', () {
      for (final bad in <Object?>[
        null,
        'x',
        <Object?>[],
        {'v': 2, 'cards': <String>[], 'matched': <int>[], 'selected': <int>[]},
        {'cards': _cards, 'matched': <int>[], 'selected': <int>[]},
        {'v': 1, 'cards': 'a', 'matched': <int>[], 'selected': <int>[]},
        {
          'v': 1,
          'cards': [1, 2],
          'matched': <int>[],
          'selected': <int>[],
        },
        {
          'v': 1,
          'cards': _cards,
          'matched': ['0'],
          'selected': <int>[],
        },
      ]) {
        expect(GentleSession.fromJson(bad), isNull, reason: '$bad');
      }
    });

    test('a picture that is no longer available voids the session', () {
      const session = GentleSession(cards: _cards, matched: [], selected: [0]);
      expect(session.toBoard(availablePictureIds: {'a', 'b'}), isNotNull);
      expect(session.toBoard(availablePictureIds: {'a'}), isNull);
    });
  });

  group('GentleSessionStore', () {
    const session = GentleSession(cards: _cards, matched: [0, 2], selected: []);

    test('round-trips per source and keeps sources apart', () async {
      expect(await store.load('starter'), isNull);
      expect(await store.save('starter', session), isTrue);
      final restored = await const GentleSessionStore().load('starter');
      expect(restored!.cards, _cards);
      expect(restored.matched, [0, 2]);
      expect(await store.load('family'), isNull);
    });

    test('clear removes only that source and nothing else', () async {
      SharedPreferences.setMockInitialValues({'unrelated': 'kept'});
      await store.save('starter', session);
      await store.save('family', session);
      await store.clear('starter');
      expect(await store.load('starter'), isNull);
      expect(await store.load('family'), isNotNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('unrelated'), 'kept');
    });

    test('corrupt stored text means no session, not a crash', () async {
      SharedPreferences.setMockInitialValues({
        '${GentleSession.storageKeyPrefix}starter': '{broken',
      });
      expect(await store.load('starter'), isNull);
      SharedPreferences.setMockInitialValues({
        '${GentleSession.storageKeyPrefix}starter': jsonEncode({'v': 9}),
      });
      expect(await store.load('starter'), isNull);
    });
  });
}
