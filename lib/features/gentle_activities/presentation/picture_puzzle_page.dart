import 'dart:math';

import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';
import 'package:golden_moments/features/gentle_activities/models/puzzle_board.dart';
import 'package:golden_moments/features/gentle_activities/presentation/picture_view.dart';
import 'package:golden_moments/shared/widgets/gm_bottom_bar.dart';

/// Experimental tap-to-place picture puzzle (GM-009), reachable only in
/// builds made with `GM_EXPERIMENTS=true`. No drag, clock, score or hint
/// ladder; the whole picture stays in view; leaving is always one tap away.
class PicturePuzzlePage extends StatefulWidget {
  const new({required this.pictures, this.size = 2, this.random, super.key});

  /// Pictures the puzzle may use. The caller passes only visible ones, so a
  /// hidden family photo can never become a puzzle.
  final List<ActivityPicture> pictures;
  final int size;
  final Random? random;

  @override
  State<PicturePuzzlePage> createState() => _PicturePuzzlePageState();
}

class _PicturePuzzlePageState extends State<PicturePuzzlePage> {
  late final Random _random = widget.random ?? Random();
  late ActivityPicture _picture;
  late PuzzleBoard _board;
  final GmMoreBelow _moreBelow = GmMoreBelow();

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _moreBelow.dispose();
    super.dispose();
  }

  void _start() {
    _picture = widget.pictures[_random.nextInt(widget.pictures.length)];
    _board = PuzzleBoard(widget.size, random: _random);
  }

  /// One piece of the picture: the full picture drawn `size` times larger
  /// and cropped to its own cell.
  Widget _piece(int piece, double side) {
    final n = widget.size;
    final col = piece % n;
    final row = piece ~/ n;
    double at(int i) => -1 + 2 * i / (n - 1);
    return ClipRect(
      child: Align(
        alignment: Alignment(at(col), at(row)),
        widthFactor: 1 / n,
        heightFactor: 1 / n,
        child: SizedBox(
          width: side * n,
          height: side * n,
          child: PictureView(picture: _picture),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final n = widget.size;
    final complete = _board.complete;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: gmToolbarHeight(context),
        title: const GmTitle('Picture puzzle'),
      ),
      body: _moreBelow.watch(
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: gmContentMaxWidth),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final available = constraints.maxWidth - 2 * gmSpaceLg;
                  // Size the board to the height too, so the pieces below it
                  // are in view without scrolling at ordinary text sizes; on
                  // a tablet it grows with the screen like the other boards.
                  final fit = constraints.maxHeight * 0.42;
                  final gridSide = max<double>(
                    n * gmTileMin + gmTileGap * (n - 1),
                    min(available, fit),
                  );
                  final slot = (gridSide - gmTileGap * (n - 1)) / n;
                  // Loose pieces stay on one row whenever they can.
                  final pieces = n * n;
                  final rowFit =
                      (available - gmTileGap * (pieces - 1)) / pieces;
                  final trayPiece = max<double>(
                    gmTileMin,
                    min(min(slot * 0.6, 120), rowFit),
                  );
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(gmSpaceLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tap a piece, then tap where it goes. Tap a placed '
                          'piece to take it back.',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: gmSpaceMd),
                        // The reference picture and its name read as one.
                        Semantics(
                          label: 'The whole picture: ${_picture.label}',
                          child: ExcludeSemantics(
                            child: Row(
                              children: [
                                SizedBox.square(
                                  dimension: 72,
                                  child: DecoratedBox(
                                    decoration: ShapeDecoration(
                                      color: scheme.surface,
                                      shape: gmTileShape(scheme),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(gmSpaceXs),
                                      child: PictureView(picture: _picture),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: gmSpaceMd),
                                Expanded(
                                  child: Text(
                                    'The whole picture',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: gmSpaceMd),
                        Center(
                          child: SizedBox(
                            width: gridSide,
                            child: Wrap(
                              spacing: gmTileGap,
                              runSpacing: gmTileGap,
                              children: [
                                for (var s = 0; s < n * n; s++) _slot(s, slot),
                              ],
                            ),
                          ),
                        ),
                        if (_board.tray.isNotEmpty) ...[
                          const SizedBox(height: gmSpaceLg),
                          Semantics(
                            header: true,
                            child: Text(
                              'Pieces',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: gmSpaceSm),
                          Wrap(
                            spacing: gmTileGap,
                            runSpacing: gmTileGap,
                            children: [
                              for (var i = 0; i < _board.tray.length; i++)
                                _trayPiece(_board.tray[i], trayPiece, i),
                            ],
                          ),
                        ],
                        const SizedBox(height: gmSpaceLg),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            complete
                                ? 'The picture is together.'
                                : 'There is no time limit.',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: GmBottomBar(
        moreBelow: _moreBelow,
        child: _exitButtons(complete: complete),
      ),
    );
  }

  /// Side by side only when both labels fit on one line; stacked, the one
  /// primary action (Play again) comes first, as on the matching board.
  Widget _exitButtons({required bool complete}) {
    const doneLabel = 'Done for now';
    final againLabel = complete ? 'Play again' : 'Start again';
    final done = OutlinedButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text(doneLabel, textAlign: TextAlign.center),
    );
    final label = Text(againLabel, textAlign: TextAlign.center);
    final again = complete
        ? FilledButton(onPressed: () => setState(_start), child: label)
        : OutlinedButton(onPressed: () => setState(_start), child: label);
    return GmButtonPair(
      first: done,
      second: again,
      labels: (doneLabel, againLabel),
      secondOnTop: complete,
    );
  }

  Widget _slot(int slot, double side) {
    final scheme = Theme.of(context).colorScheme;
    final n = widget.size;
    final piece = _board.slots[slot];
    final spot = 'Spot ${slot ~/ n + 1}, ${slot % n + 1}';
    return Semantics(
      button: true,
      label: piece == null ? '$spot, empty' : '$spot, has a piece',
      hint: _board.selected != null
          ? (piece == null
                ? 'Places the chosen piece here'
                : 'Swaps with the chosen piece')
          : (piece == null ? 'Choose a piece first' : 'Takes the piece back'),
      onTap: () => setState(() => _board.tapSlot(slot)),
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: side,
          child: Material(
            color: piece == null ? gmSurf200 : scheme.surface,
            shape: gmTileShape(
              scheme,
              emphasized: _board.selected != null && piece == null,
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => setState(() => _board.tapSlot(slot)),
              child: piece == null
                  ? Center(
                      child: Icon(
                        Icons.add,
                        size: 40,
                        color: scheme.onSurfaceVariant,
                      ),
                    )
                  : _piece(piece, side),
            ),
          ),
        ),
      ),
    );
  }

  Widget _trayPiece(int piece, double side, int position) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _board.selected == piece;
    return Semantics(
      button: true,
      // The position in the tray tells pieces apart without revealing where
      // each one belongs.
      label: 'Piece ${position + 1} of ${_board.tray.length}',
      value: selected ? 'Selected' : '',
      onTap: () => setState(() => _board.select(piece)),
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: side,
          child: Material(
            color: scheme.surface,
            shape: gmTileShape(scheme, emphasized: selected),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => setState(() => _board.select(piece)),
              child: _piece(piece, side),
            ),
          ),
        ),
      ),
    );
  }
}
