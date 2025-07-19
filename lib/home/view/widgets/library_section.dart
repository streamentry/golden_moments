import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/game/models/models.dart';
import 'package:golden_moments/shared/widgets/game_pack_card.dart';

/// Section displaying the game library
class LibrarySection extends StatelessWidget {
  const LibrarySection({
    super.key,
    required this.packs,
    required this.userPreferences,
    required this.onPackTap,
  });

  final List<GamePack> packs;
  final UserPreferences userPreferences;
  final void Function(GamePack pack) onPackTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.library_books,
              size: 32,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: gmSpaceSm),
            Text(
              'Library',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                // TODO: Navigate to full library view
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: gmSpaceSm),
        Text(
          'Explore our full collection of nostalgic memory games',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: gmSpaceMd),

        // Library packs
        if (packs.isEmpty)
          _EmptyState()
        else
          _PacksList(
            packs: packs,
            userPreferences: userPreferences,
            onPackTap: onPackTap,
          ),
      ],
    );
  }
}

/// List layout for library packs
class _PacksList extends StatelessWidget {
  const _PacksList({
    required this.packs,
    required this.userPreferences,
    required this.onPackTap,
  });

  final List<GamePack> packs;
  final UserPreferences userPreferences;
  final void Function(GamePack pack) onPackTap;

  @override
  Widget build(BuildContext context) {
    // Show only first few packs in home view
    final displayPacks = packs.take(4).toList();

    return Column(
      children: displayPacks.map((pack) {
        return Padding(
          padding: const EdgeInsets.only(bottom: gmSpaceSm),
          child: GamePackCard(
            pack: pack,
            onTap: () => onPackTap(pack),
            isHorizontal: true,
            showPremiumBadge: pack.isPremium && !userPreferences.isPremiumUser,
          ),
        );
      }).toList(),
    );
  }
}

/// Empty state when no library packs are available
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(gmRadiusMd),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'Library is empty',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: gmSpaceSm),
            Text(
              'New content will be added soon!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
