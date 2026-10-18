import 'dart:math';

/// A tap-to-place picture puzzle with no clock, score, penalty or hint
/// ladder (GM-009). The picture is cut into [size] x [size] pieces. A piece is
/// chosen from the tray, then a slot is chosen; a placed piece can be tapped
/// to return it. Any placement is allowed, and being wrong is never reported
/// as a mistake: the puzzle is simply complete when every piece is home.
class PuzzleBoard {
  new(this.size, {Random? random}) {
    if (size < 2 || size > 4) {
      throw ArgumentError('A puzzle is 2 to 4 pieces wide.');
    }
    tray = List<int>.generate(size * size, (i) => i)
      ..shuffle(random ?? Random());
    slots = List<int?>.filled(size * size, null);
  }

  final int size;

  /// Pieces not yet placed, in tray order. A piece's id is the slot it
  /// belongs in.
  late final List<int> tray;

  /// The piece in each slot, or null when empty.
  late final List<int?> slots;

  int? _selected;

  int get count => size * size;
  int? get selected => _selected;
  bool isEmpty(int slot) => slots[slot] == null;
  bool isCorrect(int slot) => slots[slot] == slot;
  bool get complete => List.generate(count, isCorrect).every((ok) => ok);
  int get placed => slots.where((p) => p != null).length;

  /// Chooses a tray piece. Choosing it again puts it down. Returns false for a
  /// piece that is not in the tray.
  bool select(int piece) {
    if (!tray.contains(piece)) return false;
    _selected = _selected == piece ? null : piece;
    return true;
  }

  /// Taps a slot. With a chosen piece it places it there (an occupying piece
  /// returns to the tray). With nothing chosen, a placed piece returns to the
  /// tray. Returns false when nothing changed.
  bool tapSlot(int slot) {
    if (slot < 0 || slot >= count) return false;
    final chosen = _selected;
    final there = slots[slot];
    if (chosen != null) {
      tray.remove(chosen);
      if (there != null) tray.add(there);
      slots[slot] = chosen;
      _selected = null;
      return true;
    }
    if (there == null) return false;
    slots[slot] = null;
    tray.add(there);
    return true;
  }
}
