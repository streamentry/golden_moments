import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/cubit/game_state.dart';

/// Calm guidance and found-pairs progress for the board. It deliberately
/// shows no clock, move count or score (DESIGN.md › Interaction & Game Feel),
/// even though [GameState.moves] is still counted internally.
class GameHeader extends StatelessWidget {
  const new({required this.state, super.key});

  final GameState state;

  /// Shown whenever nothing has just happened.
  static const instruction =
      'Find the matching pictures. There is no time limit.';

  /// What just happened on the board, or null when nothing did.
  static String? statusFor(GameState state) {
    if (state.showingMismatch) {
      return 'Take your time. Tap a picture to continue.';
    }
    if (state.hintTileIds.isNotEmpty) {
      return 'Here is a pair that matches. Tap a picture to continue.';
    }
    if (state.lastTurnMatched) return 'These two match.';
    return null;
  }

  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);
    final scheme = theme.colorScheme;
    final status = statusFor(state);

    return Wrap(
      spacing: gmSpaceMd,
      runSpacing: gmSpaceSm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // A polite live region only while it carries news (a match, a
        // mismatch or a hint), so screen readers hear each event once and
        // the return to the plain instruction is not announced again.
        Semantics(
          container: true,
          liveRegion: status != null,
          label: status ?? instruction,
          excludeSemantics: true,
          child: Text(status ?? instruction, style: theme.textTheme.bodyLarge),
        ),
        DecoratedBox(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(gmRadiusMd),
              side: BorderSide(color: scheme.outline),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: gmSpaceSm,
              vertical: gmSpaceXs,
            ),
            child: Text(
              '${state.currentPack.difficulty.displayName} · '
              '${state.matchedPairs} of '
              '${state.currentPack.difficulty.pairCount} pairs',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
