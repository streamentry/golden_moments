import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/features/game/game.dart';
import 'package:golden_moments/shared/widgets/pressable.dart';

/// Every pack is bundled and starts with a single tap.
class PackCard extends StatelessWidget {
  const PackCard({
    required this.pack,
    this.onTap,
    this.showDailyBadge = false,
    this.showPremiumBadge = false,
    super.key,
  });
  final Pack pack;
  final VoidCallback? onTap;
  final bool showDailyBadge;
  final bool showPremiumBadge;

  /// Height of a [PackCard] in a grid whose columns are [cardWidth] wide.
  ///
  /// The text area grows with the system text size, so nothing clips at
  /// 200% text.
  static double gridExtent(BuildContext context, double cardWidth) =>
      cardWidth * 2 / 3 + 176 * MediaQuery.textScalerOf(context).scale(1);

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Pressable(
      onPressed:
          onTap ??
          () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => GamePage(gamePack: pack),
              ),
            );
          },
      child: _buildLayout(Theme.of(context)),
    ),
  );

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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(gmSpaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    pack.title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  pack.theme,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                        Text(
                          'Play',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
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
