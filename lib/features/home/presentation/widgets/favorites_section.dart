import 'package:flutter/material.dart';
import 'package:golden_moments/data/models/pack.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/shared/widgets/pack_card.dart';
import 'package:golden_moments/shared/widgets/pack_grid.dart';

/// The packs the person marked as favorites, first on the page so they are
/// easy to find again (GM-020, GM-026). Only explicit choices: there is no
/// popularity, play count or ranking. Hidden favorites are not listed here.
class FavoritesSection extends StatelessWidget {
  const new({
    required this.packs,
    required this.onPackTap,
    required this.onFavoriteChanged,
    required this.onNotForMe,
    super.key,
  });

  final List<Pack> packs;
  final void Function(Pack pack) onPackTap;
  final void Function(Pack pack, {required bool favorite}) onFavoriteChanged;
  final void Function(Pack pack) onNotForMe;

  @override
  Widget build(BuildContext context) {
    if (packs.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star, size: 32, color: theme.colorScheme.primary),
            const SizedBox(width: gmSpaceSm),
            Flexible(
              child: Text(
                'Your favorites',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: gmSpaceSm),
        Text(
          'Packs you marked Favorite. Tap Favorite again to take one off.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: gmSpaceMd),
        PackGrid(
          packs: packs,
          cardBuilder: (context, pack) => PackCard(
            key: ValueKey('favorite-card-${pack.id}'),
            pack: pack,
            onTap: () => onPackTap(pack),
            isFavorite: true,
            onFavoriteChanged: (favorite) =>
                onFavoriteChanged(pack, favorite: favorite),
            onNotForMe: () => onNotForMe(pack),
          ),
        ),
      ],
    );
  }
}
