import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/l10n/l10n.dart';
import 'package:golden_moments/shared/widgets/gm_bottom_bar.dart';

/// "Done for now" and "Start again", fixed below the board so the exit is
/// always on screen (GM-002).
///
/// The two buttons sit side by side whenever their labels fit on one line
/// at the current text size; they stack only when they genuinely do not, so
/// the bar never takes more height than it needs (GM-012/GM-016).
class GameExitBar extends StatelessWidget {
  const new({
    required this.onDone,
    required this.onStartAgain,
    this.moreBelow,
    super.key,
  });

  final VoidCallback onDone;
  final VoidCallback onStartAgain;

  /// Draws the bar's dividing line while the board continues beneath it.
  final GmMoreBelow? moreBelow;

  @override
  Widget build(BuildContext context) {
    final doneLabel = context.l10n.commonDoneForNow;
    final startAgainLabel = context.l10n.commonStartAgain;
    final done = OutlinedButton(
      onPressed: onDone,
      child: Text(doneLabel, textAlign: TextAlign.center),
    );
    final again = OutlinedButton(
      onPressed: onStartAgain,
      child: Text(startAgainLabel, textAlign: TextAlign.center),
    );
    return GmBottomBar(
      moreBelow: moreBelow,
      child: GmButtonPair(
        first: done,
        second: again,
        labels: (doneLabel, startAgainLabel),
      ),
    );
  }
}
