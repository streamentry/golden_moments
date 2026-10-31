import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The hard moments on "What is hardest today?", in the order shown. Each
/// one condenses a sourced guide on dementiaactivities.games (same ids as
/// site/src/lib/today/situations.ts).
enum Situation {
  goHome('go-home'),
  sameQuestion('same-question'),
  saysNo('says-no'),
  lateDay('late-day'),
  nothingToDo('nothing-to-do'),
  hardToTalk('hard-to-talk'),
  visit('visit'),
  wornOut('worn-out');

  new(this.id);

  /// Stored id, shared with the website.
  final String id;

  static Situation? fromId(String id) {
    for (final s in values) {
      if (s.id == id) return s;
    }
    return null;
  }
}

/// How trying something went, as the caregiver tapped it.
enum Outcome {
  helped('helped'),
  notReally('not_really'),
  notTried('not_tried');

  new(this.id);

  final String id;

  static Outcome? fromId(String id) {
    for (final o in values) {
      if (o.id == id) return o;
    }
    return null;
  }
}

/// One tap of "how did it go?", with optional words of the caregiver's own.
class TodayNote extends Equatable {
  const new({
    required this.id,
    required this.day,
    required this.situation,
    required this.outcome,
    this.text = '',
  });

  final String id;

  /// Local calendar day, YYYY-MM-DD.
  final String day;
  final Situation situation;
  final Outcome outcome;
  final String text;

  static final _dayPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  Map<String, String> toJson() => {
    'id': id,
    'date': day,
    'situation': situation.id,
    'outcome': outcome.id,
    'text': text,
  };

  /// Null for anything that is not a well-formed note.
  static TodayNote? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final day = json['date'];
    final situation = json['situation'];
    final outcome = json['outcome'];
    final text = json['text'];
    if (id is! String ||
        day is! String ||
        !_dayPattern.hasMatch(day) ||
        situation is! String ||
        outcome is! String ||
        text is! String) {
      return null;
    }
    final s = Situation.fromId(situation);
    final o = Outcome.fromId(outcome);
    if (s == null || o == null) return null;
    return TodayNote(id: id, day: day, situation: s, outcome: o, text: text);
  }

  @override
  List<Object?> get props => [id, day, situation, outcome, text];
}

/// Notes of one day; [TodayNotes.byDay] lists the newest day first.
typedef NoteDay = ({String day, List<TodayNote> notes});

/// Pure list operations; the lists passed in are never changed.
abstract final class TodayNotes {
  static const maxNotes = 200;
  static const maxText = 280;

  /// A new list with [note] first, its text trimmed to [maxText] characters
  /// and the oldest notes dropped past [maxNotes].
  static List<TodayNote> add(List<TodayNote> notes, TodayNote note) {
    final text = note.text.trim();
    final trimmed = TodayNote(
      id: note.id,
      day: note.day,
      situation: note.situation,
      outcome: note.outcome,
      text: text.length > maxText ? text.substring(0, maxText) : text,
    );
    return [trimmed, ...notes].take(maxNotes).toList(growable: false);
  }

  static List<TodayNote> remove(List<TodayNote> notes, String id) =>
      notes.where((n) => n.id != id).toList(growable: false);

  static List<NoteDay> byDay(List<TodayNote> notes) {
    final days = <String, List<TodayNote>>{};
    for (final n in notes) {
      (days[n.day] ??= []).add(n);
    }
    final keys = days.keys.toList()..sort((a, b) => b.compareTo(a));
    return [for (final k in keys) (day: k, notes: days[k]!)];
  }

  /// Saved notes, keeping only well-formed entries; anything else is none.
  static List<TodayNote> parse(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final data = jsonDecode(raw);
      if (data is! List) return const [];
      return data
          .map(TodayNote.fromJson)
          .whereType<TodayNote>()
          .take(maxNotes)
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  static String encode(List<TodayNote> notes) =>
      jsonEncode([for (final n in notes) n.toJson()]);

  /// Today's local date as YYYY-MM-DD.
  static String localDay(DateTime now) =>
      '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

/// Saves notes on this device only. Nothing is sent anywhere.
class TodayNotesStore {
  const new();

  static const storageKey = 'today_notes_v1';

  Future<List<TodayNote>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return TodayNotes.parse(prefs.getString(storageKey));
  }

  /// Whether the notes were written.
  Future<bool> save(List<TodayNote> notes) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(storageKey, TodayNotes.encode(notes));
  }
}
