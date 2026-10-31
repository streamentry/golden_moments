import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/cubit/game_state.dart';
import 'package:golden_moments/l10n/l10n.dart';

/// Calm guidance and found-pairs progress for the board. It deliberately
/// shows no clock, move count or score (DESIGN.md › Interaction & Game Feel),
/// even though [GameState.moves] is still counted internally.
class GameHeader extends StatelessWidget {
  const new({required this.state, super.key});

  final GameState state;

  /// Shown whenever nothing has just happened.
  static String instruction(AppLocalizations l10n) => l10n.gameInstruction;

  /// What just happened on the board, or null when nothing did.
  static String? statusFor(GameState state, AppLocalizations l10n) {
    if (state.showingMismatch) return l10n.gameStatusMismatch;
    if (state.hintTileIds.isNotEmpty) return l10n.gameStatusHint;
    if (state.lastTurnMatched) return l10n.gameStatusMatch;
    return null;
  }

  @override
  Widget build(BuildContext parentContext) {
    final theme = Theme.of(parentContext);
    final scheme = theme.colorScheme;
    final l10n = parentContext.l10n;
    final status = statusFor(state, l10n);
    final message = status ?? instruction(l10n);

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
          label: message,
          excludeSemantics: true,
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
              // Progress in plain counts; no difficulty word, which reads
              // like a judgement of the person (GM-003).
              l10n.gamePairsProgress(
                state.matchedPairs,
                state.currentPack.difficulty.pairCount,
              ),
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
