import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/game.dart';
import 'package:golden_moments/shared/widgets/pressable.dart';

/// Every pack is bundled and starts with a single tap.
///
/// When [onFavoriteChanged] or [onNotForMe] is given, the card also shows a
/// favorite toggle and a "Not for me" action. The toggle's words change with
/// its state ("Add to favorites" / "In favorites"), as does its star (outline
/// / filled), and it is announced as a toggle. The actions sit below the
/// tappable picture area, at least 8 apart, so choosing them never starts
/// the pack.
class PackCard extends StatelessWidget {
  const new({
    required this.pack,
    this.onTap,
    this.showDailyBadge = false,
    this.showPremiumBadge = false,
    this.isFavorite = false,
    this.onFavoriteChanged,
    this.onNotForMe,
    super.key,
  });
  final Pack pack;
  final VoidCallback? onTap;
  final bool showDailyBadge;
  final bool showPremiumBadge;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteChanged;
  final VoidCallback? onNotForMe;

  bool get _hasActions => onFavoriteChanged != null || onNotForMe != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Pressable(
            onPressed:
                onTap ??
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => GamePage(gamePack: pack),
                    ),
                  );
                },
            // One labelled button for a screen reader: the role annotates
            // the tappable surface's own node (GM-014).
            child: Semantics(button: true, child: _buildLayout(theme)),
          ),
          if (_hasActions) _buildActions(theme),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        gmSpaceXs,
        gmSpaceSm,
        gmSpaceXs,
        gmSpaceXs,
      ),
      child: Wrap(
        spacing: gmSpaceSm,
        runSpacing: gmSpaceSm,
        children: [
          if (onFavoriteChanged case final onChanged?)
            // Words, star shape and the announced toggle state all carry the
            // choice; never colour or fill alone.
            MergeSemantics(
              key: ValueKey('favorite-${pack.id}'),
              child: Semantics(
                toggled: isFavorite,
                child: TextButton.icon(
                  onPressed: () => onChanged(!isFavorite),
                  icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                  label: Text(
                    isFavorite ? 'In favorites' : 'Add to favorites',
                    semanticsLabel: isFavorite
                        ? 'In favorites, ${pack.title}'
                        : 'Add to favorites, ${pack.title}',
                  ),
                ),
              ),
            ),
          if (onNotForMe case final onHide?)
            TextButton.icon(
              key: ValueKey('not-for-me-${pack.id}'),
              onPressed: onHide,
              icon: const Icon(Icons.visibility_off_outlined),
              label: Text(
                'Not for me',
                semanticsLabel: 'Not for me, hide ${pack.title}',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLayout(ThemeData theme) {
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ColoredBox(
              color: gmSurf200,
              child: AspectRatio(
                aspectRatio: 3 / 2, // width / height
                child: Image.asset(
                  pack.thumbnailUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  excludeFromSemantics: true,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.photo_outlined,
                    size: 40,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            Positioned(
              top: gmSpaceSm,
              right: gmSpaceSm,
              child: _buildBadges(theme),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(gmSpaceSm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nothing is clamped: the card grows with its text.
              Text(pack.title, style: theme.textTheme.titleMedium),
              Text(
                pack.theme,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: gmSpaceSm),
              Wrap(
                spacing: gmSpaceSm,
                runSpacing: gmSpaceXs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildDifficultyChip(theme),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 24,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: gmSpaceXs),
                      // Flexible so a narrow card wraps the word instead of
                      // overflowing at large text sizes.
                      Flexible(
                        child: Text(
                          'Play',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badge(ThemeData theme, String label, Color background) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(gmRadiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: gmSpaceSm,
          vertical: gmSpaceXs,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBadges(ThemeData theme) {
    final badges = <Widget>[
      if (showDailyBadge) _badge(theme, 'Daily', theme.colorScheme.secondary),
      if (showPremiumBadge) _badge(theme, 'Premium', theme.colorScheme.primary),
    ];
    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final badge in badges)
          Padding(
            padding: const EdgeInsets.only(bottom: gmSpaceXs),
            child: badge,
          ),
      ],
    );
  }

  /// Difficulty is a choice, not a status, so the chip stays neutral.
  Widget _buildDifficultyChip(ThemeData theme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(gmRadiusMd),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: gmSpaceSm,
          vertical: gmSpaceXs,
        ),
        child: Text(
          pack.difficulty.displayName,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
