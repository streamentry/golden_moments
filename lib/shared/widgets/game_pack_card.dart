import 'package:flutter/material.dart';
import 'package:golden_moments/design_system.dart';
import 'package:golden_moments/game/models/models.dart';
import 'package:golden_moments/shared/widgets/download_progress_card.dart';

/// Card widget for displaying a game pack
class GamePackCard extends StatelessWidget {
  const GamePackCard({
    super.key,
    required this.pack,
    required this.onTap,
    this.isHorizontal = false,
    this.showDailyBadge = false,
    this.showPremiumBadge = false,
    this.downloadStatus,
    this.downloadProgress,
  });

  final GamePack pack;
  final VoidCallback onTap;
  final bool isHorizontal;
  final bool showDailyBadge;
  final bool showPremiumBadge;
  final PackDownloadStatus? downloadStatus;
  final double? downloadProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: isHorizontal
            ? _buildHorizontalLayout(theme)
            : _buildVerticalLayout(theme),
      ),
    );
  }

  Widget _buildVerticalLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image placeholder
        Expanded(
          flex: 3,
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
                child: Icon(
                  _getThemeIcon(),
                  size: 48,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              // Badges
              Positioned(
                top: gmSpaceSm,
                right: gmSpaceSm,
                child: _buildBadges(theme),
              ),
              // Download status badge
              if (downloadStatus != null)
                Positioned(
                  bottom: gmSpaceSm,
                  left: gmSpaceSm,
                  child: DownloadStatusBadge(
                    status: downloadStatus!,
                    progress: downloadProgress,
                    size: DownloadBadgeSize.small,
                  ),
                ),
              // Completion indicator
              if (pack.isCompleted)
                Positioned(
                  bottom: gmSpaceSm,
                  right: gmSpaceSm,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Content
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(gmSpaceSm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  pack.theme,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                _buildDifficultyChip(theme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(ThemeData theme) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(gmRadiusMd),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    _getThemeIcon(),
                    size: 32,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                // Completion indicator
                if (pack.isCompleted)
                  Positioned(
                    top: gmSpaceSm,
                    right: gmSpaceSm,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 12,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(gmSpaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pack.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildBadges(theme),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pack.theme,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _buildDifficultyChip(theme),
                      const Spacer(),
                      if (pack.description != null)
                        Expanded(
                          child: Text(
                            pack.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
    Color chipColor;
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

  IconData _getThemeIcon() {
    switch (pack.theme) {
      case '1960s Cars':
        return Icons.directions_car;
      case 'Classic Movies':
        return Icons.movie;
      case 'Retro Toys':
        return Icons.toys;
      case 'Vintage Household Items':
        return Icons.kitchen;
      case 'Old TV Shows':
        return Icons.tv;
      case 'Vintage Fashion':
        return Icons.checkroom;
      default:
        return Icons.photo;
    }
  }
}
