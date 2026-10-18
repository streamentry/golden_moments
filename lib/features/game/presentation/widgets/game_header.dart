import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/cubit/game_state.dart';

/// Calm guidance above the board. It deliberately shows no clock or move
/// count (DESIGN.md › Interaction & Game Feel).
class GameHeader extends StatelessWidget {
  const new({required this.state, super.key});

  final GameState state;

  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);
    final scheme = theme.colorScheme;
    final message = state.showingMismatch
        ? 'Not a pair this time. Tap any picture to continue.'
        : state.hintTileIds.isNotEmpty
        ? 'These two match. Tap a picture to continue.'
        : 'Find the matching pictures. There is no time limit.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(gmSpaceMd, gmSpaceSm, gmSpaceMd, 0),
      child: Wrap(
        spacing: gmSpaceMd,
        runSpacing: gmSpaceSm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(message, style: theme.textTheme.bodyLarge),
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
      ),
    );
  }
}
