import 'dart:math';

/// A matching activity with no clock, score, penalty, or delayed callbacks.
/// A non-matching pair stays visible until the next deliberate tap.
class GentleBoard {
  GentleBoard(List<String> pictureIds, {Random? random}) {
    if (pictureIds.length < 2 ||
        pictureIds.length > 6 ||
        pictureIds.toSet().length != pictureIds.length) {
      throw ArgumentError('Choose between two and six different pictures.');
    }
    cards = List<String>.unmodifiable(
      [...pictureIds, ...pictureIds]..shuffle(random ?? Random()),
    );
  }

  late final List<String> cards;
  final Set<int> _matched = {};
  final List<int> _selected = [];

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
