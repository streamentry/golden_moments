import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_moments/features/today/data/today_notes.dart';
import 'package:shared_preferences/shared_preferences.dart';

TodayNote _note({
  String id = 'a',
  String day = '2026-11-01',
  Situation situation = Situation.goHome,
  Outcome outcome = Outcome.helped,
  String text = '',
}) => TodayNote(
  id: id,
  day: day,
  situation: situation,
  outcome: outcome,
  text: text,
);

void main() {
  group('TodayNotes', () {
    test('adds a note first without changing the old list', () {
      final before = [_note(id: 'old')];
      final after = TodayNotes.add(before, _note(id: 'new'));
      expect(after.map((n) => n.id), ['new', 'old']);
      expect(before.map((n) => n.id), ['old']);
    });

    test('keeps at most maxNotes and trims long text', () {
      var list = <TodayNote>[];
      for (var i = 0; i < TodayNotes.maxNotes + 5; i++) {
        list = TodayNotes.add(list, _note(id: '$i'));
      }
      expect(list, hasLength(TodayNotes.maxNotes));
      expect(list.first.id, '${TodayNotes.maxNotes + 4}');
      final long = TodayNotes.add(const [], _note(text: '  ${'x' * 400}  '));
      expect(long.single.text, hasLength(TodayNotes.maxText));
    });

    test('removes one note by id', () {
      final list = TodayNotes.remove([_note(), _note(id: 'b')], 'a');
      expect(list.map((n) => n.id), ['b']);
    });

    test('groups by day, newest day first, keeping order inside a day', () {
      final days = TodayNotes.byDay([
        _note(id: '1', day: '2026-10-30'),
        _note(id: '2'),
        _note(id: '3', day: '2026-10-30'),
      ]);
      expect(days.map((d) => d.day), ['2026-11-01', '2026-10-30']);
      expect(days.last.notes.map((n) => n.id), ['1', '3']);
    });

    test('reads the same format the website writes', () {
      final raw = jsonEncode([
        {
          'id': 'w',
          'date': '2026-11-01',
          'situation': 'late-day',
          'outcome': 'not_really',
          'text': 'Lights on helped a bit',
        },
      ]);
      expect(TodayNotes.parse(raw), [
        _note(
          id: 'w',
          situation: Situation.lateDay,
          outcome: Outcome.notReally,
          text: 'Lights on helped a bit',
        ),
      ]);
    });

    test('drops anything malformed', () {
      expect(TodayNotes.parse(null), isEmpty);
      expect(TodayNotes.parse('not json'), isEmpty);
      expect(TodayNotes.parse('{"a":1}'), isEmpty);
      final good = _note().toJson();
      final raw = jsonEncode([
        good,
        {...good, 'outcome': 'great'},
        {...good, 'situation': 'unknown'},
        {...good, 'date': 'yesterday'},
        {...good, 'text': 5},
        'string',
      ]);
      expect(TodayNotes.parse(raw), [_note()]);
    });

    test('formats the local day', () {
      expect(TodayNotes.localDay(DateTime(2026, 3, 7, 23, 59)), '2026-03-07');
    });
  });

  group('TodayNotesStore', () {
    test('saves and loads on this device', () async {
      SharedPreferences.setMockInitialValues({});
      const store = TodayNotesStore();
      expect(await store.load(), isEmpty);
      expect(await store.save([_note()]), isTrue);
      expect(await store.load(), [_note()]);
    });

    test('a damaged value reads as no notes', () async {
      SharedPreferences.setMockInitialValues({
        TodayNotesStore.storageKey: '[{"broken":',
      });
      expect(await const TodayNotesStore().load(), isEmpty);
    });
  });
}
