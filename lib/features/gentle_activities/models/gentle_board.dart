import 'dart:math';

/// A matching activity with no clock, score, penalty, or delayed callbacks.
/// A non-matching pair stays visible until the next deliberate tap.
class GentleBoard {
  new(List<String> pictureIds, {Random? random}) {
    if (pictureIds.length < 2 ||
        pictureIds.length > 6 ||
        pictureIds.toSet().length != pictureIds.length) {
      throw ArgumentError('Choose between two and six different pictures.');
    }
    cards = List<String>.unmodifiable(
      [...pictureIds, ...pictureIds]..shuffle(random ?? Random()),
    );
  }

  new _restored(
    List<String> restoredCards,
    Iterable<int> matched,
    Iterable<int> selected,
  ) {
    cards = List<String>.unmodifiable(restoredCards);
    _matched.addAll(matched);
    _selected.addAll(selected);
  }

  /// Rebuilds a saved, unfinished board, or returns null when the saved
  /// arrangement is not a state this activity could have reached.
  static GentleBoard? tryRestore({
    required List<String> cards,
    required List<int> matched,
    required List<int> selected,
  }) {
    final counts = <String, int>{};
    for (final id in cards) {
      counts[id] = (counts[id] ?? 0) + 1;
    }
    final pairs = counts.length;
    if (cards.length != pairs * 2 ||
        pairs < 2 ||
        pairs > 6 ||
        counts.values.any((n) => n != 2)) {
      return null;
    }
    bool inRange(int i) => i >= 0 && i < cards.length;
    final matchedSet = matched.toSet();
    final selectedSet = selected.toSet();
    if (matchedSet.length != matched.length ||
        selectedSet.length != selected.length ||
        !matchedSet.every(inRange) ||
        !selectedSet.every(inRange) ||
        selected.length > 2 ||
        selectedSet.any(matchedSet.contains)) {
      return null;
    }
    // Matches come in whole pairs, and two selected tiles that match would
    // already have been matched.
    for (final id in counts.keys) {
      final at = [
        for (var i = 0; i < cards.length; i++)
          if (cards[i] == id) i,
      ];
      if (at.where(matchedSet.contains).length == 1) return null;
    }
    if (selected.length == 2 && cards[selected[0]] == cards[selected[1]]) {
      return null;
    }
    final board = GentleBoard._restored(cards, matched, selected);
    return board.complete ? null : board;
  }

  late final List<String> cards;
  final Set<int> _matched = {};
  final List<int> _selected = [];

  List<int> get matchedIndices => (_matched.toList()..sort());
  List<int> get selectedIndices => List<int>.of(_selected);

  bool get complete => _matched.length == cards.length;
  bool get waitingForNextTurn => _selected.length == 2;

  /// True once the participant has made a choice on an unfinished board, so
  /// starting over should be confirmed rather than silently discarding it.
  bool get hasProgress =>
      !complete && (_matched.isNotEmpty || _selected.isNotEmpty);
  bool isMatched(int index) => _matched.contains(index);
  bool isSelected(int index) => _selected.contains(index);
  bool isVisible(int index, {required bool keepVisible}) =>
      keepVisible || isMatched(index) || isSelected(index);

  /// Returns false for taps that do not change the activity.
  bool tap(int index) {
    if (index < 0 || index >= cards.length || isMatched(index) || complete) {
      return false;
    }
    if (waitingForNextTurn) _selected.clear();
    if (_selected.contains(index)) return false;
    _selected.add(index);
    if (_selected.length == 2 &&
        cards[_selected.first] == cards[_selected.last]) {
      _matched.addAll(_selected);
      _selected.clear();
    }
    return true;
  }
}
