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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image placeholder
        Padding(
          padding: EdgeInsetsGeometry.zero,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(gmRadiusMd),
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: 3 / 2, // width / height
                  child: Image.asset(
                    pack.thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity, // match parent
                  ),
                ),
              ),
              // Badges
              Positioned(
                top: gmSpaceSm,
                right: gmSpaceSm,
                child: _buildBadges(theme),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(gmSpaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    pack.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  pack.theme,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: gmSpaceSm),
                Row(
                  children: [
                    _buildDifficultyChip(theme),
                    const Spacer(),
                    Icon(
                      Icons.play_circle_outline,
                      size: 24,
                      color: theme.colorScheme.primary,
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

  Widget _buildBadges(ThemeData theme) {
    final badges = <Widget>[];

    if (showDailyBadge) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'DAILY',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (showPremiumBadge) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'PREMIUM',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onTertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: badges
          .map(
            (badge) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: badge,
            ),
          )
          .toList(),
    );
  }

  Widget _buildDifficultyChip(ThemeData theme) {
    final Color chipColor;
    switch (pack.difficulty) {
      case GameDifficulty.easy:
        chipColor = Colors.green;
      case GameDifficulty.medium:
        chipColor = Colors.orange;
      case GameDifficulty.hard:
        chipColor = Colors.red;
      case GameDifficulty.brainy:
        chipColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        pack.difficulty.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: chipColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
